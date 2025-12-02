# CLAUDE.md - Vibe Coder's Dream Setup

**Stack**: Next.js 14 + shadcn/UI + Clerk + Convex
**Philosophy**: Ship fast. Stay type-safe. Zero friction.
**Version**: 2.0 | December 2025

---

## GETTING STARTED

### Quick Setup (New Project)

```bash
# Clone and run setup script
git clone https://github.com/your-repo/vibe-coder-dream.git
cd vibe-coder-dream
bash setup.sh my-app

# Add your keys to .env.local
# Then start development
cd my-app
npm run dev        # Terminal 1
npx convex dev     # Terminal 2
```

### Requirements

- **Node.js 18+** (check with `node -v`)
- **npm** (comes with Node.js)
- **git** (for version control)
- **Clerk account** (free at https://clerk.com)
- **Convex account** (free at https://convex.dev)

### First-Time Setup Checklist

1. [ ] Run setup script: `bash setup.sh my-app`
2. [ ] Get Clerk keys from https://dashboard.clerk.com
3. [ ] Add keys to `.env.local`
4. [ ] Start Next.js: `npm run dev`
5. [ ] Start Convex: `npx convex dev` (separate terminal)
6. [ ] Visit http://localhost:3000 - you should see the home page
7. [ ] Set up Clerk webhook for user sync (see TROUBLESHOOTING.md)

### Related Documentation

- **[README.md](./README.md)** - Quick reference and commands
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Common issues and fixes
- **[CHANGELOG.md](./CHANGELOG.md)** - Version history and migration guides

---

## THE VIBE

You're building for speed. Not recklessness.

Every decision optimizes for:
1. **Time to working feature** (< 30 min)
2. **Time to production** (< 5 min after feature works)
3. **Time to fix bugs** (< 10 min)

If something slows you down, we remove it.
If something catches bugs early, we keep it.

---

## QUICK COMMANDS

```bash
# Start new feature (AI builds everything)
/vibe [feature-name]

# Preview what you're building
/preview

# Ship to production
/ship

# Fix something broken
/fix [description]

# Make it pretty
/style [component]
```

---

## THE STACK (Why Each Piece)

### Next.js 14 (App Router)
- Server components = fast
- File-based routing = simple
- API routes built-in = no separate backend

### shadcn/UI
- You own the code
- Copy-paste components
- Tailwind-based = customize anything
- No vendor lock-in

### Clerk
- Auth in 5 minutes
- User management included
- Webhooks for sync
- Zero auth code to write

### Convex
- Real-time by default
- No REST APIs to build
- TypeScript end-to-end
- Automatic scaling

**Combined**: Features that took days now take minutes.

---

## PROJECT STRUCTURE

### Boilerplate Repository
```
vibe-coder-dream/
├── CLAUDE.md                 # AI coding guidelines
├── cloud.md                  # AI orchestration settings
├── README.md                 # Quick start guide
├── setup.sh                  # Project generator script
├── agents/                   # AI agent definitions
│   ├── vibe-agent.md        # Main builder (fast mode)
│   ├── fix-agent.md         # Bug fixer
│   ├── style-agent.md       # Make things pretty
│   └── ship-agent.md        # Deployment
├── skills/                   # Reusable code patterns
│   ├── convex-crud/         # Database patterns
│   ├── shadcn-forms/        # Form patterns
│   ├── clerk-auth/          # Auth patterns
│   └── realtime-sync/       # Real-time patterns
└── templates/                # Feature templates
```

### Generated Project (after running setup.sh)
```
my-app/
├── src/
│   ├── app/                 # Next.js pages
│   │   ├── (auth)/          # Auth pages (sign-in, sign-up)
│   │   ├── (dashboard)/     # Protected pages
│   │   └── layout.tsx       # Root layout with providers
│   ├── components/
│   │   ├── ui/              # shadcn components
│   │   ├── features/        # Feature components
│   │   └── providers/       # Context providers
│   └── lib/                 # Utilities
├── convex/                  # Backend
│   ├── schema.ts            # Database schema
│   ├── functions/           # Queries & mutations
│   └── http.ts              # Webhooks
├── .claude/                 # AI config (copied from boilerplate)
│   └── agents/              # Agent definitions
└── skills/                  # Code patterns (copied)
```

---

## CODING PATTERNS

### Pattern 1: Convex Schema

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
    createdAt: v.number(),
  })
    .index('by_clerkId', ['clerkId'])
    .index('by_email', ['email']),

  posts: defineTable({
    userId: v.id('users'),
    title: v.string(),
    content: v.string(),
    published: v.boolean(),
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    .index('by_userId', ['userId'])
    .index('by_published', ['published']),
});
```

**Rules:**
- Always add `createdAt` and `updatedAt`
- Always index foreign keys
- Always index fields you query by
- Use `v.id('tableName')` for references

### Pattern 2: Convex Query

```typescript
// convex/functions/posts.ts
import { query } from '../_generated/server';
import { v } from 'convex/values';

