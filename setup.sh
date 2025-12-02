#!/bin/bash

# Vibe Coder Dream Setup Script
# Version: 2.0
# Run with: bash setup.sh [project-name]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress tracking
CURRENT_STEP=0
TOTAL_STEPS=9

# Save script directory for copying files later
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print functions
print_header() {
  echo ""
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}   Vibe Coder Dream Setup v2.0${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
}

print_step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  echo ""
  echo -e "${BLUE}[$CURRENT_STEP/$TOTAL_STEPS]${NC} ${GREEN}$1${NC}"
  echo -e "${BLUE}────────────────────────────────────────${NC}"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_info() {
  echo -e "${CYAN}ℹ${NC} $1"
}

# Error handler
handle_error() {
  print_error "An error occurred on line $1"
  print_error "Setup failed. Please check the error above and try again."
  exit 1
}

trap 'handle_error $LINENO' ERR

# Check Node.js version
check_node_version() {
  local required_major=18
  local node_version=$(node -v 2>/dev/null | sed 's/v//' | cut -d. -f1)

  if [ -z "$node_version" ]; then
    print_error "Node.js is not installed"
    print_info "Install Node.js 18+ from https://nodejs.org"
    exit 1
  fi

  if [ "$node_version" -lt "$required_major" ]; then
    print_error "Node.js $required_major+ required. Found: v$node_version"
    print_info "Update Node.js from https://nodejs.org"
    exit 1
  fi

  print_success "Node.js v$(node -v | sed 's/v//') found"
}

# Check all requirements
check_requirements() {
  print_step "Checking requirements"

  # Node.js
  check_node_version

  # npm
  if ! command -v npm &> /dev/null; then
    print_error "npm not found. Install Node.js from https://nodejs.org"
    exit 1
  fi
  print_success "npm v$(npm -v) found"

  # git
  if ! command -v git &> /dev/null; then
    print_error "git not found. Install from https://git-scm.com"
    exit 1
  fi
  print_success "git v$(git --version | cut -d' ' -f3) found"

  # Check disk space (need at least 500MB)
  local available_space
  available_space=$(df -m . 2>/dev/null | awk 'NR==2 {print $4}' || true)
  available_space=${available_space:-1000}
  if [ "$available_space" -lt 500 ]; then
    print_warning "Low disk space: ${available_space}MB available (500MB+ recommended)"
  fi

  print_success "All requirements met"
}

# Get project name
get_project_name() {
  if [ -z "$1" ]; then
    echo ""
    read -p "Project name (lowercase, no spaces): " PROJECT_NAME
  else
    PROJECT_NAME=$1
  fi

  # Default name
  if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="my-vibe-app"
  fi

  # Validate project name (lowercase, no spaces, valid npm name)
  if [[ ! "$PROJECT_NAME" =~ ^[a-z][a-z0-9-]*$ ]]; then
    print_error "Invalid project name. Use lowercase letters, numbers, and hyphens only."
    print_info "Example: my-cool-app"
    exit 1
  fi

  # Check if directory exists
  if [ -d "$PROJECT_NAME" ]; then
    print_error "Directory '$PROJECT_NAME' already exists"
    print_info "Choose a different name or remove the existing directory"
    exit 1
  fi

  print_info "Creating project: $PROJECT_NAME"
}

# Create Next.js app
create_nextjs_app() {
  print_step "Creating Next.js app"

  print_info "This may take a minute..."

  # Create Next.js app with all options
  npx create-next-app@latest "$PROJECT_NAME" \
    --typescript \
    --tailwind \
    --eslint \
    --app \
    --src-dir \
    --import-alias "@/*" \
    --no-git \
    --use-npm

  cd "$PROJECT_NAME"

  print_success "Next.js app created"
}

# Install dependencies
install_dependencies() {
  print_step "Installing dependencies"

  print_info "Installing core packages..."
  npm install @clerk/nextjs convex sonner lucide-react svix --save
  print_success "Core packages installed"

  print_info "Setting up shadcn/ui..."

  # Create components.json for shadcn
  cat > components.json << 'EOF'
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "default",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "src/app/globals.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils"
  }
}
EOF

  # Create utils file for shadcn
  mkdir -p src/lib
  cat > src/lib/utils.ts << 'EOF'
