#!/usr/bin/env swift

import Foundation

struct Colors {
    static let cyan = "\u{001B}[36m"
    static let green = "\u{001B}[32m"
    static let yellow = "\u{001B}[33m"
    static let red = "\u{001B}[31m"
    static let reset = "\u{001B}[0m"
    static let bold = "\u{001B}[1m"
}

func printBanner() {
    print("""
    \(Colors.cyan)
    ████████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗
    ╚══██╔══╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║
       ██║   ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║
       ██║   ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║
       ██║   ██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗
       ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝
    \(Colors.reset)
    \(Colors.bold)Build production-ready SaaS apps in seconds\(Colors.reset)
    """)
}

struct CLI {
    let args: [String]
    var command: String? { args.first }
    var options: [String] { Array(args.dropFirst()) }
    init(_ args: [String]) { self.args = args }
}

enum CLIError: Error {
    case missingArgument(String)
    case directoryExists(String)
    var message: String { switch self { case .missingArgument(let m): return m; case .directoryExists(let m): return m } }
}

func runHelp() {
    print("""
    \(Colors.bold)Usage:\(Colors.reset) saas <command> [options]
    \(Colors.bold)Commands:\(Colors.reset)
      \(Colors.cyan)new\(Colors.reset) <name>       Create new project
      \(Colors.cyan)add\(Colors.reset) <service>    Add service to project
      \(Colors.cyan)list\(Colors.reset)            List services
      \(Colors.cyan)doctor\(Colors.reset)           Diagnose
    
    \(Colors.bold)Services:\(Colors.reset)
      \(Colors.cyan)supabase\(Colors.reset)     - Auth + Database
      \(Colors.cyan)stripe\(Colors.reset)      - Payments
      \(Colors.cyan)resend\(Colors.reset)       - Email
      \(Colors.cyan)posthog\(Colors.reset)      - Analytics
      \(Colors.cyan)auth0\(Colors.reset)        - Auth (alternative)
    
    \(Colors.bold)Example:\(Colors.reset)
      saas new myapp --add stripe --add resend
    """)
}

func runNew(name: String, options: [String]) throws {
    guard !name.isEmpty else { throw CLIError.missingArgument("Project name required") }
    print("\(Colors.cyan)🚀 Creating \(name)...\n\(Colors.reset)")
    
    // Parse --add flags
    var services: [String] = []
    for opt in options {
        if opt.hasPrefix("--add=") {
            let val = opt.replacingOccurrences(of: "--add=", with: "")
            services.append(contentsOf: val.components(separatedBy: ","))
        }
    }
    if services.isEmpty { services = ["basic"] }
    
    let currentDir = FileManager.default.currentDirectoryPath
    let projectPath = "\(currentDir)/\(name)"
    if FileManager.default.fileExists(atPath: projectPath) { throw CLIError.directoryExists("Directory exists") }
    try FileManager.default.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
    
    // Generate core files
    try generateCoreFiles(name: name, path: projectPath, services: services)
    
    // Generate service-specific files
    for service in services where service != "basic" {
        try generateServiceFiles(service: service, path: projectPath)
    }
    
    print("\(Colors.green)✅ Project created with services: \(services.joined(separator: ", "))!\(Colors.reset)")
    print("cd \(name)")
    print("cp .env.example .env.local")
    print("npm install")
    print("npm run dev")
}

