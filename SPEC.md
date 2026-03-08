# SaaS Scaffolder CLI - Specification Document

## 1. Overview

**Project Name:** `saas-cli`  
**Type:** Command-Line Interface Tool  
**Core Functionality:** A CLI tool that scaffolds complete, production-ready SaaS applications with the most popular modern stack - Next.js, TypeScript, Supabase, Stripe, Resend, Vercel, and Cloudflare.  
**Target Users:** Developers, startups, and teams building modern SaaS products who want to skip boilerplate setup and focus on business logic.

---

## 2. The Stack

### 🏆 Core Stack (Default)

| Category | Primary Option | Description |
|----------|---------------|-------------|
| **🔐 Auth** | Supabase | Auth + PostgreSQL in one |
| **🗄️ Database** | PostgreSQL (via Supabase) | Relational data |
| **💳 Payments** | Stripe | Subscriptions, payments |
| **📧 Email** | Resend | Transactional emails |
| **☁️ Hosting** | Vercel | Deploy + CDN |
| **🌐 DNS** | Cloudflare | Domain + security |

### Tech Stack

- **Framework:** Next.js 14+ (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **Auth:** Supabase Auth
- **Database:** Supabase PostgreSQL
- **Payments:** Stripe
- **Email:** React Email + Resend

---

## 3. Presets

### MVP (Minimal)
```
Next.js + TypeScript + Supabase + Stripe
```
Just auth + payments. Everything else minimal.

### Full-Stack
```
Next.js + TypeScript + Supabase + Stripe + Resend + Vercel + Cloudflare
```
Everything included. The complete package.

### Custom
Pick and choose individual services.

---

## 4. CLI Commands

### Core Commands

```bash
# Create new project
saas new <project-name>              # Interactive prompts
saas new <project-name> --preset=mvp # Use MVP preset
saas new <project-name> --template=<github-repo> # Custom template

# Service management
saas add <service>                  # Add a service
saas remove <service>                # Remove a service
saas list                           # List current services

# Configuration
saas config                         # Configure API keys
saas env                            # Show environment variables

# Development
saas dev                           # Start dev server
saas build                         # Build for production
saas deploy                        # Deploy to Vercel

# Utilities
saas doctor                        # Diagnose issues
saas update                        # Update CLI
```

### Service Commands

```bash
# Auth
saas add auth                      # Add Supabase Auth
saas add auth --provider=firebase  # Add Firebase instead

# Database
saas add db                       # Add PostgreSQL (Supabase)
saas add redis                    # Add Redis

# Payments
saas add stripe                   # Add Stripe
saas add stripe:webhooks         # Add Stripe webhooks

# Email
saas add email                    # Add Resend
saas add email --provider=sendgrid # Alternative

# Hosting
saas add hosting                  # Add Vercel
saas deploy                       # Deploy to Vercel
```

---

## 5. Generated Project Structure

```
my-saas-app/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   ├── signup/
│   │   └── forgot-password/
│   ├── (dashboard)/
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── api/
│   │   ├── auth/
│   │   │   └── [...nextauth]/
│   │   ├── stripe/
│   │   │   ├── webhooks/
│   │   │   └── checkout/
│   │   └── email/
│   ├── layout.tsx
│   ├── page.tsx
│   └── globals.css
├── components/
│   ├── ui/                   # Reusable UI components
│   ├── auth/                 # Auth components
│   ├── pricing/              # Pricing components
│   └── email/                # Email templates
├── lib/
│   ├── supabase/             # Supabase client
│   ├── stripe/               # Stripe client
│   ├── resend/               # Resend client
│   └── utils.ts
├── hooks/                    # Custom React hooks
├── types/                    # TypeScript types
├── public/
├── .env.example
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

---

## 6. Environment Variables

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

# Stripe
STRIPE_SECRET_KEY=sk_test_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

# Resend
RESEND_API_KEY=re_...

# App
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_APP_NAME=My SaaS
```

---

## 7. Implementation Phases

### Phase 1: Core CLI (Week 1)
- Project initialization
- Template generation
- Basic file scaffolding

### Phase 2: Services Integration (Week 2)
- Supabase integration
- Stripe integration
- Resend integration

### Phase 3: Deployment (Week 3)
- Vercel deployment
- Environment setup
- CI/CD pipeline

### Phase 4: Polish (Week 4)
- Error handling
- Updates
- Documentation

---

## 8. Service Details

### Supabase
- Auth (Email + Social)
- PostgreSQL Database
- Row Level Security (RLS)
- Auto-generated types

### Stripe
- Subscription management
- Checkout sessions
- Customer portal
- Webhook handling
- Tax calculation

### Resend
- Transactional emails
- React Email templates
- Welcome emails
- Password reset
- Payment receipts

### Vercel
- Zero-config deployment
- Preview deployments
- Environment variables
- Custom domains

### Cloudflare
- Domain management
- DNS configuration
- SSL/TLS
- Page rules

---

## 9. Future Considerations

These can be added later:
- Additional auth providers (Firebase, Auth0, Clerk)
- Database alternatives (MySQL, MongoDB, Redis)
- Analytics (PostHog, Mixpanel)
- Error tracking (Sentry)
- Storage (S3, Cloudinary)
- SMS (Twilio)

---

## 10. License

MIT