import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
EOF

  # Install shadcn dependencies
  npm install class-variance-authority clsx tailwind-merge tailwindcss-animate --save

  # Install shadcn components
  print_info "Adding shadcn components..."
  npx shadcn@latest add button input textarea label card skeleton dialog alert-dialog dropdown-menu avatar tabs select switch scroll-area tooltip badge table --yes 2>/dev/null || npx shadcn-ui@latest add button input textarea label card skeleton dialog alert-dialog dropdown-menu avatar tabs select switch scroll-area tooltip badge table -y 2>/dev/null || print_warning "Some shadcn components may need manual installation"

  print_success "shadcn/ui installed"
}

# Create folder structure
create_structure() {
  print_step "Creating project structure"

  # AI config directories
  mkdir -p .claude/agents
  mkdir -p skills/{convex-crud,shadcn-forms,clerk-auth,realtime-sync}

  # App structure
  mkdir -p "src/app/(auth)/sign-in/[[...sign-in]]"
  mkdir -p "src/app/(auth)/sign-up/[[...sign-up]]"
  mkdir -p "src/app/(dashboard)/dashboard"
  mkdir -p src/components/providers
  mkdir -p src/components/features
  mkdir -p convex/functions

  print_success "Folder structure created"
}

# Create boilerplate files
create_files() {
  print_step "Creating boilerplate files"

  # Environment template
  cat > .env.local << 'EOF'
# Clerk Authentication
# Get keys from: https://dashboard.clerk.com
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=
CLERK_SECRET_KEY=
CLERK_WEBHOOK_SECRET=

# Clerk URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# Convex (auto-filled by npx convex dev)
NEXT_PUBLIC_CONVEX_URL=
EOF
  print_success "Created .env.local"

  # Middleware
  cat > src/middleware.ts << 'EOF'
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isPublicRoute = createRouteMatcher([
  '/',
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/webhooks(.*)',
]);

export default clerkMiddleware(async (auth, request) => {
  if (!isPublicRoute(request)) {
    await auth.protect();
  }
});

export const config = {
  matcher: [
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    '/(api|trpc)(.*)',
  ],
};
EOF
  print_success "Created middleware.ts"

  # Convex Provider
  cat > src/components/providers/convex-provider.tsx << 'EOF'
'use client';

import { ReactNode } from 'react';
import { ConvexReactClient } from 'convex/react';
import { ConvexProviderWithClerk } from 'convex/react-clerk';
import { useAuth } from '@clerk/nextjs';

const convex = new ConvexReactClient(
  process.env.NEXT_PUBLIC_CONVEX_URL as string
);

export function ConvexClientProvider({ children }: { children: ReactNode }) {
  return (
    <ConvexProviderWithClerk client={convex} useAuth={useAuth}>
      {children}
    </ConvexProviderWithClerk>
  );
}
EOF
  print_success "Created convex-provider.tsx"

  # Root Layout
  cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ClerkProvider } from '@clerk/nextjs';
import { ConvexClientProvider } from '@/components/providers/convex-provider';
import { Toaster } from 'sonner';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'My Vibe App',
  description: 'Built with the Vibe Coder Dream setup',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body className={inter.className}>
          <ConvexClientProvider>
            {children}
            <Toaster position="bottom-right" />
          </ConvexClientProvider>
        </body>
      </html>
    </ClerkProvider>
  );
}
EOF
  print_success "Created layout.tsx"

  # Sign In Page
  cat > "src/app/(auth)/sign-in/[[...sign-in]]/page.tsx" << 'EOF'
import { SignIn } from '@clerk/nextjs';

export default function SignInPage() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <SignIn />
    </div>
  );
}
EOF
  print_success "Created sign-in page"

  # Sign Up Page
  cat > "src/app/(auth)/sign-up/[[...sign-up]]/page.tsx" << 'EOF'
import { SignUp } from '@clerk/nextjs';

export default function SignUpPage() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <SignUp />
    </div>
  );
}
EOF
  print_success "Created sign-up page"

  # Dashboard Page
  cat > "src/app/(dashboard)/dashboard/page.tsx" << 'EOF'
import { UserButton } from '@clerk/nextjs';