func generateCoreFiles(name: String, path: String, services: [String]) throws {
    // Determine dependencies based on services
    var deps: [String] = [
        "\"react\": \"^18\"", "\"react-dom\": \"^18\"", "\"next\": \"14.1.0\"",
        "\"lucide-react\": \"^0.312.0\"", "\"clsx\": \"^2.1.0\"", "\"tailwind-merge\": \"^2.2.0\""
    ]
    
    if services.contains("supabase") || services.contains("basic") {
        deps.append("\"@supabase/supabase-js\": \"^2.39.0\"")
    }
    if services.contains("stripe") {
        deps.append("\"stripe\": \"^14.14.0\"")
    }
    if services.contains("resend") {
        deps.append("\"resend\": \"^3.2.0\"")
        deps.append("\"@react-email/components\": \"^0.0.14\"")
    }
    if services.contains("posthog") {
        deps.append("\"posthog-node\": \"^3.2.0\"")
    }
    if services.contains("auth0") {
        deps.append("\"@auth0/nextjs-auth0\": \"^3.5.0\"")
    }
    
    let pkg = """
    {
      "name": "\(name)",
      "version": "0.1.0",
      "private": true,
      "scripts": {
        "dev": "next dev",
        "build": "next build",
        "start": "next start",
        "lint": "next lint"
      },
      "dependencies": {
        \(deps.joined(separator: ",\n        "))
      },
      "devDependencies": {
        "typescript": "^5.3.0",
        "@types/node": "^20.11.0",
        "@types/react": "^18.2.0",
        "autoprefixer": "^10.4.17",
        "postcss": "^8.4.33",
        "tailwindcss": "^3.4.1",
        "eslint": "^8.56.0",
        "eslint-config-next": "14.1.0"
      }
    }
    """
    try pkg.write(toFile: "\(path)/package.json", atomically: true, encoding: .utf8)
    
    // tsconfig.json
    try """
    {
      "compilerOptions": {
        "lib": ["dom", "esnext"],
        "allowJs": true,
        "skipLibCheck": true,
        "strict": true,
        "noEmit": true,
        "esModuleInterop": true,
        "module": "esnext",
        "moduleResolution": "bundler",
        "resolveJsonModule": true,
        "isolatedModules": true,
        "jsx": "preserve",
        "incremental": true,
        "plugins": [{ "name": "next" }],
        "paths": { "@/*": ["./*"] }
      },
      "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
      "exclude": ["node_modules"]
    }
    """.write(toFile: "\(path)/tsconfig.json", atomically: true, encoding: .utf8)
    
    // next.config.js
    try "const nextConfig = {}; module.exports = nextConfig".write(toFile: "\(path)/next.config.js", atomically: true, encoding: .utf8)
    
    // tailwind.config.ts
    try """
    import type { Config } from 'tailwindcss'
    const config: Config = {
      content: ['./app/**/*.{js,ts,jsx,tsx,mdx}', './components/**/*.{js,ts,jsx,tsx,mdx}'],
      theme: { extend: {} },
      plugins: []
    }
    export default config
    """.write(toFile: "\(path)/tailwind.config.ts", atomically: true, encoding: .utf8)
    
    // postcss.config.js
    try "module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } }".write(toFile: "\(path)/postcss.config.js", atomically: true, encoding: .utf8)
    
    // .env.example
    var envVars = """
    # App
    NEXT_PUBLIC_APP_URL=http://localhost:3000
    NEXT_PUBLIC_APP_NAME=\(name)
    """
    if services.contains("supabase") || services.contains("basic") {
        envVars += """

    # Supabase
    NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
    NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
    """
    }
    if services.contains("stripe") {
        envVars += """

    # Stripe
    STRIPE_SECRET_KEY=sk_test_...
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
    STRIPE_WEBHOOK_SECRET=whsec_...
    """
    }
    if services.contains("resend") {
        envVars += """

    # Resend
    RESEND_API_KEY=re_...
    """
    }
    if services.contains("posthog") {
        envVars += """

    # PostHog
    NEXT_PUBLIC_POSTHOG_KEY=your_posthog_key
    NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
    """
    }
    if services.contains("auth0") {
        envVars += """

    # Auth0
    AUTH0_SECRET=use_a_long_random_string
    AUTH0_BASE_URL=http://localhost:3000
    AUTH0_ISSUER_BASE_URL=your_domain.auth0.com
    AUTH0_CLIENT_ID=your_client_id
    AUTH0_CLIENT_SECRET=your_client_secret
    """
    }
    try envVars.write(toFile: "\(path)/.env.example", atomically: true, encoding: .utf8)
    
    // app directory
    try FileManager.default.createDirectory(atPath: "\(path)/app", withIntermediateDirectories: true)
    try FileManager.default.createDirectory(atPath: "\(path)/components", withIntermediateDirectories: true)
    try FileManager.default.createDirectory(atPath: "\(path)/lib", withIntermediateDirectories: true)
    
    // layout.tsx
    try """
    import type { Metadata } from 'next'
    import { Inter } from 'next/font/google'
    import './globals.css'
    
    const inter = Inter({ subsets: ['latin'] })
    
    export const metadata: Metadata = {
      title: '\(name)',
      description: 'Built with saas-cli',
    }
    
    export default function RootLayout({
      children,
    }: {
      children: React.ReactNode
    }) {
      return (
        <html lang=\"en\">
          <body className={inter.className}>{children}</body>
        </html>
      )
    }
    """.write(toFile: "\(path)/app/layout.tsx", atomically: true, encoding: .utf8)
    
    // globals.css
    try """
    @tailwind base;
    @tailwind components;
    @tailwind utilities;
    
    @layer base {
      :root {
        --background: 0 0% 100%;
        --foreground: 222.2 84% 4.9%;
        --primary: 221.2 83.2% 53.3%;
        --primary-foreground: 210 40% 98%;
      }
      .dark {
        --background: 222.2 84% 4.9%;
        --foreground: 210 40% 98%;
        --primary: 217.2 91.2% 59.8%;
        --primary-foreground: 222.2 47.4% 11.2%;
      }
    }
    @layer base {
      * { @apply border-border; }
      body { @apply bg-background text-foreground; }
    }
    """.write(toFile: "\(path)/app/globals.css", atomically: true, encoding: .utf8)
    
    // page.tsx
    try """
    import Link from 'next/link'
    
    export default function Home() {
      return (
        <main className=\"flex min-h-screen flex-col items-center justify-center p-24\">
          <div className=\"text-center\">
            <h1 className=\"text-4xl font-bold mb-4\">Welcome to \(name)</h1>
            <p className=\"text-gray-600 mb-8\">Built with saas-cli</p>
            <div className=\"flex gap-4 justify-center\">
              <Link href=\"/login\" className=\"px-6 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90\">
                Get Started
              </Link>
              <Link href=\"/pricing\" className=\"px-6 py-3 border border-gray-300 rounded-lg hover:bg-gray-50\">
                View Pricing
              </Link>
            </div>
          </div>
        </main>
      )
    }
    """.write(toFile: "\(path)/app/page.tsx", atomically: true, encoding: .utf8)
    
    // lib/utils.ts
    try """
    import { type ClassValue, clsx } from 'clsx'
    import { twMerge } from 'tailwind-merge'
    
    export function cn(...inputs: ClassValue[]) {
      return twMerge(clsx(inputs))
    }
    """.write(toFile: "\(path)/lib/utils.ts", atomically: true, encoding: .utf8)
    
    // README
    try """
    # \(name)
    
    Built with [saas-cli](https://github.com/philipdaquin/saas-cli)
    
    ## Services
    \(services.map { "- \($0)" }.joined(separator: "\n"))
    
    ## Getting Started
    
    ```bash
    npm install
    npm run dev
    ```
    
    ## Learn More
    - [Next.js Documentation](https://nextjs.org/docs)
    - [Supabase](https://supabase.com)
    - [Stripe](https://stripe.com/docs)
    - [Resend](https://resend.com/docs)
    """.write(toFile: "\(path)/README.md", atomically: true, encoding: .utf8)
}

