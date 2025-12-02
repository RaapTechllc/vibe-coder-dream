# Clerk Auth Skill

**Purpose**: Complete authentication patterns with Clerk and Convex  
**Triggers**: "auth", "login", "signup", "user", "protected", "middleware"

---

## Initial Setup

### 1. Install Dependencies

```bash
npm install @clerk/nextjs
```

### 2. Environment Variables

```bash
# .env.local

# From Clerk Dashboard → API Keys
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...

# Optional: Webhook secret (for user sync)
CLERK_WEBHOOK_SECRET=whsec_...

# Auth URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard
```

### 3. Root Layout Provider

```typescript
// app/layout.tsx
import { ClerkProvider } from '@clerk/nextjs';
import { ConvexClientProvider } from '@/components/providers/convex-provider';

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider>
      <html lang="en">
        <body>
          <ConvexClientProvider>{children}</ConvexClientProvider>
        </body>
      </html>
    </ClerkProvider>
  );
}
```

### 4. Convex Provider with Clerk Auth

```typescript
// components/providers/convex-provider.tsx
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
```

---

## Middleware (Route Protection)

```typescript
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

// Define public routes (no auth required)
const isPublicRoute = createRouteMatcher([
  '/',
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/webhooks(.*)',
]);

export default clerkMiddleware(async (auth, request) => {
  // If not public route, require auth
  if (!isPublicRoute(request)) {
    await auth.protect();
  }
});

export const config = {
  matcher: [
    // Skip Next.js internals and static files
    '/((?!_next|[^?]*\\.(?:html?|css|js(?!on)|jpe?g|webp|png|gif|svg|ttf|woff2?|ico|csv|docx?|xlsx?|zip|webmanifest)).*)',
    // Always run for API routes
    '/(api|trpc)(.*)',
  ],
};
```

---

## Auth Pages

### Sign In Page

```typescript
// app/sign-in/[[...sign-in]]/page.tsx
import { SignIn } from '@clerk/nextjs';

export default function SignInPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <SignIn
        appearance={{
          elements: {
            formButtonPrimary:
              'bg-primary text-primary-foreground hover:bg-primary/90',
            card: 'shadow-none',
          },
        }}
      />
    </div>
  );
}
```

### Sign Up Page

```typescript
// app/sign-up/[[...sign-up]]/page.tsx
import { SignUp } from '@clerk/nextjs';

export default function SignUpPage() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-background">
      <SignUp
        appearance={{
          elements: {
            formButtonPrimary:
              'bg-primary text-primary-foreground hover:bg-primary/90',
            card: 'shadow-none',
          },
        }}
      />
    </div>
  );
}
```

---

## User Components

### User Button (Profile Menu)

```typescript
// components/user-button.tsx
import { UserButton as ClerkUserButton } from '@clerk/nextjs';

export function UserButton() {
  return (
    <ClerkUserButton
      afterSignOutUrl="/"
      appearance={{
        elements: {
          avatarBox: 'h-8 w-8',
        },
      }}
    />
  );
}
```

### Custom User Menu

```typescript
// components/user-menu.tsx
'use client';

import { useUser, useClerk } from '@clerk/nextjs';
import { useRouter } from 'next/navigation';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { LogOut, Settings, User } from 'lucide-react';

export function UserMenu() {
  const { user } = useUser();
  const { signOut } = useClerk();
  const router = useRouter();

  if (!user) return null;

  const initials = user.firstName?.[0] ?? user.emailAddresses[0]?.emailAddress[0] ?? '?';

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button className="rounded-full">
          <Avatar className="h-8 w-8">
            <AvatarImage src={user.imageUrl} alt={user.fullName ?? ''} />
            <AvatarFallback>{initials.toUpperCase()}</AvatarFallback>
          </Avatar>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-56">
        <DropdownMenuLabel>
          <div className="flex flex-col">
            <span className="font-medium">{user.fullName}</span>
            <span className="text-xs text-muted-foreground">
              {user.emailAddresses[0]?.emailAddress}
            </span>
          </div>
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => router.push('/settings')}>
          <Settings className="mr-2 h-4 w-4" />
          Settings
        </DropdownMenuItem>
        <DropdownMenuItem onClick={() => router.push('/profile')}>
          <User className="mr-2 h-4 w-4" />
          Profile
        </DropdownMenuItem>
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => signOut()}>
          <LogOut className="mr-2 h-4 w-4" />
          Sign out
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

### Auth Guard Component

```typescript
// components/auth-guard.tsx
'use client';

import { useAuth } from '@clerk/nextjs';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

interface AuthGuardProps {
  children: React.ReactNode;
  fallback?: React.ReactNode;
}

