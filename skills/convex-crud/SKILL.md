# Convex CRUD Skill

**Purpose**: Complete patterns for Convex database operations  
**Triggers**: "database", "schema", "table", "CRUD", "query", "mutation"

---

## Schema Patterns

### Basic Table

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from 'convex/server';
import { v } from 'convex/values';

export default defineSchema({
  posts: defineTable({
    // Foreign key to users (required)
    userId: v.id('users'),
    
    // Core fields
    title: v.string(),
    content: v.string(),
    slug: v.string(),
    
    // Optional fields
    imageUrl: v.optional(v.string()),
    excerpt: v.optional(v.string()),
    
    // Status/flags
    published: v.boolean(),
    featured: v.boolean(),
    
    // Counts (denormalized for performance)
    viewCount: v.number(),
    likeCount: v.number(),
    
    // Timestamps (always include these)
    createdAt: v.number(),
    updatedAt: v.number(),
  })
    // Always index foreign keys
    .index('by_userId', ['userId'])
    // Index fields you filter/query by
    .index('by_slug', ['slug'])
    .index('by_published', ['published'])
    // Compound index for common queries
    .index('by_user_and_published', ['userId', 'published']),
});
```

### User Table (with Clerk)

```typescript
users: defineTable({
  // Clerk integration
  clerkId: v.string(),
  email: v.string(),
  name: v.string(),
  imageUrl: v.optional(v.string()),
  
  // Profile fields
  bio: v.optional(v.string()),
  website: v.optional(v.string()),
  
  // Settings
  emailNotifications: v.boolean(),
  
  // Metadata
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index('by_clerkId', ['clerkId'])
  .index('by_email', ['email']),
```

### Join Table (Many-to-Many)

```typescript
// Example: posts have many tags, tags have many posts
postTags: defineTable({
  postId: v.id('posts'),
  tagId: v.id('tags'),
  createdAt: v.number(),
})
  .index('by_postId', ['postId'])
  .index('by_tagId', ['tagId'])
  .index('by_post_and_tag', ['postId', 'tagId']),
```

---

## Query Patterns

### Get Current User

```typescript
// convex/functions/users.ts
import { query } from '../_generated/server';

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

### Get List with Auth

```typescript
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

### Get Single by ID

```typescript
import { v } from 'convex/values';

export const getPost = query({
  args: { id: v.id('posts') },
  handler: async (ctx, args) => {
    return ctx.db.get(args.id);
  },
});
```

### Get with Filter

```typescript
export const getPublishedPosts = query({
  args: {},
  handler: async (ctx) => {
    return ctx.db
      .query('posts')
      .withIndex('by_published', (q) => q.eq('published', true))
      .order('desc')
      .collect();
  },
});
```

### Get with Pagination

```typescript
export const getPaginatedPosts = query({
  args: {
    paginationOpts: v.object({
      cursor: v.optional(v.string()),
      numItems: v.number(),
    }),
  },
  handler: async (ctx, args) => {
    return ctx.db
      .query('posts')
      .withIndex('by_published', (q) => q.eq('published', true))
      .order('desc')
      .paginate(args.paginationOpts);
  },
});
```

### Get with Related Data

```typescript
export const getPostWithAuthor = query({
  args: { id: v.id('posts') },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.id);
    if (!post) return null;

    const author = await ctx.db.get(post.userId);

    return {
      ...post,
      author: author
        ? { name: author.name, imageUrl: author.imageUrl }
        : null,
    };
  },
});
```

---

## Mutation Patterns

### Create

```typescript
import { mutation } from '../_generated/server';
import { v } from 'convex/values';