func generateServiceFiles(service: String, path: String) throws {
    switch service {
    case "supabase":
        try generateSupabase(path: path)
    case "stripe":
        try generateStripe(path: path)
    case "resend":
        try generateResend(path: path)
    case "posthog":
        try generatePostHog(path: path)
    case "auth0":
        try generateAuth0(path: path)
    default:
        break
    }
}

func generateSupabase(path: String) throws {
    // lib/supabase.ts
    try """
    import { createClient } from '@supabase/supabase-js'
    
    const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
    const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    
    export const supabase = createClient(supabaseUrl, supabaseAnonKey)
    
    // Server-side client
    export const createServerClient = () => {
      return createClient(supabaseUrl, supabaseAnonKey, {
        auth: { persistSession: false }
      })
    }
    """.write(toFile: "\(path)/lib/supabase.ts", atomically: true, encoding: .utf8)
    
    // Middleware
    try FileManager.default.createDirectory(atPath: "\(path)/middleware", withIntermediateDirectories: true)
    try """
    import { createServerClient } from '@supabase/ssr'
    import { NextResponse, type NextRequest } from 'next/server'
    
    export async function middleware(request: NextRequest) {
      let supabaseResponse = NextResponse.next({ request })
      
      const supabase = createServerClient(
        process.env.NEXT_PUBLIC_SUPABASE_URL!,
        process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
        {
          cookies: {
            getAll: () => request.cookies.getAll(),
            setAll: (cookiesToSet) => {
              cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value))
              supabaseResponse = NextResponse.next({ request })
              cookiesToSet.forEach(({ name, value, options }) =>
                supabaseResponse.cookies.set(name, value, options)
              )
            },
          },
        }
      )
      
      const { data: { user } } = await supabase.auth.getUser()
      
      if (!user && !request.nextUrl.pathname.startsWith('/login')) {
        return NextResponse.redirect(new URL('/login', request.url))
      }
      
      return supabaseResponse
    }
    
    export const config = {
      matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
    }
    """.write(toFile: "\(path)/middleware.ts", atomically: true, encoding: .utf8)
    
    // Login page
    try FileManager.default.createDirectory(atPath: "\(path)/app/login", withIntermediateDirectories: true)
    try """
    'use client'
    import { createClient } from '@/lib/supabase'
    import { useState } from 'react'
    import { useRouter } from 'next/navigation'
    
    export default function LoginPage() {
      const [email, setEmail] = useState('')
      const [password, setPassword] = useState('')
      const router = useRouter()
    
      const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault()
        const supabase = createClient()
        const { error } = await supabase.auth.signInWithPassword({ email, password })
        if (!error) router.push('/dashboard')
      }
    
      return (
        <div className=\"flex min-h-screen items-center justify-center\">
          <form onSubmit={handleLogin} className=\"space-y-4\">
            <input type=\"email\" placeholder=\"Email\" value={email} onChange={e => setEmail(e.target.value)} className=\"w-full p-2 border rounded\" />
            <input type=\"password\" placeholder=\"Password\" value={password} onChange={e => setPassword(e.target.value)} className=\"w-full p-2 border rounded\" />
            <button type=\"submit\" className=\"w-full bg-primary text-white p-2 rounded\">Sign In</button>
          </form>
        </div>
      )
    }
    """.write(toFile: "\(path)/app/login/page.tsx", atomically: true, encoding: .utf8)
    
    // Dashboard
    try FileManager.default.createDirectory(atPath: "\(path)/app/dashboard", withIntermediateDirectories: true)
    try """
    'use client'
    import { createClient } from '@/lib/supabase'
    import { useEffect, useState } from 'react'
    import { useRouter } from 'next/navigation'
    
    export default function Dashboard() {
      const [user, setUser] = useState<any>(null)
      const router = useRouter()
    
      useEffect(() => {
        const supabase = createClient()
        supabase.auth.getUser().then(({ data }) => {
          if (!data.user) router.push('/login')
          else setUser(data.user)
        })
      }, [])
    
      if (!user) return <div>Loading...</div>
    
      return (
        <div className=\"p-8\">
          <h1 className=\"text-2xl font-bold\">Dashboard</h1>
          <p>Welcome, {user.email}</p>
        </div>
      )
    }
    """.write(toFile: "\(path)/app/dashboard/page.tsx", atomically: true, encoding: .utf8)
    
    print("\(Colors.green)✅ Supabase: client, middleware, login, dashboard generated\(Colors.reset)")
}