export function AuthGuard({ children, fallback }: AuthGuardProps) {
  const { isLoaded, isSignedIn } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (isLoaded && !isSignedIn) {
      router.push('/sign-in');
    }
  }, [isLoaded, isSignedIn, router]);

  if (!isLoaded) {
    return fallback ?? <Skeleton className="h-screen w-full" />;
  }

  if (!isSignedIn) {
    return null;
  }

  return <>{children}</>;
}
```

---

## Webhook for User Sync

### Convex HTTP Handler

```typescript
// convex/http.ts
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

    const eventType = evt.type;
    const { id, email_addresses, first_name, last_name, image_url } = evt.data;

    const email = email_addresses?.[0]?.email_address ?? '';
    const name = `${first_name ?? ''} ${last_name ?? ''}`.trim() || 'Unknown';

    switch (eventType) {
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
```

### User Functions (Internal)

```typescript
// convex/functions/users.ts
import { internalMutation, query } from '../_generated/server';
import { v } from 'convex/values';

// Called by webhook
export const createUser = internalMutation({
  args: {
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    imageUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // Check if already exists
    const existing = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', args.clerkId))
      .unique();

    if (existing) return existing._id;

    const now = Date.now();
    return ctx.db.insert('users', {
      clerkId: args.clerkId,
      email: args.email,
      name: args.name,
      imageUrl: args.imageUrl,
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

    // Delete user's data first (posts, etc.)
    const posts = await ctx.db
      .query('posts')
      .withIndex('by_userId', (q) => q.eq('userId', user._id))
      .collect();

    for (const post of posts) {
      await ctx.db.delete(post._id);
    }

    await ctx.db.delete(user._id);
  },
});

// Query for current user
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
```

---

## Auth Patterns in Components

### Check Auth in Component

```typescript
'use client';

import { useAuth, useUser } from '@clerk/nextjs';

export function MyComponent() {
  const { isLoaded, isSignedIn } = useAuth();
  const { user } = useUser();

  if (!isLoaded) {
    return <div>Loading...</div>;
  }

  if (!isSignedIn) {
    return <div>Please sign in</div>;
  }

  return <div>Hello, {user?.firstName}!</div>;
}
```

### Get User in Convex Query

```typescript
export const getMyData = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    
    if (!identity) {
      return []; // Not signed in
    }

    // identity.subject is the Clerk user ID
    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) {
      return []; // User not synced yet
    }

    // Now query user's data
    return ctx.db
      .query('posts')
      .withIndex('by_userId', (q) => q.eq('userId', user._id))
      .collect();
  },
});
```

### Require Auth in Mutation

```typescript
export const createPost = mutation({
  args: { title: v.string() },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    
    if (!identity) {
      throw new Error('Not authenticated');
    }

    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) {
      throw new Error('User not found');
    }

    // Create the post
    return ctx.db.insert('posts', {
      userId: user._id,
      title: args.title,
      createdAt: Date.now(),
      updatedAt: Date.now(),
    });
  },
});
```

---

## Common Issues

### "User not found" after signup

**Cause**: Webhook hasn't synced user yet  
**Fix**: Add loading state or retry logic

```typescript
const user = useQuery(api.functions.users.getCurrentUser);

if (user === undefined) {
  return <div>Setting up your account...</div>;
}

if (user === null) {
  return <div>Account setup in progress...</div>;
}
```

### Redirect loop on protected routes

**Cause**: Middleware matching wrong routes  
**Fix**: Check `isPublicRoute` matcher includes auth pages

### Auth not working in Convex

**Cause**: Missing ConvexProviderWithClerk
**Fix**: Use ConvexProviderWithClerk instead of ConvexProvider

---

## Role-Based Access Control (RBAC)

### Schema with Roles

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from 'convex/server';
import { v } from 'convex/values';

export default defineSchema({
  users: defineTable({
    clerkId: v.string(),
    email: v.string(),
    name: v.string(),
    imageUrl: v.optional(v.string()),
    role: v.union(
      v.literal('user'),
      v.literal('admin'),
      v.literal('moderator')
    ),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index('by_clerkId', ['clerkId'])
    .index('by_email', ['email'])
    .index('by_role', ['role']),

  // For more complex permissions
  permissions: defineTable({
    userId: v.id('users'),
    resource: v.string(),  // e.g., 'posts', 'users', 'settings'
    actions: v.array(v.string()),  // e.g., ['read', 'write', 'delete']
  })
    .index('by_userId', ['userId'])
    .index('by_resource', ['resource']),
});
```

### Auth Helper Functions

```typescript
// convex/lib/auth.ts
import { QueryCtx, MutationCtx } from '../_generated/server';

export type Role = 'user' | 'admin' | 'moderator';

export async function getCurrentUser(ctx: QueryCtx | MutationCtx) {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) return null;

  return ctx.db
    .query('users')
    .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
    .unique();
}

export async function requireAuth(ctx: QueryCtx | MutationCtx) {
  const user = await getCurrentUser(ctx);
  if (!user) {
    throw new Error('Not authenticated');
  }
  return user;
}

export async function requireRole(
  ctx: QueryCtx | MutationCtx,
  allowedRoles: Role[]
) {
  const user = await requireAuth(ctx);
  if (!allowedRoles.includes(user.role)) {
    throw new Error('Insufficient permissions');
  }
  return user;
}

export async function requireAdmin(ctx: QueryCtx | MutationCtx) {
  return requireRole(ctx, ['admin']);
}

export async function requireModerator(ctx: QueryCtx | MutationCtx) {
  return requireRole(ctx, ['admin', 'moderator']);
}
```