export const createPost = mutation({
  args: {
    title: v.string(),
    content: v.string(),
  },
  handler: async (ctx, args) => {
    // 1. Auth check
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error('Not authenticated');
    }

    // 2. Get user
    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) {
      throw new Error('User not found');
    }

    // 3. Create with timestamps
    const now = Date.now();

    return ctx.db.insert('posts', {
      userId: user._id,
      title: args.title,
      content: args.content,
      slug: args.title.toLowerCase().replace(/\s+/g, '-'),
      published: false,
      featured: false,
      viewCount: 0,
      likeCount: 0,
      createdAt: now,
      updatedAt: now,
    });
  },
});
```

### Update

```typescript
export const updatePost = mutation({
  args: {
    id: v.id('posts'),
    title: v.optional(v.string()),
    content: v.optional(v.string()),
    published: v.optional(v.boolean()),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error('Not authenticated');
    }

    // Get existing post
    const post = await ctx.db.get(args.id);
    if (!post) {
      throw new Error('Post not found');
    }

    // Get user for ownership check
    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user || post.userId !== user._id) {
      throw new Error('Not authorized');
    }

    // Build update object (only changed fields)
    const updates: any = {
      updatedAt: Date.now(),
    };

    if (args.title !== undefined) {
      updates.title = args.title;
      updates.slug = args.title.toLowerCase().replace(/\s+/g, '-');
    }
    if (args.content !== undefined) updates.content = args.content;
    if (args.published !== undefined) updates.published = args.published;

    await ctx.db.patch(args.id, updates);

    return ctx.db.get(args.id);
  },
});
```

### Delete

```typescript
export const deletePost = mutation({
  args: { id: v.id('posts') },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error('Not authenticated');
    }

    const post = await ctx.db.get(args.id);
    if (!post) {
      throw new Error('Post not found');
    }

    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user || post.userId !== user._id) {
      throw new Error('Not authorized');
    }

    // Delete related records first (if any)
    const postTags = await ctx.db
      .query('postTags')
      .withIndex('by_postId', (q) => q.eq('postId', args.id))
      .collect();

    for (const tag of postTags) {
      await ctx.db.delete(tag._id);
    }

    // Delete the post
    await ctx.db.delete(args.id);
  },
});
```

### Increment Counter

```typescript
export const incrementViewCount = mutation({
  args: { id: v.id('posts') },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.id);
    if (!post) return;

    await ctx.db.patch(args.id, {
      viewCount: post.viewCount + 1,
    });
  },
});
```

### Toggle Boolean

```typescript
export const togglePublished = mutation({
  args: { id: v.id('posts') },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error('Not authenticated');

    const post = await ctx.db.get(args.id);
    if (!post) throw new Error('Post not found');

    // Auth check...

    await ctx.db.patch(args.id, {
      published: !post.published,
      updatedAt: Date.now(),
    });
  },
});
```

---

## Internal Functions (for webhooks)

```typescript
// convex/functions/users.ts
import { internalMutation } from '../_generated/server';
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
      emailNotifications: true,
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

    // Delete user's posts
    const posts = await ctx.db
      .query('posts')
      .withIndex('by_userId', (q) => q.eq('userId', user._id))
      .collect();

    for (const post of posts) {
      await ctx.db.delete(post._id);
    }

    // Delete user
    await ctx.db.delete(user._id);
  },
});
```

---

## Validation Patterns

### Required String with Length

```typescript
args: {
  title: v.string(), // Add runtime validation
},
handler: async (ctx, args) => {
  if (!args.title.trim()) {
    throw new Error('Title is required');
  }
  if (args.title.length > 100) {
    throw new Error('Title must be 100 characters or less');
  }
  // ...
}
```

### Email Validation

```typescript
handler: async (ctx, args) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(args.email)) {
    throw new Error('Invalid email address');
  }
  // ...
}
```

### Unique Check

```typescript
handler: async (ctx, args) => {
  const existing = await ctx.db
    .query('posts')
    .withIndex('by_slug', (q) => q.eq('slug', args.slug))
    .unique();
  
  if (existing) {
    throw new Error('A post with this slug already exists');
  }
  // ...
}
```

---

## Best Practices

### Always Do

- Add indexes for every field you query by
- Include createdAt/updatedAt timestamps
- Check auth before mutations
- Use descriptive error messages
- Handle not-found cases

### Never Do

- Query without index (full table scan)
- Forget auth checks
- Return sensitive data (passwords, tokens)
- Delete without checking ownership
- Use mutation for read operations

---

*Use these patterns. They work.*