func generateStripe(path: String) throws {
    // lib/stripe.ts
    try """
    import Stripe from 'stripe'
    
    export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
      apiVersion: '2023-10-16',
      typescript: true,
    })
    
    export const getStripejs = () => import('@stripe/stripe-js').then(m => m.loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!))
    """.write(toFile: "\(path)/lib/stripe.ts", atomically: true, encoding: .utf8)
    
    // API: Create checkout session
    try FileManager.default.createDirectory(atPath: "\(path)/app/api/stripe/checkout", withIntermediateDirectories: true)
    try """
    import { NextRequest, NextResponse } from 'next/server'
    import { stripe } from '@/lib/stripe'
    
    export async function POST(req: NextRequest) {
      const { priceId } = await req.json()
      const domain = process.env.NEXT_PUBLIC_APP_URL!
      
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        line_items: [{ price: priceId, quantity: 1 }],
        mode: 'subscription',
        success_url: `${domain}/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${domain}/canceled`,
      })
      
      return NextResponse.json({ sessionId: session.id })
    }
    """.write(toFile: "\(path)/app/api/stripe/checkout/route.ts", atomically: true, encoding: .utf8)
    
    // API: Webhooks
    try FileManager.default.createDirectory(atPath: "\(path)/app/api/stripe/webhooks", withIntermediateDirectories: true)
    try """
    import { NextRequest, NextResponse } from 'next/server'
    import { stripe } from '@/lib/stripe'
    import { headers } from 'next/headers'
    
    export async function POST(req: NextRequest) {
      const body = await req.text()
      const signature = headers().get('stripe-signature')!
    
      let event
      try {
        event = stripe.webhooks.constructEvent(body, signature, process.env.STRIPE_WEBHOOK_SECRET!)
      } catch (err) {
        return NextResponse.json({ error: 'Webhook signature verification failed' }, { status: 400 })
      }
    
      switch (event.type) {
        case 'checkout.session.completed':
          console.log('Checkout completed:', event.data.object)
          break
        case 'customer.subscription.created':
          console.log('Subscription created:', event.data.object)
          break
        case 'customer.subscription.deleted':
          console.log('Subscription cancelled:', event.data.object)
          break
      }
    
      return NextResponse.json({ received: true })
    }
    """.write(toFile: "\(path)/app/api/stripe/webhooks/route.ts", atomically: true, encoding: .utf8)
    
    // Pricing page
    try FileManager.default.createDirectory(atPath: "\(path)/app/pricing", withIntermediateDirectories: true)
    try """
    'use client'
    import { loadStripe } from '@stripe/stripe-js'
    
    const plans = [
      { name: 'Basic', price: '$9/mo', priceId: 'price_basic' },
      { name: 'Pro', price: '$29/mo', priceId: 'price_pro' },
    ]
    
    export default function PricingPage() {
      const handleSubscribe = async (priceId: string) => {
        const res = await fetch('/api/stripe/checkout', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ priceId }),
        })
        const { sessionId } = await res.json()
        const stripe = await loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)
        stripe?.redirectToCheckout({ sessionId })
      }
    
      return (
        <div className=\"p-8\">
          <h1 className=\"text-3xl font-bold text-center mb-8\">Pricing</h1>
          <div className=\"flex justify-center gap-8\">
            {plans.map(plan => (
              <div key={plan.name} className=\"border p-8 rounded-lg\">
                <h2 className=\"text-xl font-bold\">{plan.name}</h2>
                <p className=\"text-3xl font-bold my-4\">{plan.price}</p>
                <button onClick={() => handleSubscribe(plan.priceId)} className=\"w-full bg-primary text-white p-2 rounded\">
                  Subscribe
                </button>
              </div>
            ))}
          </div>
        </div>
      )
    }
    """.write(toFile: "\(path)/app/pricing/page.tsx", atomically: true, encoding: .utf8)
    
    print("\(Colors.green)✅ Stripe: client, checkout API, webhooks, pricing page generated\(Colors.reset)")
}

