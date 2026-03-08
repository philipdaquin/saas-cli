# saas-cli

Build production-ready SaaS apps in seconds.

## Installation

```bash
git clone https://github.com/philipdaquin/saas-cli.git
cd saas-cli
swift build -c release
```

## Usage

```bash
# Run the CLI
swift run saas-cli --help

# Or after building
./build/release/saas-cli --help
```

## Quick Start

```bash
# Create a new SaaS project
saas-cli new my-saas-app

# Navigate to project
cd my-saas-app

# Install dependencies
npm install

# Start development server
npm run dev
```

## Commands

| Command | Description |
|---------|-------------|
| `new <name>` | Create new SaaS project |
| `add <service>` | Add a service |
| `list` | List available services |
| `doctor` | Diagnose issues |

## What's Included

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS
- Supabase (Auth + Database)
- Stripe (Payments)
- Resend (Email)

## License

MIT