### Using Role Checks in Functions

```typescript
// convex/functions/admin.ts
import { mutation, query } from '../_generated/server';
import { v } from 'convex/values';
import { requireAdmin, requireModerator } from '../lib/auth';

// Admin only
export const deleteUser = mutation({
  args: { userId: v.id('users') },
  handler: async (ctx, args) => {
    await requireAdmin(ctx);
    await ctx.db.delete(args.userId);
  },
});

// Admin or moderator
export const banUser = mutation({
  args: { userId: v.id('users') },
  handler: async (ctx, args) => {
    await requireModerator(ctx);
    await ctx.db.patch(args.userId, { banned: true });
  },
});

// Get all users (admin only)
export const getAllUsers = query({
  args: {},
  handler: async (ctx) => {
    await requireAdmin(ctx);
    return ctx.db.query('users').collect();
  },
});
```

### React Components with Role Checks

```typescript
// components/admin-guard.tsx
'use client';

import { useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { ReactNode } from 'react';

interface RoleGuardProps {
  children: ReactNode;
  allowedRoles: ('user' | 'admin' | 'moderator')[];
  fallback?: ReactNode;
}

export function RoleGuard({ children, allowedRoles, fallback }: RoleGuardProps) {
  const user = useQuery(api.functions.users.getCurrentUser);

  // Loading
  if (user === undefined) {
    return null;
  }

  // Not authenticated or wrong role
  if (!user || !allowedRoles.includes(user.role)) {
    return fallback ?? null;
  }

  return <>{children}</>;
}

// Usage
function AdminPanel() {
  return (
    <RoleGuard allowedRoles={['admin']} fallback={<p>Access denied</p>}>
      <h1>Admin Panel</h1>
      {/* Admin content */}
    </RoleGuard>
  );
}
```

### Middleware with Role Protection

```typescript
// middleware.ts
import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isPublicRoute = createRouteMatcher([
  '/',
  '/sign-in(.*)',
  '/sign-up(.*)',
  '/api/webhooks(.*)',
]);

const isAdminRoute = createRouteMatcher([
  '/admin(.*)',
]);

export default clerkMiddleware(async (auth, request) => {
  if (!isPublicRoute(request)) {
    await auth.protect();
  }

  // Note: For admin routes, you'd typically check the role
  // in the page component or layout since Clerk middleware
  // doesn't have access to your database roles.
  // Use a layout-level check for admin routes.
});
```

### Admin Layout with Server-Side Check

```typescript
// app/admin/layout.tsx
import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';
import { ConvexHttpClient } from 'convex/browser';
import { api } from '@/convex/_generated/api';

const convex = new ConvexHttpClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export default async function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { userId } = await auth();

  if (!userId) {
    redirect('/sign-in');
  }

  // For server-side role check, you'd need to query Convex
  // Note: This is a simplified example. In production,
  // consider caching this or using Clerk's session claims.

  return (
    <div className="admin-layout">
      {children}
    </div>
  );
}
```

### Setting User Roles

```typescript
// convex/functions/users.ts
import { internalMutation, mutation } from '../_generated/server';
import { v } from 'convex/values';
import { requireAdmin } from '../lib/auth';

// Only admins can change roles
export const setUserRole = mutation({
  args: {
    userId: v.id('users'),
    role: v.union(v.literal('user'), v.literal('admin'), v.literal('moderator')),
  },
  handler: async (ctx, args) => {
    const admin = await requireAdmin(ctx);

    // Prevent removing your own admin role
    if (args.userId === admin._id && args.role !== 'admin') {
      throw new Error('Cannot remove your own admin role');
    }

    await ctx.db.patch(args.userId, {
      role: args.role,
      updatedAt: Date.now(),
    });
  },
});

// Set first user as admin (called from webhook)
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

    // Check if this is the first user
    const userCount = await ctx.db.query('users').collect();
    const isFirstUser = userCount.length === 0;

    const now = Date.now();
    return ctx.db.insert('users', {
      ...args,
      role: isFirstUser ? 'admin' : 'user',
      createdAt: now,
      updatedAt: now,
    });
  },
});
```

---

## Best Practices

### Always Do

- Use middleware for route protection
- Sync users via webhook
- Check auth in mutations
- Handle loading states
- Use proper Convex provider
- Check roles server-side (in Convex functions)
- Use helper functions for auth checks

### Never Do

- Store passwords (Clerk handles this)
- Trust client-side auth alone
- Skip webhook verification
- Forget to index clerkId
- Check roles only on client (can be bypassed)
- Allow users to set their own role

---

*Auth done right. Fast and secure.*