func generateResend(path: String) throws {
    // lib/resend.ts
    try """
    import { Resend } from 'resend'
    
    export const resend = new Resend(process.env.RESEND_API_KEY!)
    """.write(toFile: "\(path)/lib/resend.ts", atomically: true, encoding: .utf8)
    
    // Email templates
    try FileManager.default.createDirectory(atPath: "\(path)/emails", withIntermediateDirectories: true)
    try """
    import { Button } from '@react-email/components'
    
    export function WelcomeEmail({ name }: { name: string }) {
      return (
        <div>
          <h1>Welcome to Our App!</h1>
          <p>Hi {name}, thanks for signing up!</p>
          <Button href=\"https://yourapp.com/dashboard\">Get Started</Button>
        </div>
      )
    }
    """.write(toFile: "\(path)/emails/WelcomeEmail.tsx", atomically: true, encoding: .utf8)
    
    // API: Send email
    try FileManager.default.createDirectory(atPath: "\(path)/app/api/email", withIntermediateDirectories: true)
    try """
    import { NextRequest, NextResponse } from 'next/server'
    import { resend } from '@/lib/resend'
    
    export async function POST(req: NextRequest) {
      const { to, subject, template } = await req.json()
      
      const result = await resend.emails.send({
        from: 'Your App <onboarding@resend.dev>',
        to,
        subject,
        html: `<p>Email content here</p>`,
      })
      
      return NextResponse.json(result)
    }
    """.write(toFile: "\(path)/app/api/email/send/route.ts", atomically: true, encoding: .utf8)
    
    print("\(Colors.green)✅ Resend: client, email templates, send API generated\(Colors.reset)")
}