export const getMyPosts = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return [];

    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) return [];

    return ctx.db
      .query('posts')
      .withIndex('by_userId', (q) => q.eq('userId', user._id))
      .order('desc')
      .collect();
  },
});
```

**Rules:**
- Always check auth first
- Always use indexes (never full table scans)
- Return empty array, not null
- Order by most recent first

### Pattern 3: Convex Mutation

```typescript
// convex/functions/posts.ts
import { mutation } from '../_generated/server';
import { v } from 'convex/values';

export const createPost = mutation({
  args: {
    title: v.string(),
    content: v.string(),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error('Not authenticated');

    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) throw new Error('User not found');

    const now = Date.now();

    return ctx.db.insert('posts', {
      userId: user._id,
      title: args.title,
      content: args.content,
      published: false,
      createdAt: now,
      updatedAt: now,
    });
  },
});
```

**Rules:**
- Validate args with Convex validators
- Check auth, throw if missing
- Use `Date.now()` for timestamps
- Return the inserted ID

### Pattern 4: React Component with Convex

```typescript
// components/features/PostsList.tsx
'use client';

import { useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Skeleton } from '@/components/ui/skeleton';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

export function PostsList() {
  const posts = useQuery(api.functions.posts.getMyPosts);

  // Loading state
  if (posts === undefined) {
    return (
      <div className="space-y-4">
        {[1, 2, 3].map((i) => (
          <Skeleton key={i} className="h-24 w-full" />
        ))}
      </div>
    );
  }

  // Empty state
  if (posts.length === 0) {
    return (
      <Card>
        <CardContent className="py-8 text-center text-muted-foreground">
          No posts yet. Create your first one!
        </CardContent>
      </Card>
    );
  }

  // Data state
  return (
    <div className="space-y-4">
      {posts.map((post) => (
        <Card key={post._id}>
          <CardHeader>
            <CardTitle>{post.title}</CardTitle>
          </CardHeader>
          <CardContent>{post.content}</CardContent>
        </Card>
      ))}
    </div>
  );
}
```

**Rules:**
- Always handle loading (`undefined`)
- Always handle empty state
- Use shadcn components
- Keep components focused (one job)

### Pattern 5: Form with Validation

```typescript
// components/features/CreatePostForm.tsx
'use client';

import { useState } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { toast } from 'sonner';

export function CreatePostForm() {
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const createPost = useMutation(api.functions.posts.createPost);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title.trim() || !content.trim()) {
      toast.error('Please fill in all fields');
      return;
    }

    setIsLoading(true);
    try {
      await createPost({ title, content });
      toast.success('Post created!');
      setTitle('');
      setContent('');
    } catch (error) {
      toast.error('Failed to create post');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <Input
        placeholder="Post title"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        disabled={isLoading}
      />
      <Textarea
        placeholder="Write your post..."
        value={content}
        onChange={(e) => setContent(e.target.value)}
        disabled={isLoading}
      />
      <Button type="submit" disabled={isLoading}>
        {isLoading ? 'Creating...' : 'Create Post'}
      </Button>
    </form>
  );
}
```

**Rules:**
- Use controlled inputs
- Show loading states
- Use toast for feedback
- Clear form on success
- Disable inputs while loading

### Pattern 6: Clerk Webhook

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
    const webhookSecret = process.env.CLERK_WEBHOOK_SECRET!;
    
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
      return new Response('Invalid signature', { status: 400 });
    }

    const eventType = evt.type;

    if (eventType === 'user.created') {
      await ctx.runMutation(internal.functions.users.createUser, {
        clerkId: evt.data.id,
        email: evt.data.email_addresses[0]?.email_address ?? '',
        name: `${evt.data.first_name ?? ''} ${evt.data.last_name ?? ''}`.trim(),
        imageUrl: evt.data.image_url,
      });
    }

    if (eventType === 'user.updated') {
      await ctx.runMutation(internal.functions.users.updateUser, {
        clerkId: evt.data.id,
        email: evt.data.email_addresses[0]?.email_address ?? '',
        name: `${evt.data.first_name ?? ''} ${evt.data.last_name ?? ''}`.trim(),
        imageUrl: evt.data.image_url,
      });
    }

    if (eventType === 'user.deleted') {
      await ctx.runMutation(internal.functions.users.deleteUser, {
        clerkId: evt.data.id,
      });
    }

    return new Response('OK', { status: 200 });
  }),
});

export default http;
```

