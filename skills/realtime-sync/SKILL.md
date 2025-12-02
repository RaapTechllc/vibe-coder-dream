# Real-Time Sync Skill

**Purpose**: Real-time data patterns with Convex  
**Triggers**: "real-time", "live", "sync", "updates", "subscription"

---

## Core Concept

Convex is real-time by default. When you use `useQuery`, the data automatically updates when it changes. No WebSockets to manage. No manual refetching.

```typescript
// This automatically updates in real-time
const posts = useQuery(api.posts.getAll);
```

That's it. The magic is already there.

---

## Basic Real-Time List

```typescript
'use client';

import { useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Skeleton } from '@/components/ui/skeleton';
import { Card, CardContent } from '@/components/ui/card';

export function PostsList() {
  // This updates in real-time automatically
  const posts = useQuery(api.functions.posts.getPosts);

  // Loading state
  if (posts === undefined) {
    return (
      <div className="space-y-3">
        {[1, 2, 3].map((i) => (
          <Skeleton key={i} className="h-20 w-full" />
        ))}
      </div>
    );
  }

  // Empty state
  if (posts.length === 0) {
    return (
      <Card>
        <CardContent className="py-8 text-center text-muted-foreground">
          No posts yet
        </CardContent>
      </Card>
    );
  }

  // Real-time list - updates instantly when data changes
  return (
    <div className="space-y-3">
      {posts.map((post) => (
        <Card key={post._id}>
          <CardContent className="py-4">
            <h3 className="font-medium">{post.title}</h3>
            <p className="text-sm text-muted-foreground">{post.content}</p>
          </CardContent>
        </Card>
      ))}
    </div>
  );
}
```

---

## Real-Time Counter

```typescript
// Convex query
export const getPostStats = query({
  args: { postId: v.id('posts') },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.postId);
    if (!post) return null;
    
    return {
      views: post.viewCount,
      likes: post.likeCount,
    };
  },
});

// Convex mutation
export const likePost = mutation({
  args: { postId: v.id('posts') },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.postId);
    if (!post) throw new Error('Post not found');
    
    await ctx.db.patch(args.postId, {
      likeCount: post.likeCount + 1,
    });
  },
});
```

```typescript
// React component
'use client';

import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Id } from '@/convex/_generated/dataModel';
import { Button } from '@/components/ui/button';
import { Heart, Eye } from 'lucide-react';

interface PostStatsProps {
  postId: Id<'posts'>;
}

export function PostStats({ postId }: PostStatsProps) {
  // Real-time stats
  const stats = useQuery(api.functions.posts.getPostStats, { postId });
  const likePost = useMutation(api.functions.posts.likePost);

  if (!stats) return null;

  return (
    <div className="flex items-center gap-4">
      <div className="flex items-center gap-1 text-muted-foreground">
        <Eye className="h-4 w-4" />
        <span>{stats.views}</span>
      </div>
      
      <Button
        variant="ghost"
        size="sm"
        onClick={() => likePost({ postId })}
        className="flex items-center gap-1"
      >
        <Heart className="h-4 w-4" />
        <span>{stats.likes}</span>
      </Button>
    </div>
  );
}
```

---

## Real-Time Presence

```typescript
// convex/schema.ts
presence: defineTable({
  odocumentId: v.string(),
  clerkId: v.string(),
  name: v.string(),
  cursor: v.optional(v.object({
    x: v.number(),
    y: v.number(),
  })),
  lastSeen: v.number(),
})
  .index('by_document', ['documentId'])
  .index('by_clerk', ['clerkId']),
```

```typescript
// convex/functions/presence.ts
export const updatePresence = mutation({
  args: {
    documentId: v.string(),
    cursor: v.optional(v.object({ x: v.number(), y: v.number() })),
  },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return;

    const existing = await ctx.db
      .query('presence')
      .withIndex('by_clerk', (q) => q.eq('clerkId', identity.subject))
      .filter((q) => q.eq(q.field('documentId'), args.documentId))
      .unique();

    const now = Date.now();

    if (existing) {
      await ctx.db.patch(existing._id, {
        cursor: args.cursor,
        lastSeen: now,
      });
    } else {
      await ctx.db.insert('presence', {
        documentId: args.documentId,
        clerkId: identity.subject,
        name: identity.name ?? 'Anonymous',
        cursor: args.cursor,
        lastSeen: now,
      });
    }
  },
});

export const getPresence = query({
  args: { documentId: v.string() },
  handler: async (ctx, args) => {
    const fiveMinutesAgo = Date.now() - 5 * 60 * 1000;

    return ctx.db
      .query('presence')
      .withIndex('by_document', (q) => q.eq('documentId', args.documentId))
      .filter((q) => q.gt(q.field('lastSeen'), fiveMinutesAgo))
      .collect();
  },
});

export const removePresence = mutation({
  args: { documentId: v.string() },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return;

    const existing = await ctx.db
      .query('presence')
      .withIndex('by_clerk', (q) => q.eq('clerkId', identity.subject))
      .filter((q) => q.eq(q.field('documentId'), args.documentId))
      .unique();

    if (existing) {
      await ctx.db.delete(existing._id);
    }
  },
});
```