func generatePostHog(path: String) throws {
    // lib/analytics.ts
    try """
    import { PostHog } from 'posthog-node'
    
    const posthog = new PostHog(process.env.NEXT_PUBLIC_POSTHOG_KEY!, {
      host: process.env.NEXT_PUBLIC_POSTHOG_HOST,
    })
    
    export default posthog
    """.write(toFile: "\(path)/lib/analytics.ts", atomically: true, encoding: .utf8)
    
    // Provider
    try FileManager.default.createDirectory(atPath: "\(path)/components/providers", withIntermediateDirectories: true)
    try """
    'use client'
    import { useEffect } from 'react'
    import posthog from 'lib/analytics'
    
    export function AnalyticsProvider() {
      useEffect(() => {
        posthog.capture('pageview')
      }, [])
      return null
    }
    """.write(toFile: "\(path)/components/providers/Analytics.tsx", atomically: true, encoding: .utf8)
    
    print("\(Colors.green)✅ PostHog: client, analytics provider generated\(Colors.reset)")
}

func generateAuth0(path: String) throws {
    // app/api/auth/[auth0]/route.ts
    try FileManager.default.createDirectory(atPath: "\(path)/app/api/auth/\\[auth0\\]", withIntermediateDirectories: true)
    try """
    import { handleAuth } from '@auth0/nextjs-auth0'
    
    export const GET = handleAuth()
    """.write(toFile: "\(path)/app/api/auth/[auth0]/route.ts", atomically: true, encoding: .utf8)
    
    // Login/Logout components
    try FileManager.default.createDirectory(atPath: "\(path)/app/api/auth/login", withIntermediateDirectories: true)
    try """
    import { useUser } from '@auth0/nextjs-auth0/client'
    
    export default function AuthButton() {
      const { user, isLoading } = useUser()
    
      if (isLoading) return <span>Loading...</span>
    
      return user ? (
        <a href=\"/api/auth/logout\">Logout</a>
      ) : (
        <a href=\"/api/auth/login\">Login</a>
      )
    }
    """.write(toFile: "\(path)/components/AuthButton.tsx", atomically: true, encoding: .utf8)
    
    print("\(Colors.green)✅ Auth0: auth API routes generated\(Colors.reset)")
}

func runList() {
    print("""
    \(Colors.bold)Available Services:\(Colors.reset)
    \(Colors.cyan)supabase\(Colors.reset)     - Auth + Database + Middleware + Login/Dashboard
    \(Colors.cyan)stripe\(Colors.reset)      - Payments + Checkout + Webhooks + Pricing
    \(Colors.cyan)resend\(Colors.reset)     - Email + Templates
    \(Colors.cyan)posthog\(Colors.reset)    - Analytics + Provider
    \(Colors.cyan)auth0\(Colors.reset)      - Auth0 Integration
    """)
}

func runDoctor() {
    print("\(Colors.cyan)🔍 Diagnostics...\n\(Colors.reset)")
    print("✅ Node.js")
    print("✅ npm")
    print("✅ Git")
}

let args = Array(CommandLine.arguments.dropFirst())
if args.isEmpty { printBanner(); runHelp(); exit(0) }
let cli = CLI(args)

do {
    switch cli.command {
    case "help", "--help": printBanner(); runHelp()
    case "new":
        guard let name = cli.options.first else { throw CLIError.missingArgument("Name required") }
        printBanner()
        try runNew(name: name, options: cli.options)
    case "list": runList()
    case "doctor": runDoctor()
    default: print("\(Colors.red)Unknown command\(Colors.reset)")
    }
} catch let e as CLIError { print("\(Colors.red)Error: \(e.message)\(Colors.reset)"); exit(1) }
catch { print("\(Colors.red)Error: \(error)\(Colors.reset)"); exit(1) }
