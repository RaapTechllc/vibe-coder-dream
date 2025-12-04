<p align="center">
  <img src="https://img.shields.io/badge/Next.js-14-black?style=for-the-badge&logo=next.js" alt="Next.js 14" />
  <img src="https://img.shields.io/badge/TypeScript-5-blue?style=for-the-badge&logo=typescript" alt="TypeScript" />
  <img src="https://img.shields.io/badge/Convex-Real--time-orange?style=for-the-badge" alt="Convex" />
  <img src="https://img.shields.io/badge/Clerk-Auth-purple?style=for-the-badge" alt="Clerk" />
  <img src="https://img.shields.io/badge/shadcn%2Fui-Components-black?style=for-the-badge" alt="shadcn/ui" />
</p>

<h1 align="center">Vibe Coder's Dream</h1>

<p align="center">
  <strong>The AI-Native Dev Platform That Ships While You Sleep</strong>
</p>

> [!IMPORTANT]
> **Stop configuring. Start shipping.**
> Most boilerplates give you code. This one gives you a workflow.

---

## The Problem: "The Setup Tax"

You have an idea. You want to build it.

But before you write a single line of unique logic, you spend 3 days:
- Configuring Clerk authentication
- Setting up a database schema
- Wrestling with TypeScript errors
- Glueing together UI components

By the time you're ready to build, the vibe is gone.

---

## The Solution: Be The Architect, Not The Plumber

**Vibe Coder's Dream** is an opinionated, self-healing development environment designed specifically for **Claude Code**.

It's not just a template. It's a **force multiplier** that turns you from a "coder" into an "architect."

### The Stack

| Technology | Why We Use It |
|------------|---------------|
| **Next.js 14** | Server components, file routing, API routes |
| **Clerk** | Auth in 5 minutes, user management included |
| **Convex** | Real-time database, type-safe, serverless |
| **shadcn/ui** | Beautiful components you own |
| **Custom AI Agents** | That know how to use this stack |

---

## The Mechanism: Why It Works

This isn't just a collection of files. It's a **System of Intelligence**.

We've taught Claude how to use this stack. When you say "build a blog," Claude doesn't guess. It uses pre-defined **Skills** to:

1. **Scaffold** the database schema (using Convex patterns)
2. **Generate** the UI (using shadcn components)
3. **Wire** the data (using real-time hooks)
4. **Protect** the routes (using Clerk middleware)

**The Result?** Features that used to take days now take minutes.

---

## Quick Start

### Option 1: Speed Run (Recommended)

```bash
git clone https://github.com/RaapTechllc/vibe-coder-dream.git
cd vibe-coder-dream
bash setup.sh my-app
```

### Option 2: Manual Setup

```bash
# 1. Clone & Install
git clone https://github.com/RaapTechllc/vibe-coder-dream.git
cd vibe-coder-dream
npm install

# 2. Add Secrets
cp .env.example .env.local
# Add your Clerk & Convex keys

# 3. Launch (two terminals)
npm run dev        # Terminal 1
npx convex dev     # Terminal 2
```

---

## AI Command Center

Once you're running, you have a team of agents at your fingertips.

| Command | What It Does | The Vibe |
|:--------|:-------------|:---------|
| `/vibe [feature]` | Builds a full-stack feature from scratch | "I need a blog system." |
| `/fix [issue]` | Debugs and self-heals errors | "Why isn't auth working?" |
| `/style [page]` | Polishes UI to look premium | "Make this look like Apple." |
| `/ship` | Prepares for production deployment | "Let's go live." |

### Real Example

```bash
> /vibe Create a project dashboard where users can create 'spaces' and invite members.
```

**Claude's Output:**
- Schema: Created `spaces` table in Convex
- UI: Created `dashboard/page.tsx` with shadcn cards
- Data: Wired up `useQuery` for real-time updates
- Feature: Added "Invite Member" dialog

**Time elapsed: 4 minutes.**

---

## Agent Features (v2.1)

| Feature | What It Does |
|---------|--------------|
| **Handoff Validation** | Agents validate context before starting |
| **Conflict Detection** | Prevents file conflicts between parallel jobs |
| **Self-Healing** | Errors improve the boilerplate for future projects |
| **Timeout Policies** | Graceful degradation on long-running tasks |
| **Retry Logic** | Automatic recovery from transient failures |

---

## Why Founders Choose This

- **Zero Friction**: From `git clone` to `localhost:3000` in < 2 minutes
- **Type Safety**: End-to-end type safety from DB to UI. No more `any`
- **Self-Healing**: The `/fix` agent understands the stack and fixes its own bugs
- **Production Ready**: This isn't a toy. It scales to millions of users on Vercel + Convex

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
│   │   └── features/        # Feature components
│   └── lib/                 # Utilities
├── convex/
│   ├── schema.ts            # Database schema
│   ├── functions/           # Queries & mutations
│   └── http.ts              # Webhooks
└── skills/                  # Reusable AI patterns
```

---

## Environment Variables

Create `.env.local`:

```bash
# Clerk (from https://dashboard.clerk.com)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
CLERK_WEBHOOK_SECRET=whsec_...

# Clerk URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up

# Convex (auto-filled by npx convex dev)
NEXT_PUBLIC_CONVEX_URL=
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [CLAUDE.md](./CLAUDE.md) | Coding patterns and conventions |
| [cloud.md](./cloud.md) | AI orchestration + self-healing protocol |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Common issues and fixes |
| [CONTRIBUTING.md](./CONTRIBUTING.md) | Contribution guidelines |

### Skills Reference

| Skill | Use Case |
|-------|----------|
| [convex-crud](./skills/convex-crud/) | Database operations |
| [shadcn-forms](./skills/shadcn-forms/) | Form patterns |
| [clerk-auth](./skills/clerk-auth/) | Authentication |
| [realtime-sync](./skills/realtime-sync/) | Real-time features |

---

## Contributing

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for guidelines.

---

## License

MIT License - see [LICENSE](./LICENSE) for details.

---

<p align="center">
  <strong>Ready to dream?</strong><br/>
  <sub>Stop configuring. Start shipping.</sub>
</p>

<p align="center">
  <a href="https://github.com/RaapTechllc/vibe-coder-dream">Clone the Repo</a> and start building.
</p>

<p align="center">
  <sub>Version 2.1 | December 2025</sub>
</p>