---

## NAMING CONVENTIONS

| Thing | Convention | Example |
|-------|------------|---------|
| Files | kebab-case | `create-post-form.tsx` |
| Components | PascalCase | `CreatePostForm` |
| Functions | camelCase | `createPost` |
| Convex tables | plural, lowercase | `users`, `posts` |
| Convex indexes | by_fieldName | `by_userId`, `by_email` |
| API routes | kebab-case | `/api/webhooks/clerk` |

---

## ENVIRONMENT VARIABLES

```bash
# .env.local

# Clerk
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
CLERK_WEBHOOK_SECRET=whsec_...

# Clerk URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# Convex
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
CONVEX_DEPLOY_KEY=prod:...
```

**Rules:**
- `NEXT_PUBLIC_` prefix = available in browser
- Never commit real keys
- Use `.env.local` for development
- Use Vercel/platform for production

---

## QUALITY GATES

### Before Commit
- [ ] TypeScript compiles (zero errors)
- [ ] Component renders without crash
- [ ] Basic functionality works

### Before Ship
- [ ] Test on mobile viewport
- [ ] Check loading states
- [ ] Check error states
- [ ] Check empty states

### After Ship
- [ ] Monitor for errors (Convex dashboard)
- [ ] Check real user feedback
- [ ] Fix within 24 hours if broken

---

## ERROR HANDLING

### In Convex Mutations

```typescript
// DO: Specific errors
if (!user) throw new Error('User not found');
if (!post) throw new Error('Post not found');
if (post.userId !== user._id) throw new Error('Not authorized');

// DON'T: Generic errors
if (!user) throw new Error('Error');
```

### In React Components

```typescript
// DO: Catch and show feedback
try {
  await createPost({ title, content });
  toast.success('Created!');
} catch (error) {
  toast.error(error.message || 'Something went wrong');
}

// DON'T: Silent failures
await createPost({ title, content });
```

---

## DEPLOYMENT

### One-Command Deploy

```bash
# Deploy everything
npm run deploy

# This runs:
# 1. npx convex deploy (backend)
# 2. vercel --prod (frontend)
```

### Vercel Settings

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "installCommand": "npm install"
}
```

### Convex Settings

```bash
# Set production environment variables
npx convex env set CLERK_WEBHOOK_SECRET whsec_...
```

---

## SPEED TIPS

### 1. Use the Right Hook

```typescript
// For data that updates in real-time
const posts = useQuery(api.posts.getAll);

// For one-time actions
const createPost = useMutation(api.posts.create);

// For actions that need optimistic updates
const updatePost = useMutation(api.posts.update);
```

### 2. Prefetch Data

```typescript
// In layout or parent component
const posts = useQuery(api.posts.getAll);
// Child components get instant data
```

### 3. Use Loading States

```typescript
// Don't: Wait for everything
if (posts === undefined) return <FullPageLoader />;

// Do: Progressive loading
<Suspense fallback={<Skeleton />}>
  <PostsList />
</Suspense>
```

### 4. Batch Operations

```typescript
// Don't: Multiple separate mutations
await createTag({ name: 'react' });
await createTag({ name: 'nextjs' });
await createTag({ name: 'convex' });

// Do: Single batch mutation
await createTags({ names: ['react', 'nextjs', 'convex'] });
```

---

## COMMON FIXES

### "User not found" after sign up
**Cause**: Webhook hasn't synced yet.
**Fix**: Add retry logic or show "Setting up your account..." state.

### Real-time not working
**Cause**: Not using `useQuery` hook.
**Fix**: Replace `fetch` with `useQuery`.

### TypeScript errors in Convex
**Cause**: Schema out of sync.
**Fix**: Run `npx convex dev` to regenerate types.

### Clerk redirect loop
**Cause**: Middleware misconfigured.
**Fix**: Check `matcher` in `middleware.ts`.

---

## WHAT NOT TO DO

❌ Don't use `fetch` for Convex data (use hooks)
❌ Don't store auth state manually (Clerk handles it)
❌ Don't create REST endpoints (Convex functions are better)
❌ Don't skip loading states (users hate blank screens)
❌ Don't ignore TypeScript errors (they catch real bugs)
❌ Don't deploy without testing mobile (50%+ of users)

---

## WHAT TO ALWAYS DO

✅ Use `useQuery` for all data fetching
✅ Use `useMutation` for all data changes
✅ Handle loading, empty, and error states
✅ Use shadcn/UI components (don't reinvent)
✅ Index every field you query by
✅ Test the happy path before edge cases
✅ Ship small, ship often

---

## PERFORMANCE OPTIMIZATION

### Frontend Performance

**1. Use Server Components by Default**
```typescript
// Good - Server Component (default)
export default function PostsPage() {
  return <PostsList />;
}