```typescript
// components/presence-avatars.tsx
'use client';

import { useEffect } from 'react';
import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Avatar, AvatarFallback } from '@/components/ui/avatar';
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';

interface PresenceAvatarsProps {
  documentId: string;
}

export function PresenceAvatars({ documentId }: PresenceAvatarsProps) {
  const presence = useQuery(api.functions.presence.getPresence, { documentId });
  const updatePresence = useMutation(api.functions.presence.updatePresence);
  const removePresence = useMutation(api.functions.presence.removePresence);

  // Heartbeat - update presence every 30 seconds
  useEffect(() => {
    updatePresence({ documentId });

    const interval = setInterval(() => {
      updatePresence({ documentId });
    }, 30000);

    return () => {
      clearInterval(interval);
      removePresence({ documentId });
    };
  }, [documentId, updatePresence, removePresence]);

  if (!presence || presence.length === 0) return null;

  return (
    <TooltipProvider>
      <div className="flex -space-x-2">
        {presence.slice(0, 5).map((user) => (
          <Tooltip key={user._id}>
            <TooltipTrigger>
              <Avatar className="h-8 w-8 border-2 border-background">
                <AvatarFallback className="text-xs">
                  {user.name[0]?.toUpperCase()}
                </AvatarFallback>
              </Avatar>
            </TooltipTrigger>
            <TooltipContent>
              <p>{user.name}</p>
            </TooltipContent>
          </Tooltip>
        ))}
        {presence.length > 5 && (
          <Avatar className="h-8 w-8 border-2 border-background">
            <AvatarFallback className="text-xs">
              +{presence.length - 5}
            </AvatarFallback>
          </Avatar>
        )}
      </div>
    </TooltipProvider>
  );
}
```

---

## Real-Time Chat

```typescript
// convex/schema.ts
messages: defineTable({
  channelId: v.string(),
  userId: v.id('users'),
  content: v.string(),
  createdAt: v.number(),
})
  .index('by_channel', ['channelId', 'createdAt']),
```

```typescript
// convex/functions/messages.ts
export const getMessages = query({
  args: { channelId: v.string() },
  handler: async (ctx, args) => {
    const messages = await ctx.db
      .query('messages')
      .withIndex('by_channel', (q) => q.eq('channelId', args.channelId))
      .order('asc')
      .take(100);

    // Fetch user info for each message
    return Promise.all(
      messages.map(async (message) => {
        const user = await ctx.db.get(message.userId);
        return {
          ...message,
          userName: user?.name ?? 'Unknown',
          userImage: user?.imageUrl,
        };
      })
    );
  },
});

export const sendMessage = mutation({
  args: {
    channelId: v.string(),
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

    if (!args.content.trim()) {
      throw new Error('Message cannot be empty');
    }

    return ctx.db.insert('messages', {
      channelId: args.channelId,
      userId: user._id,
      content: args.content.trim(),
      createdAt: Date.now(),
    });
  },
});
```

```typescript
// components/chat.tsx
'use client';

import { useState, useRef, useEffect } from 'react';
import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Send } from 'lucide-react';

interface ChatProps {
  channelId: string;
}

export function Chat({ channelId }: ChatProps) {
  const [message, setMessage] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  // Real-time messages
  const messages = useQuery(api.functions.messages.getMessages, { channelId });
  const sendMessage = useMutation(api.functions.messages.sendMessage);

  // Auto-scroll on new messages
  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim() || isLoading) return;

    setIsLoading(true);
    try {
      await sendMessage({ channelId, content: message });
      setMessage('');
    } catch (error) {
      console.error('Failed to send message:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-[500px] border rounded-lg">
      {/* Messages */}
      <ScrollArea className="flex-1 p-4" ref={scrollRef}>
        <div className="space-y-4">
          {messages?.map((msg) => (
            <div key={msg._id} className="flex items-start gap-3">
              <Avatar className="h-8 w-8">
                <AvatarImage src={msg.userImage} />
                <AvatarFallback>{msg.userName[0]}</AvatarFallback>
              </Avatar>
              <div>
                <div className="flex items-center gap-2">
                  <span className="font-medium text-sm">{msg.userName}</span>
                  <span className="text-xs text-muted-foreground">
                    {new Date(msg.createdAt).toLocaleTimeString()}
                  </span>
                </div>
                <p className="text-sm">{msg.content}</p>
              </div>
            </div>
          ))}
        </div>
      </ScrollArea>

      {/* Input */}
      <form onSubmit={handleSend} className="p-4 border-t flex gap-2">
        <Input
          placeholder="Type a message..."
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          disabled={isLoading}
        />
        <Button type="submit" size="icon" disabled={isLoading || !message.trim()}>
          <Send className="h-4 w-4" />
        </Button>
      </form>
    </div>
  );
}
```

