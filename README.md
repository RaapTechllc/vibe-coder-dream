<p align="center">
  <img src="https://img.shields.io/badge/Next.js-14-black?style=for-the-badge&logo=next.js" alt="Next.js 14" />
  <img src="https://img.shields.io/badge/TypeScript-5-blue?style=for-the-badge&logo=typescript" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Convex-Real--time-orange?style=for-the-badge" alt="Convex" />
  <img src="https://img.shields.io/badge/Clerk-Auth-purple?style=for-the-badge" alt="Clerk" />
  <img src="https://img.shields.io/badge/shadcn%2Fui-Components-black?style=for-the-badge" alt="shadcn/ui" />
</p>

<h1 align="center">Vibe Coder's Dream</h1>

<p align="center">
  <strong>Ship fast. Stay type-safe. Zero friction.</strong>
</p>

<p align="center">
  The ultimate boilerplate for AI-assisted development with Claude Code.<br/>
  Complete features in minutes, not hours.
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> •
  <a href="#-features">Features</a> •
  <a href="#-ai-commands">AI Commands</a> •
  <a href="#-documentation">Documentation</a> •
  <a href="#-contributing">Contributing</a>
</p>

---

## Why This Exists

Building modern web apps shouldn't be slow. But configuring auth, databases, real-time sync, and UI components takes forever.

**Vibe Coder's Dream** gives you:
- **Production-ready stack** configured and integrated
- **AI agent orchestration** for Claude Code
- **Reusable patterns** for common features
- **One command** to go from idea to deployed feature

```bash
# Instead of hours of setup...
/vibe user can create and view blog posts

# 8 minutes later: Working feature with real-time updates, auth, and beautiful UI
```

---

## Quick Start

### Option 1: Setup Script (Recommended)

```bash
git clone https://github.com/your-username/vibe-coder-dream.git
cd vibe-coder-dream
bash setup.sh my-app
```

### Option 2: Manual Setup

```bash
# 1. Create Next.js app
npx create-next-app@latest my-app --typescript --tailwind --eslint --app --src-dir

# 2. Install dependencies
cd my-app
npm install @clerk/nextjs convex sonner lucide-react svix
npx shadcn@latest init
npx shadcn@latest add button input textarea label card skeleton dialog

# 3. Copy configuration files from this repo
# 4. Add your API keys to .env.local
```

### After Setup

```bash
# Terminal 1: Start Next.js
npm run dev

# Terminal 2: Start Convex
npx convex dev

# Visit http://localhost:3000
```

---

## Features

### The Stack

| Technology | Why We Use It |
|------------|---------------|
| **Next.js 14** | Server components, file routing, API routes |
| **shadcn/ui** | Beautiful components you own |
| **Clerk** | Auth in 5 minutes |
| **Convex** | Real-time database with TypeScript |
| **Tailwind CSS** | Utility-first styling |

### What You Get

- **Authentication** - Sign up, sign in, user management (Clerk)
- **Database** - Real-time sync, type-safe queries (Convex)
- **UI Components** - 20+ shadcn components pre-installed
- **AI Orchestration** - 4 specialized agents for different tasks
- **Code Patterns** - Production-tested patterns for common features

---

## AI Commands

Use these commands with Claude Code:

| Command | What It Does |
|---------|--------------|
| `/vibe [feature]` | Build a complete feature fast |
| `/fix [issue]` | Debug and fix bugs surgically |
| `/style [component]` | Make components beautiful |
| `/ship` | Deploy to production |

### Example Usage

```bash
# Build a blog
/vibe blog with posts and comments

# Fix authentication
/fix user not redirecting after login

# Style the dashboard
/style dashboard cards

# Deploy everything
/ship
```

### Agent Features (v2.1)

- **Handoff Validation** - Agents validate context before starting
- **Conflict Detection** - Prevents file conflicts between parallel jobs
- **Timeout Policies** - Graceful degradation on long-running tasks
- **Retry Logic** - Automatic recovery from transient failures

---

## Project Structure

```
my-app/
├── src/
│   ├── app/                 # Next.js pages
│   │   ├── (auth)/          # Auth pages (sign-in, sign-up)
│   │   ├── (dashboard)/     # Protected pages
│   │   └── layout.tsx       # Root layout
│   ├── components/
│   │   ├── ui/              # shadcn components
│   │   ├── features/        # Feature components
│   │   └── providers/       # Context providers
│   └── lib/                 # Utilities
├── convex/
│   ├── schema.ts            # Database schema
│   ├── functions/           # Queries & mutations
│   └── http.ts              # Webhooks
├── .claude/                 # AI agent configs
│   └── agents/              # Agent definitions
└── skills/                  # Reusable patterns
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [CLAUDE.md](./CLAUDE.md) | Complete coding patterns and conventions |
| [cloud.md](./cloud.md) | AI orchestration settings |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Common issues and fixes |
| [CHANGELOG.md](./CHANGELOG.md) | Version history |

### Skills Reference

| Skill | Use Case |
|-------|----------|
| [convex-crud](./skills/convex-crud/) | Database operations |
| [shadcn-forms](./skills/shadcn-forms/) | Form patterns |
| [clerk-auth](./skills/clerk-auth/) | Authentication |
| [realtime-sync](./skills/realtime-sync/) | Real-time features |

### External Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Convex Documentation](https://docs.convex.dev)
- [Clerk Documentation](https://clerk.com/docs)
- [shadcn/ui Documentation](https://ui.shadcn.com)

---

## Environment Variables

Create `.env.local` with:

```bash
# Clerk (from https://dashboard.clerk.com)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
CLERK_WEBHOOK_SECRET=whsec_...

# Clerk URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# Convex (auto-filled by npx convex dev)
NEXT_PUBLIC_CONVEX_URL=
```

---

## Setting Up Clerk Webhook

1. Go to [Clerk Dashboard](https://dashboard.clerk.com) → Webhooks
2. Add endpoint: `https://your-convex.convex.site/clerk-webhook`
3. Select events: `user.created`, `user.updated`, `user.deleted`
4. Copy signing secret
5. Add to Convex: `npx convex env set CLERK_WEBHOOK_SECRET whsec_...`

---

## Common Commands

```bash
# Development
npm run dev              # Start Next.js
npx convex dev           # Start Convex

# Type checking
npm run typecheck        # Check TypeScript
npm run lint             # Run ESLint

# Deployment
npm run deploy           # Deploy Convex + Vercel
npx convex deploy        # Deploy Convex only
vercel --prod            # Deploy Vercel only
```

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

---

## License

MIT License - see [LICENSE](./LICENSE) for details.

---

## Acknowledgments

Built with:
- [Next.js](https://nextjs.org) by Vercel
- [shadcn/ui](https://ui.shadcn.com) by shadcn
- [Clerk](https://clerk.com) for authentication
- [Convex](https://convex.dev) for the backend

---

<p align="center">
  <strong>Built for Vibe Coders</strong><br/>
  <sub>Ship fast. Stay type-safe. Zero friction.</sub>
</p>

<p align="center">
  <sub>Version 2.1 | December 2025</sub>
</p>