// Only add 'use client' when you need:
// - useState, useEffect, event handlers
// - Browser APIs
// - Convex hooks (useQuery, useMutation)
```

**2. Optimize Images**
```typescript
import Image from 'next/image';

// Always use Next.js Image
<Image
  src={imageUrl}
  alt="Description"
  width={400}
  height={300}
  priority={isAboveFold}  // For hero images
/>
```

**3. Lazy Load Heavy Components**
```typescript
import dynamic from 'next/dynamic';

const HeavyChart = dynamic(() => import('@/components/Chart'), {
  loading: () => <Skeleton className="h-64" />,
  ssr: false,  // If it uses browser APIs
});
```

**4. Minimize Client Bundle**
```typescript
// Import only what you need
import { Button } from '@/components/ui/button';  // Good
import * as UI from '@/components/ui';            // Bad - imports everything
```

### Database Performance

**1. Always Use Indexes**
```typescript
// Fast - uses index
.query('posts')
.withIndex('by_userId', q => q.eq('userId', userId))

// Slow - full table scan
.query('posts')
.filter(q => q.eq(q.field('userId'), userId))
```

**2. Limit Query Results**
```typescript
// Good - limit results
.query('posts')
.order('desc')
.take(20);  // Only get what you need

// Consider - paginate for large datasets
.paginate(paginationOpts);
```

**3. Denormalize When Needed**
```typescript
// Instead of joining every time, store counts
posts: defineTable({
  // ...
  likeCount: v.number(),    // Denormalized
  commentCount: v.number(), // Denormalized
})
```

**4. Batch Operations**
```typescript
// Bad - N+1 queries
for (const id of ids) {
  await ctx.db.get(id);
}

// Good - batch using Promise.all
const items = await Promise.all(ids.map(id => ctx.db.get(id)));
```

### Real-Time Performance

**1. Keep Queries Focused**
```typescript
// Good - specific query
export const getPostStats = query({
  args: { postId: v.id('posts') },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.postId);
    return { likes: post?.likeCount, views: post?.viewCount };
  },
});

// Avoid - fetching everything
export const getAllData = query({...});  // Too broad
```

**2. Use Appropriate Update Frequency**
```typescript
// High-frequency updates - consider debouncing on client
const debouncedUpdate = useMemo(
  () => debounce((value) => updateCursor({ value }), 50),
  []
);
```

### Build Performance

**1. Check Bundle Size**
```bash
# Analyze what's in your bundle
npm run build
# Check .next/analyze (if configured)
```

**2. Avoid Large Dependencies**
```typescript
// Instead of moment.js (300KB)
import { format } from 'date-fns';  // Tree-shakeable

// Instead of lodash (70KB)
import debounce from 'lodash/debounce';  // Single function
```

### Quick Wins

| Issue | Solution |
|-------|----------|
| Slow initial load | Add loading states, use Suspense |
| Large images | Use Next.js Image, compress, use WebP |
| Slow queries | Add indexes, limit results |
| Bundle too big | Dynamic imports, check dependencies |
| Re-renders | Memoize with useMemo/useCallback |

---

## TROUBLESHOOTING QUICK REFERENCE

For detailed troubleshooting, see **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**.

### Most Common Issues

| Error | Likely Cause | Quick Fix |
|-------|--------------|-----------|
| "Missing publishableKey" | Clerk env not set | Add keys to `.env.local` |
| "Query not found" | Function not exported | Add `export` to function |
| "User not found" | Webhook not configured | Set up Clerk webhook |
| "Index not found" | Missing index in schema | Add `.index()` to table |
| Redirect loop | Middleware issue | Check `isPublicRoute` matcher |
| Hydration mismatch | Server/client differ | Use `'use client'` or `useEffect` |
| Build fails | TypeScript errors | Run `npm run typecheck` |

### Debug Commands

```bash
# Check TypeScript
npm run typecheck

# Regenerate Convex types
npx convex dev

# Check Convex logs
npx convex dashboard

# Analyze bundle
npm run build && npx @next/bundle-analyzer
```

---

**Remember**: The goal is shipping.

Every pattern here exists to help you ship faster.
If something isn't helping, skip it.

---

*Version 2.0 | Built for Vibe Coders | December 2025*