export default function DashboardPage() {
  return (
    <div className="min-h-screen p-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex items-center justify-between mb-8">
          <h1 className="text-3xl font-bold">Dashboard</h1>
          <UserButton afterSignOutUrl="/" />
        </div>
        <div className="bg-card rounded-lg border p-6">
          <p className="text-muted-foreground">
            Welcome! Your app is ready. Start building features.
          </p>
        </div>
      </div>
    </div>
  );
}
EOF
  print_success "Created dashboard page"

  # Home Page
  cat > src/app/page.tsx << 'EOF'
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-8">
      <h1 className="text-4xl font-bold mb-4">Welcome to Your App</h1>
      <p className="text-muted-foreground mb-8">
        Built with Next.js, shadcn/ui, Clerk, and Convex
      </p>
      <div className="flex gap-4">
        <Button asChild>
          <Link href="/sign-up">Get Started</Link>
        </Button>
        <Button variant="outline" asChild>
          <Link href="/sign-in">Sign In</Link>
        </Button>
      </div>
    </div>
  );
}
EOF
  print_success "Created home page"

  # Convex Schema
  cat > convex/schema.ts << 'EOF'
import { defineSchema, defineTable } from 'convex/server';
import { v } from 'convex/values';

export default defineSchema({
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    imageUrl: v.optional(v.string()),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index('by_clerkId', ['clerkId'])
    .index('by_email', ['email']),

  // Add your tables here
  // Example:
  // posts: defineTable({
  //   userId: v.id('users'),
  //   title: v.string(),
  //   content: v.string(),
  //   published: v.boolean(),
  //   createdAt: v.number(),
  //   updatedAt: v.number(),
  // })
  //   .index('by_userId', ['userId']),
});
EOF
  print_success "Created convex/schema.ts"

  # Convex Users Functions
  cat > convex/functions/users.ts << 'EOF'
import { internalMutation, query } from '../_generated/server';
import { v } from 'convex/values';

export const createUser = internalMutation({
  args: {
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    imageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', args.clerkId))
      .unique();

    if (existing) return existing._id;

    const now = Date.now();
    return ctx.db.insert('users', {
      ...args,
      createdAt: now,
      updatedAt: now,
    });
  },
});

export const updateUser = internalMutation({
  args: {
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    imageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', args.clerkId))
      .unique();

    if (!user) return;

    await ctx.db.patch(user._id, {
      email: args.email,
      name: args.name,
      imageUrl: args.imageUrl,
      updatedAt: Date.now(),
    });
  },
});

export const deleteUser = internalMutation({
  args: { clerkId: v.string() },
  handler: async (ctx, args) => {
    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', args.clerkId))
      .unique();

    if (!user) return;
    await ctx.db.delete(user._id);
  },
});

export const getCurrentUser = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return null;

    return ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();
  },
});
EOF
  print_success "Created convex/functions/users.ts"

  # Convex HTTP (Webhook Handler)
  cat > convex/http.ts << 'EOF'
import { httpRouter } from 'convex/server';
import { httpAction } from './_generated/server';
import { Webhook } from 'svix';
import { internal } from './_generated/api';

const http = httpRouter();

http.route({
  path: '/clerk-webhook',
  method: 'POST',
  handler: httpAction(async (ctx, request) => {
    const webhookSecret = process.env.CLERK_WEBHOOK_SECRET;

    if (!webhookSecret) {
      console.error('Missing CLERK_WEBHOOK_SECRET environment variable');
      return new Response('Missing CLERK_WEBHOOK_SECRET', { status: 500 });
    }

    const svix_id = request.headers.get('svix-id');
    const svix_timestamp = request.headers.get('svix-timestamp');
    const svix_signature = request.headers.get('svix-signature');

    if (!svix_id || !svix_timestamp || !svix_signature) {
      return new Response('Missing svix headers', { status: 400 });
    }

    const payload = await request.text();
    const wh = new Webhook(webhookSecret);

    let evt: any;
    try {
      evt = wh.verify(payload, {
        'svix-id': svix_id,
        'svix-timestamp': svix_timestamp,
        'svix-signature': svix_signature,
      });
    } catch (err) {
      console.error('Webhook verification failed:', err);
      return new Response('Invalid signature', { status: 400 });
    }

    const { id, email_addresses, first_name, last_name, image_url } = evt.data;
    const email = email_addresses?.[0]?.email_address ?? '';
    const name = `${first_name ?? ''} ${last_name ?? ''}`.trim() || 'Unknown';

    switch (evt.type) {
      case 'user.created':
        await ctx.runMutation(internal.functions.users.createUser, {
          clerkId: id,
          email,
          name,
          imageUrl: image_url,
        });
        break;
      case 'user.updated':
        await ctx.runMutation(internal.functions.users.updateUser, {
          clerkId: id,
          email,
          name,
          imageUrl: image_url,
        });
        break;
      case 'user.deleted':
        await ctx.runMutation(internal.functions.users.deleteUser, {
          clerkId: id,
        });
        break;
    }

    return new Response('OK', { status: 200 });
  }),
});