---

## Real-Time Notifications

```typescript
// convex/schema.ts
notifications: defineTable({
  userId: v.id('users'),
  type: v.string(),
  title: v.string(),
  message: v.string(),
  read: v.boolean(),
  createdAt: v.number(),
})
  .index('by_user', ['userId', 'createdAt'])
  .index('by_user_unread', ['userId', 'read']),
```

```typescript
// convex/functions/notifications.ts
export const getUnreadCount = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return 0;

    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) return 0;

    const unread = await ctx.db
      .query('notifications')
      .withIndex('by_user_unread', (q) =>
        q.eq('userId', user._id).eq('read', false)
      )
      .collect();

    return unread.length;
  },
});

export const getNotifications = query({
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
      .query('notifications')
      .withIndex('by_user', (q) => q.eq('userId', user._id))
      .order('desc')
      .take(20);
  },
});

export const markAsRead = mutation({
  args: { id: v.id('notifications') },
  handler: async (ctx, args) => {
    await ctx.db.patch(args.id, { read: true });
  },
});

export const markAllAsRead = mutation({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return;

    const user = await ctx.db
      .query('users')
      .withIndex('by_clerkId', (q) => q.eq('clerkId', identity.subject))
      .unique();

    if (!user) return;

    const unread = await ctx.db
      .query('notifications')
      .withIndex('by_user_unread', (q) =>
        q.eq('userId', user._id).eq('read', false)
      )
      .collect();

    for (const notification of unread) {
      await ctx.db.patch(notification._id, { read: true });
    }
  },
});
```

```typescript
// components/notification-bell.tsx
'use client';

import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Bell } from 'lucide-react';

export function NotificationBell() {
  // Real-time unread count
  const unreadCount = useQuery(api.functions.notifications.getUnreadCount);
  const notifications = useQuery(api.functions.notifications.getNotifications);
  const markAsRead = useMutation(api.functions.notifications.markAsRead);
  const markAllAsRead = useMutation(api.functions.notifications.markAllAsRead);

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon" className="relative">
          <Bell className="h-5 w-5" />
          {(unreadCount ?? 0) > 0 && (
            <span className="absolute -top-1 -right-1 h-5 w-5 rounded-full bg-destructive text-destructive-foreground text-xs flex items-center justify-center">
              {unreadCount}
            </span>
          )}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-80">
        <DropdownMenuLabel className="flex items-center justify-between">
          <span>Notifications</span>
          {(unreadCount ?? 0) > 0 && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => markAllAsRead()}
              className="text-xs"
            >
              Mark all read
            </Button>
          )}
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        {notifications?.length === 0 ? (
          <div className="p-4 text-center text-muted-foreground text-sm">
            No notifications
          </div>
        ) : (
          notifications?.map((notification) => (
            <DropdownMenuItem
              key={notification._id}
              className={notification.read ? 'opacity-60' : ''}
              onClick={() => !notification.read && markAsRead({ id: notification._id })}
            >
              <div>
                <p className="font-medium">{notification.title}</p>
                <p className="text-sm text-muted-foreground">
                  {notification.message}
                </p>
              </div>
            </DropdownMenuItem>
          ))
        )}
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
```

---

## Optimistic Updates

```typescript
'use client';

import { useMutation, useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Heart } from 'lucide-react';
import { useState } from 'react';

export function LikeButton({ postId }) {
  const post = useQuery(api.posts.get, { id: postId });
  const likePost = useMutation(api.posts.like);
  
  // Local optimistic state
  const [optimisticLikes, setOptimisticLikes] = useState<number | null>(null);

  const handleLike = async () => {
    // Optimistically update
    setOptimisticLikes((post?.likes ?? 0) + 1);

    try {
      await likePost({ id: postId });
    } catch (error) {
      // Revert on error
      setOptimisticLikes(null);
    }
  };

  // Use optimistic value if set, otherwise use real value
  const displayLikes = optimisticLikes ?? post?.likes ?? 0;

  return (
    <Button variant="ghost" onClick={handleLike}>
      <Heart className="mr-2 h-4 w-4" />
      {displayLikes}
    </Button>
  );
}
```

