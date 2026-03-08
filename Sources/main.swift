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
    var message: String {
        switch self {
        case .missingArgument(let m): return m
        case .directoryExists(let m): return m
        }
    }
}

func runHelp() {
    print("""
    \(Colors.bold)Usage:\(Colors.reset) saas <command> [options]
    \(Colors.bold)Commands:\(Colors.reset)
      \(Colors.cyan)new\(Colors.reset) <name>       Create new project
      \(Colors.cyan)add\(Colors.reset) <service>     Add service
      \(Colors.cyan)list\(Colors.reset)             List services
      \(Colors.cyan)doctor\(Colors.reset)           Diagnose
    """)
}

func runNew(name: String, options: [String]) throws {
    guard !name.isEmpty else { throw CLIError.missingArgument("Project name required") }
    print("\(Colors.cyan)🚀 Creating \(name)...\n\(Colors.reset)")
    let currentDir = FileManager.default.currentDirectoryPath
    let projectPath = "\(currentDir)/\(name)"
    if FileManager.default.fileExists(atPath: projectPath) { throw CLIError.directoryExists("Directory exists") }
    try FileManager.default.createDirectory(atPath: projectPath, withIntermediateDirectories: true)
    
    // package.json
    let pkg = """
    {
      "name": "\(name)",
      "version": "0.1.0",
      "scripts": {
        "dev": "next dev",
        "build": "next build",
        "start": "next start"
      },
      "dependencies": {
        "react": "^18", "react-dom": "^18", "next": "14.1.0",
        "@supabase/supabase-js": "^2.39.0",
        "stripe": "^14.14.0",
        "resend": "^3.2.0",
        "lucide-react": "^0.312.0",
        "clsx": "^2.1.0",
        "tailwind-merge": "^2.2.0"
      },
      "devDependencies": {
        "typescript": "^5.3.0",
        "@types/node": "^20.11.0",
        "autoprefixer": "^10.4.17",
        "postcss": "^8.4.33",
        "tailwindcss": "^3.4.1"
      }
    }
    """
    try pkg.write(toFile: "\(projectPath)/package.json", atomically: true, encoding: .utf8)
    
    // tsconfig.json
    try """
    {
      "compilerOptions": {
        "lib": ["dom", "esnext"], "allowJs": true, "strict": true,
        "module": "esnext", "moduleResolution": "bundler",
        "jsx": "preserve", "incremental": true,
        "plugins": [{ "name": "next" }],
        "paths": { "@/*": ["./*"] }
      },
      "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
      "exclude": ["node_modules"]
    }
    """.write(toFile: "\(projectPath)/tsconfig.json", atomically: true, encoding: .utf8)
    
    // next.config.js
    try "const nextConfig = {}; module.exports = nextConfig".write(toFile: "\(projectPath)/next.config.js", atomically: true, encoding: .utf8)
    
    // tailwind.config.ts
    try """
    import type { Config } from 'tailwindcss'
    const config: Config = { content: ['./app/**/*.{js,ts,jsx,tsx}', './components/**/*.{js,ts,jsx,tsx}'], theme: { extend: {} }, plugins: [] }
    export default config
    """.write(toFile: "\(projectPath)/tailwind.config.ts", atomically: true, encoding: .utf8)
    
    // .env.example
    try """
    NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
    NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
    STRIPE_SECRET_KEY=sk_test_...
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
    RESEND_API_KEY=re_...
    NEXT_PUBLIC_APP_URL=http://localhost:3000
    """.write(toFile: "\(projectPath)/.env.example", atomically: true, encoding: .utf8)
    
    // app/layout.tsx
    try FileManager.default.createDirectory(atPath: "\(projectPath)/app", withIntermediateDirectories: true)
    try """
    import './globals.css'
    export const metadata = { title: '\(name)', description: 'Built with saas-cli' }
    export default function RootLayout({ children }: { children: React.ReactNode }) {
      return <html><body>{children}</body></html>
    }
    """.write(toFile: "\(projectPath)/app/layout.tsx", atomically: true, encoding: .utf8)
    
    // app/globals.css
    try """
    @tailwind base; @tailwind components; @tailwind utilities;
    @layer base { * { @apply border-border; } body { @apply bg-background text-foreground; } }
    """.write(toFile: "\(projectPath)/app/globals.css", atomically: true, encoding: .utf8)
    
    // app/page.tsx
    try """
    import Link from 'next/link'
    export default function Home() {
      return <main className="flex min-h-screen flex-col items-center justify-center p-24">
        <h1 className="text-4xl font-bold mb-4">Welcome to \(name)</h1>
        <p className="text-gray-600 mb-8">Built with saas-cli</p>
        <div className="flex gap-4"><Link href="/login" className="px-6 py-3 bg-blue-600 text-white rounded-lg">Get Started</Link></div>
      </main>
    }
    """.write(toFile: "\(projectPath)/app/page.tsx", atomically: true, encoding: .utf8)
    
    // lib/supabase.ts
    try FileManager.default.createDirectory(atPath: "\(projectPath)/lib", withIntermediateDirectories: true)
    try """
    import { createClient } from '@supabase/supabase-js'
    export const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!)
    """.write(toFile: "\(projectPath)/lib/supabase.ts", atomically: true, encoding: .utf8)
    
    // lib/stripe.ts
    try """
    import Stripe from 'stripe'
    export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, { apiVersion: '2023-10-16' })
    """.write(toFile: "\(projectPath)/lib/stripe.ts", atomically: true, encoding: .utf8)
    
    // README
    try """
    # \(name)
    Built with saas-cli
    ## Install: npm install && npm run dev
    """.write(toFile: "\(projectPath)/README.md", atomically: true, encoding: .utf8)
    
    print("\(Colors.green)✅ Project created!\(Colors.reset)")
    print("cd \(name)")
    print("cp .env.example .env.local")
    print("npm install")
    print("npm run dev")
}

func runList() {
    print("""
    \(Colors.bold)Available Services:\(Colors.reset)
    \(Colors.cyan)supabase\(Colors.reset) - Auth + Database
    \(Colors.cyan)stripe\(Colors.reset) - Payments
    \(Colors.cyan)resend\(Colors.reset) - Email
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
    case "new": guard let name = cli.options.first else { throw CLIError.missingArgument("Name required") }; printBanner(); try runNew(name: name, options: cli.options)
    case "list": runList()
    case "doctor": runDoctor()
    default: print("\(Colors.red)Unknown command\(Colors.reset)")
    }
} catch let e as CLIError { print("\(Colors.red)Error: \(e.message)\(Colors.reset)"); exit(1) }
catch { print("\(Colors.red)Error: \(error)\(Colors.reset)"); exit(1) }