export default http;
EOF
  print_success "Created convex/http.ts"

  print_success "All boilerplate files created"
}

# Copy AI configuration files from boilerplate
copy_ai_config() {
  print_step "Copying AI configuration"

  # Copy agents to .claude/agents/
  if [ -d "$SCRIPT_DIR/agents" ]; then
    cp -r "$SCRIPT_DIR/agents/"* .claude/agents/ 2>/dev/null || true
    print_success "Copied agent definitions to .claude/agents/"
  else
    print_warning "No agents directory found in boilerplate"
  fi

  # Copy skills
  if [ -d "$SCRIPT_DIR/skills" ]; then
    for skill_dir in "$SCRIPT_DIR/skills/"*/; do
      skill_name=$(basename "$skill_dir")
      if [ -d "$skill_dir" ] && [ "$(ls -A "$skill_dir" 2>/dev/null)" ]; then
        cp -r "$skill_dir"* "skills/$skill_name/" 2>/dev/null || true
      fi
    done
    print_success "Copied skill patterns to skills/"
  else
    print_warning "No skills directory found in boilerplate"
  fi

  # Copy cloud.md to .claude/ if it exists
  if [ -f "$SCRIPT_DIR/cloud.md" ]; then
    cp "$SCRIPT_DIR/cloud.md" .claude/
    print_success "Copied cloud.md to .claude/"
  fi

  # Copy CLAUDE.md to project root
  if [ -f "$SCRIPT_DIR/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/CLAUDE.md" ./
    print_success "Copied CLAUDE.md to project root"
  fi

  print_success "AI configuration copied"
}

# Initialize Convex
init_convex() {
  print_step "Initializing Convex"

  print_info "Setting up Convex backend..."
  print_info "You may need to log in to Convex if prompted."

  # Run convex dev to generate types (will also set up project if needed)
  if npx convex dev --once --configure=new 2>&1; then
    print_success "Convex initialized and types generated"
  else
    print_warning "Convex initialization needs manual setup"
    print_info "Run 'npx convex dev' after setup to complete Convex configuration"
  fi
}

# Initialize git
init_git() {
  print_step "Initializing Git repository"

  git init --quiet
  git add .
  git commit -m "chore: initial setup with Vibe Coder Dream v2.0" --quiet

  print_success "Git repository initialized with initial commit"
}

# Print next steps
print_next_steps() {
  echo ""
  echo -e "${GREEN}========================================${NC}"
  echo -e "${GREEN}   Setup Complete!${NC}"
  echo -e "${GREEN}========================================${NC}"
  echo ""
  echo -e "${CYAN}Next Steps:${NC}"
  echo ""
  echo -e "  ${YELLOW}1.${NC} Add Clerk keys to .env.local"
  echo -e "     → Get keys from ${BLUE}https://dashboard.clerk.com${NC}"
  echo ""
  echo -e "  ${YELLOW}2.${NC} Start development:"
  echo -e "     ${GREEN}cd $PROJECT_NAME${NC}"
  echo -e "     ${GREEN}npm run dev${NC}        # Terminal 1"
  echo -e "     ${GREEN}npx convex dev${NC}     # Terminal 2"
  echo ""
  echo -e "  ${YELLOW}3.${NC} Set up Clerk webhook (for user sync):"
  echo -e "     → Add endpoint: ${BLUE}https://your-convex.convex.site/clerk-webhook${NC}"
  echo -e "     → Events: user.created, user.updated, user.deleted"
  echo ""
  echo -e "  ${YELLOW}4.${NC} Start building with AI commands:"
  echo -e "     ${GREEN}/vibe [feature]${NC}   → Build complete feature"
  echo -e "     ${GREEN}/fix [issue]${NC}      → Fix a bug"
  echo -e "     ${GREEN}/style [comp]${NC}     → Make it pretty"
  echo -e "     ${GREEN}/ship${NC}             → Deploy to production"
  echo ""
  echo -e "${CYAN}Happy vibing!${NC}"
  echo ""
}

# Main
main() {
  print_header
  check_requirements
  get_project_name "$1"
  create_nextjs_app
  install_dependencies
  create_structure
  create_files
  copy_ai_config
  init_convex
  init_git
  print_next_steps
}

main "$1"
