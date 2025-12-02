# Troubleshooting Guide

Common issues and solutions for Vibe Coder Dream projects.

---

## Setup Issues

### "Node.js not found" or version too old

**Problem**: Setup script fails with Node.js error.

**Solution**:
```bash
# Check your Node.js version
node -v

# Requires Node.js 18+
# Download from: https://nodejs.org
```

### "Directory already exists"

**Problem**: Can't create project because folder exists.

**Solution**:
```bash
# Remove existing directory
rm -rf my-app

# Or use a different name
bash setup.sh my-new-app
```

### shadcn components not installing

**Problem**: `npx shadcn add` fails or components missing.

**Solution**:
```bash
# Ensure components.json exists and is valid
cat components.json

# Try the older CLI name
npx shadcn-ui@latest add button card

# Or install manually
npm install @radix-ui/react-dialog
```

---

## Authentication Issues

### "Clerk: Missing publishableKey"

**Problem**: App crashes with missing Clerk key error.

**Cause**: Environment variables not set.

**Solution**:
1. Get keys from [Clerk Dashboard](https://dashboard.clerk.com)
2. Add to `.env.local`:
```bash
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
```
3. Restart dev server

### Redirect loop after login

**Problem**: Page keeps redirecting between routes.

**Cause**: Middleware matching wrong routes.

**Solution**: Check `middleware.ts`:
```typescript
const isPublicRoute = createRouteMatcher([
  '/',
  '/sign-in(.*)',  // Must include (.*)
  '/sign-up(.*)',
  '/api/webhooks(.*)',
]);
```

### "User not found" after signup

**Problem**: User signs up but database shows no user.

**Cause**: Clerk webhook not configured.

**Solution**:
1. Go to Clerk Dashboard → Webhooks
2. Add endpoint: `https://your-convex.convex.site/clerk-webhook`
3. Select events: `user.created`, `user.updated`, `user.deleted`
4. Copy signing secret to Convex:
```bash
npx convex env set CLERK_WEBHOOK_SECRET whsec_...
```

### Auth works locally but not in production

**Problem**: Auth fails after deploying.

**Cause**: Using test keys in production.

**Solution**:
1. Get production keys from Clerk (start with `pk_live_` and `sk_live_`)
2. Update Vercel environment variables
3. Redeploy

---

## Convex Issues

### "NEXT_PUBLIC_CONVEX_URL is not defined"

**Problem**: App crashes because Convex URL missing.

**Solution**:
```bash
# Run Convex dev to get URL
npx convex dev

# Copy the URL to .env.local
NEXT_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
```

### "Query/Mutation not found"

**Problem**: Convex function doesn't exist error.

**Causes & Solutions**:

1. **Function not exported**:
```typescript
// Wrong
const getUsers = query({...});

// Correct
export const getUsers = query({...});
```

2. **Wrong import path**:
```typescript
// Wrong
import { api } from '@/convex/api';

// Correct
import { api } from '@/convex/_generated/api';
```

3. **Types not generated**:
```bash
# Regenerate types
npx convex dev
```

### "Index not found"

**Problem**: Query fails because index doesn't exist.

**Solution**: Add index to schema:
```typescript
// convex/schema.ts
posts: defineTable({...})
  .index('by_userId', ['userId'])  // Add this
```

Then run `npx convex dev` to apply changes.

### TypeScript errors in Convex functions

**Problem**: Type errors in `convex/` folder.

**Solution**:
```bash
# Regenerate Convex types
npx convex dev

# If still failing, check schema matches data
```

### Webhook returns 500 error

**Problem**: Clerk webhook fails with 500.

**Solution**: Check Convex logs:
```bash
# Open Convex dashboard
npx convex dashboard

# Check Logs tab for errors
```

Common causes:
- `CLERK_WEBHOOK_SECRET` not set in Convex env
- Function referenced doesn't exist

---

## React/Next.js Issues

### "Cannot read property of undefined"

**Problem**: Accessing data before it loads.

**Solution**: Always check for undefined:
```typescript
const posts = useQuery(api.posts.getAll);

// Add loading check
if (posts === undefined) {
  return <Skeleton />;
}

// Now safe to use
return posts.map(...);
```

### "Hydration mismatch"

**Problem**: Server and client render differently.

**Causes & Solutions**:

1. **Using browser-only APIs**:
```typescript
// Wrong - runs on server
const width = window.innerWidth;

// Correct - client only
const [width, setWidth] = useState(0);
useEffect(() => {
  setWidth(window.innerWidth);
}, []);
```

2. **Date/time rendering**:
```typescript
// Wrong - different on server/client
<p>{new Date().toLocaleString()}</p>

// Correct - format consistently or use client component
'use client';
```

### "Too many re-renders"

**Problem**: Infinite render loop.

**Cause**: State update in render body.

**Solution**:
```typescript
// Wrong
const [count, setCount] = useState(0);
setCount(count + 1);  // Updates every render!

// Correct - update in effect or handler
useEffect(() => {
  setCount(count + 1);
}, [someDependency]);
```

### "Invalid hook call"

**Problem**: Hook used incorrectly.

**Rules**:
1. Only call hooks at top level
2. Only call hooks in React components
3. Don't call hooks conditionally

```typescript
// Wrong
if (condition) {
  const [state, setState] = useState();
}

// Correct
const [state, setState] = useState();
if (condition) {
  // use state here
}
```

---

## Build & Deployment Issues

### Build fails with TypeScript errors

**Problem**: `npm run build` fails.

**Solution**:
```bash
# Check types locally first
npm run typecheck

# Fix all errors, then build
npm run build
```

### "Module not found" in production

**Problem**: Works locally, fails in production.

**Causes**:
1. Case sensitivity (works on Windows, fails on Linux)
2. Missing dependency

**Solution**:
```bash
# Check exact case in imports
import { Button } from '@/components/ui/Button';  // Wrong on Linux
import { Button } from '@/components/ui/button';  // Correct

# Ensure all dependencies in package.json
npm install
```

### Vercel deployment fails

**Problem**: Deployment errors on Vercel.

**Solution**:
1. Check build logs in Vercel dashboard
2. Ensure all env vars are set in Vercel
3. Try building locally first:
```bash
npm run build
```

### Functions not appearing in production

**Problem**: Convex functions work locally but not in prod.

**Solution**:
```bash
# Deploy Convex to production
npx convex deploy

# Verify in Convex dashboard
npx convex dashboard
```

---

## Performance Issues

### Slow initial page load

**Causes & Solutions**:

1. **Too many client components**:
   - Use Server Components by default
   - Only add `'use client'` when needed

2. **Large bundle size**:
```bash
# Analyze bundle
npm run build
# Check .next/analyze if configured
```

3. **No loading states**:
```typescript
// Add Suspense boundaries
<Suspense fallback={<Skeleton />}>
  <DataComponent />
</Suspense>
```

### Real-time updates slow

**Problem**: Data takes time to sync.

**Note**: Convex is real-time by default. If slow:
1. Check network tab for connection issues
2. Verify using `useQuery` not `fetch`
3. Check Convex dashboard for function latency

---

## Quick Debug Checklist

When something doesn't work:

1. **Check browser console** for errors
2. **Check terminal** for server errors
3. **Check Convex logs**: `npx convex dashboard`
4. **Verify env vars** are set correctly
5. **Restart dev servers** (both Next.js and Convex)
6. **Clear browser cache** / try incognito
7. **Regenerate types**: `npx convex dev`

---

## Getting Help

If you're still stuck:

1. Check [Next.js docs](https://nextjs.org/docs)
2. Check [Convex docs](https://docs.convex.dev)
3. Check [Clerk docs](https://clerk.com/docs)
4. Search [Stack Overflow](https://stackoverflow.com)
5. Ask in [Convex Discord](https://convex.dev/community)

---

*Still stuck? The error message usually tells you what's wrong. Read it carefully.*