---

## Rate Limiting Patterns

For high-frequency real-time updates, implement client-side rate limiting:

### Debounced Updates

```typescript
'use client';

import { useMemo, useCallback } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import debounce from 'lodash/debounce';

export function CursorTracker({ documentId }: { documentId: string }) {
  const updateCursor = useMutation(api.functions.presence.updateCursor);

  // Debounce cursor updates to max 20/second
  const debouncedUpdate = useMemo(
    () => debounce((x: number, y: number) => {
      updateCursor({ documentId, x, y });
    }, 50),
    [documentId, updateCursor]
  );

  const handleMouseMove = useCallback((e: React.MouseEvent) => {
    debouncedUpdate(e.clientX, e.clientY);
  }, [debouncedUpdate]);

  return (
    <div onMouseMove={handleMouseMove} className="w-full h-full">
      {/* Content */}
    </div>
  );
}
```

### Throttled Updates

```typescript
import { useMemo, useCallback, useRef } from 'react';

export function useThrottledMutation(
  mutation: any,
  delay: number = 100
) {
  const lastCallRef = useRef(0);

  return useCallback((...args: any[]) => {
    const now = Date.now();
    if (now - lastCallRef.current >= delay) {
      lastCallRef.current = now;
      return mutation(...args);
    }
  }, [mutation, delay]);
}

// Usage
const updatePosition = useMutation(api.functions.position.update);
const throttledUpdate = useThrottledMutation(updatePosition, 100);
```

### Server-Side Rate Limiting

```typescript
// convex/functions/rateLimited.ts
import { mutation } from '../_generated/server';
import { v } from 'convex/values';

// Rate limit table
// Add to schema:
// rateLimits: defineTable({
//   key: v.string(),
//   count: v.number(),
//   windowStart: v.number(),
// }).index('by_key', ['key']),

const RATE_LIMIT_WINDOW = 60 * 1000; // 1 minute
const MAX_REQUESTS = 100; // per window

export const rateLimitedAction = mutation({
  args: { data: v.string() },
  handler: async (ctx, args) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error('Not authenticated');

    const key = `rate:${identity.subject}`;
    const now = Date.now();

    // Get or create rate limit record
    let rateLimit = await ctx.db
      .query('rateLimits')
      .withIndex('by_key', (q) => q.eq('key', key))
      .unique();

    if (rateLimit) {
      // Check if window expired
      if (now - rateLimit.windowStart > RATE_LIMIT_WINDOW) {
        // Reset window
        await ctx.db.patch(rateLimit._id, {
          count: 1,
          windowStart: now,
        });
      } else if (rateLimit.count >= MAX_REQUESTS) {
        throw new Error('Rate limit exceeded. Try again later.');
      } else {
        // Increment count
        await ctx.db.patch(rateLimit._id, {
          count: rateLimit.count + 1,
        });
      }
    } else {
      // Create new rate limit record
      await ctx.db.insert('rateLimits', {
        key,
        count: 1,
        windowStart: now,
      });
    }

    // Proceed with action
    // ...
  },
});
```

### Batching Updates

```typescript
'use client';

import { useRef, useCallback, useEffect } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';

export function useBatchedUpdates(delay: number = 200) {
  const batchRef = useRef<any[]>([]);
  const timeoutRef = useRef<NodeJS.Timeout>();
  const batchUpdate = useMutation(api.functions.items.batchUpdate);

  const addToBatch = useCallback((item: any) => {
    batchRef.current.push(item);

    // Clear existing timeout
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Set new timeout to flush batch
    timeoutRef.current = setTimeout(() => {
      if (batchRef.current.length > 0) {
        batchUpdate({ items: batchRef.current });
        batchRef.current = [];
      }
    }, delay);
  }, [batchUpdate, delay]);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return addToBatch;
}
```

---

## Best Practices

### Always Do

- Handle `undefined` (loading) state
- Handle empty state
- Use indexes for all queries
- Clean up subscriptions (Convex does this automatically)
- Add appropriate loading UI
- Debounce/throttle high-frequency updates

### Never Do

- Use `fetch` for Convex data (use hooks)
- Forget to handle loading states
- Poll for updates (Convex is already real-time)
- Create too many subscriptions (combine queries)
- Send updates faster than 20/second without throttling

---

*Real-time is the default. Just use it.*
