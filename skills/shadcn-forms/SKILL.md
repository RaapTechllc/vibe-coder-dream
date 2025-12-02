# shadcn Forms Skill

**Purpose**: Complete patterns for building forms with shadcn/UI and Convex  
**Triggers**: "form", "input", "validation", "submit"

---

## Basic Form Pattern

```typescript
'use client';

import { useState } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from 'sonner';

export function CreatePostForm() {
  const [title, setTitle] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const createPost = useMutation(api.functions.posts.createPost);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!title.trim()) {
      toast.error('Title is required');
      return;
    }

    setIsLoading(true);
    try {
      await createPost({ title });
      toast.success('Post created!');
      setTitle('');
    } catch (error: any) {
      toast.error(error.message || 'Something went wrong');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          placeholder="Enter title..."
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          disabled={isLoading}
        />
      </div>
      <Button type="submit" disabled={isLoading}>
        {isLoading ? 'Creating...' : 'Create Post'}
      </Button>
    </form>
  );
}
```

---

## Form with Multiple Fields

```typescript
'use client';

import { useState } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Switch } from '@/components/ui/switch';
import { toast } from 'sonner';

interface FormData {
  title: string;
  content: string;
  category: string;
  published: boolean;
}

export function CreatePostForm() {
  const [formData, setFormData] = useState<FormData>({
    title: '',
    content: '',
    category: '',
    published: false,
  });
  const [isLoading, setIsLoading] = useState(false);

  const createPost = useMutation(api.functions.posts.createPost);

  const updateField = <K extends keyof FormData>(
    field: K,
    value: FormData[K]
  ) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validation
    if (!formData.title.trim()) {
      toast.error('Title is required');
      return;
    }
    if (!formData.content.trim()) {
      toast.error('Content is required');
      return;
    }
    if (!formData.category) {
      toast.error('Please select a category');
      return;
    }

    setIsLoading(true);
    try {
      await createPost(formData);
      toast.success('Post created!');
      setFormData({
        title: '',
        content: '',
        category: '',
        published: false,
      });
    } catch (error: any) {
      toast.error(error.message || 'Something went wrong');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Title */}
      <div className="space-y-2">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          placeholder="Enter title..."
          value={formData.title}
          onChange={(e) => updateField('title', e.target.value)}
          disabled={isLoading}
        />
      </div>

      {/* Content */}
      <div className="space-y-2">
        <Label htmlFor="content">Content</Label>
        <Textarea
          id="content"
          placeholder="Write your content..."
          value={formData.content}
          onChange={(e) => updateField('content', e.target.value)}
          disabled={isLoading}
          rows={6}
        />
      </div>

      {/* Category Select */}
      <div className="space-y-2">
        <Label htmlFor="category">Category</Label>
        <Select
          value={formData.category}
          onValueChange={(value) => updateField('category', value)}
          disabled={isLoading}
        >
          <SelectTrigger>
            <SelectValue placeholder="Select category" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="tech">Technology</SelectItem>
            <SelectItem value="design">Design</SelectItem>
            <SelectItem value="business">Business</SelectItem>
            <SelectItem value="lifestyle">Lifestyle</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Published Switch */}
      <div className="flex items-center justify-between">
        <div className="space-y-0.5">
          <Label htmlFor="published">Publish immediately</Label>
          <p className="text-sm text-muted-foreground">
            Make this post visible to everyone
          </p>
        </div>
        <Switch
          id="published"
          checked={formData.published}
          onCheckedChange={(checked) => updateField('published', checked)}
          disabled={isLoading}
        />
      </div>

      {/* Submit */}
      <div className="flex justify-end gap-3">
        <Button type="button" variant="outline" disabled={isLoading}>
          Cancel
        </Button>
        <Button type="submit" disabled={isLoading}>
          {isLoading ? 'Creating...' : 'Create Post'}
        </Button>
      </div>
    </form>
  );
}
```

---

## Edit Form Pattern

```typescript
'use client';

import { useState, useEffect } from 'react';
import { useQuery, useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Id } from '@/convex/_generated/dataModel';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';
import { toast } from 'sonner';

interface EditPostFormProps {
  postId: Id<'posts'>;
  onSuccess?: () => void;
}

export function EditPostForm({ postId, onSuccess }: EditPostFormProps) {
  const post = useQuery(api.functions.posts.getPost, { id: postId });
  const updatePost = useMutation(api.functions.posts.updatePost);

  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Initialize form when data loads
  useEffect(() => {
    if (post) {
      setTitle(post.title);
      setContent(post.content);
    }
  }, [post]);

  // Loading state
  if (post === undefined) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-10 w-full" />
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-10 w-24" />
      </div>
    );
  }

  // Not found
  if (post === null) {
    return (
      <div className="text-center text-muted-foreground">Post not found</div>
    );
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!title.trim()) {
      toast.error('Title is required');
      return;
    }

    setIsLoading(true);
    try {
      await updatePost({ id: postId, title, content });
      toast.success('Post updated!');
      onSuccess?.();
    } catch (error: any) {
      toast.error(error.message || 'Failed to update');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          disabled={isLoading}
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="content">Content</Label>
        <Textarea
          id="content"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          disabled={isLoading}
          rows={6}
        />
      </div>

      <div className="flex justify-end gap-3">
        <Button type="button" variant="outline" disabled={isLoading}>
          Cancel
        </Button>
        <Button type="submit" disabled={isLoading}>
          {isLoading ? 'Saving...' : 'Save Changes'}
        </Button>
      </div>
    </form>
  );
}
```

---

## Form in Dialog Pattern

```typescript
'use client';

import { useState } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Plus } from 'lucide-react';
import { toast } from 'sonner';

export function CreatePostDialog() {
  const [open, setOpen] = useState(false);
  const [title, setTitle] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const createPost = useMutation(api.functions.posts.createPost);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!title.trim()) {
      toast.error('Title is required');
      return;
    }

    setIsLoading(true);
    try {
      await createPost({ title });
      toast.success('Post created!');
      setTitle('');
      setOpen(false);
    } catch (error: any) {
      toast.error(error.message || 'Something went wrong');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button>
          <Plus className="mr-2 h-4 w-4" />
          Create Post
        </Button>
      </DialogTrigger>
      <DialogContent className="sm:max-w-md">
        <form onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>Create Post</DialogTitle>
            <DialogDescription>
              Add a new post to your collection.
            </DialogDescription>
          </DialogHeader>

          <div className="py-4 space-y-4">
            <div className="space-y-2">
              <Label htmlFor="dialog-title">Title</Label>
              <Input
                id="dialog-title"
                placeholder="Enter title..."
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                disabled={isLoading}
              />
            </div>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={() => setOpen(false)}
              disabled={isLoading}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={isLoading}>
              {isLoading ? 'Creating...' : 'Create'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}
```

---

## Delete Confirmation Pattern

```typescript
'use client';

import { useState } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Id } from '@/convex/_generated/dataModel';
import { Button } from '@/components/ui/button';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { Trash2 } from 'lucide-react';
import { toast } from 'sonner';

interface DeletePostButtonProps {
  postId: Id<'posts'>;
  postTitle: string;
  onSuccess?: () => void;
}

export function DeletePostButton({
  postId,
  postTitle,
  onSuccess,
}: DeletePostButtonProps) {
  const [isLoading, setIsLoading] = useState(false);
  const deletePost = useMutation(api.functions.posts.deletePost);

  const handleDelete = async () => {
    setIsLoading(true);
    try {
      await deletePost({ id: postId });
      toast.success('Post deleted');
      onSuccess?.();
    } catch (error: any) {
      toast.error(error.message || 'Failed to delete');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <Button variant="destructive" size="sm">
          <Trash2 className="h-4 w-4" />
        </Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Delete Post</AlertDialogTitle>
          <AlertDialogDescription>
            Are you sure you want to delete "{postTitle}"? This action cannot be
            undone.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={isLoading}>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={handleDelete}
            disabled={isLoading}
            className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
          >
            {isLoading ? 'Deleting...' : 'Delete'}
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
```

---

## Search/Filter Form Pattern

```typescript
'use client';

import { useState } from 'react';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Search } from 'lucide-react';

interface FilterState {
  search: string;
  category: string;
  sortBy: string;
}

interface SearchFilterProps {
  onFilterChange: (filters: FilterState) => void;
}

export function SearchFilter({ onFilterChange }: SearchFilterProps) {
  const [filters, setFilters] = useState<FilterState>({
    search: '',
    category: 'all',
    sortBy: 'newest',
  });

  const updateFilter = <K extends keyof FilterState>(
    key: K,
    value: FilterState[K]
  ) => {
    const newFilters = { ...filters, [key]: value };
    setFilters(newFilters);
    onFilterChange(newFilters);
  };

  return (
    <div className="flex flex-col sm:flex-row gap-4">
      {/* Search */}
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
        <Input
          placeholder="Search posts..."
          value={filters.search}
          onChange={(e) => updateFilter('search', e.target.value)}
          className="pl-9"
        />
      </div>

      {/* Category Filter */}
      <Select
        value={filters.category}
        onValueChange={(value) => updateFilter('category', value)}
      >
        <SelectTrigger className="w-full sm:w-40">
          <SelectValue placeholder="Category" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="all">All Categories</SelectItem>
          <SelectItem value="tech">Technology</SelectItem>
          <SelectItem value="design">Design</SelectItem>
          <SelectItem value="business">Business</SelectItem>
        </SelectContent>
      </Select>

      {/* Sort */}
      <Select
        value={filters.sortBy}
        onValueChange={(value) => updateFilter('sortBy', value)}
      >
        <SelectTrigger className="w-full sm:w-32">
          <SelectValue placeholder="Sort" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="newest">Newest</SelectItem>
          <SelectItem value="oldest">Oldest</SelectItem>
          <SelectItem value="popular">Popular</SelectItem>
        </SelectContent>
      </Select>
    </div>
  );
}
```

---

## File Upload Form Pattern

```typescript
'use client';

import { useState, useRef } from 'react';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Upload, X } from 'lucide-react';
import { toast } from 'sonner';

export function ImageUploadForm() {
  const [file, setFile] = useState<File | null>(null);
  const [preview, setPreview] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const generateUploadUrl = useMutation(api.functions.files.generateUploadUrl);
  const saveImage = useMutation(api.functions.files.saveImage);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (!selectedFile) return;

    // Validate type
    if (!selectedFile.type.startsWith('image/')) {
      toast.error('Please select an image file');
      return;
    }

    // Validate size (5MB max)
    if (selectedFile.size > 5 * 1024 * 1024) {
      toast.error('Image must be less than 5MB');
      return;
    }

    setFile(selectedFile);
    setPreview(URL.createObjectURL(selectedFile));
  };

  const handleRemove = () => {
    setFile(null);
    setPreview(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleUpload = async () => {
    if (!file) return;

    setIsLoading(true);
    try {
      // Get upload URL from Convex
      const uploadUrl = await generateUploadUrl();

      // Upload to Convex storage
      const result = await fetch(uploadUrl, {
        method: 'POST',
        headers: { 'Content-Type': file.type },
        body: file,
      });

      const { storageId } = await result.json();

      // Save reference in database
      await saveImage({ storageId, fileName: file.name });

      toast.success('Image uploaded!');
      handleRemove();
    } catch (error: any) {
      toast.error(error.message || 'Upload failed');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-4">
      <Label>Image</Label>

      {preview ? (
        <div className="relative w-full max-w-xs">
          <img
            src={preview}
            alt="Preview"
            className="w-full h-48 object-cover rounded-lg border"
          />
          <Button
            type="button"
            variant="destructive"
            size="icon"
            className="absolute top-2 right-2"
            onClick={handleRemove}
          >
            <X className="h-4 w-4" />
          </Button>
        </div>
      ) : (
        <div
          onClick={() => fileInputRef.current?.click()}
          className="border-2 border-dashed rounded-lg p-8 text-center cursor-pointer hover:border-primary transition-colors"
        >
          <Upload className="h-8 w-8 mx-auto text-muted-foreground" />
          <p className="mt-2 text-sm text-muted-foreground">
            Click to upload image
          </p>
          <p className="text-xs text-muted-foreground">PNG, JPG up to 5MB</p>
        </div>
      )}

      <Input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
      />

      {file && (
        <Button onClick={handleUpload} disabled={isLoading}>
          {isLoading ? 'Uploading...' : 'Upload Image'}
        </Button>
      )}
    </div>
  );
}
```

---

## Zod Validation Pattern

For complex forms, use Zod for type-safe validation:

### Setup

```bash
npm install zod react-hook-form @hookform/resolvers
```

### Form with Zod

```typescript
'use client';

import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { toast } from 'sonner';

// Define schema
const postSchema = z.object({
  title: z.string()
    .min(1, 'Title is required')
    .max(100, 'Title must be 100 characters or less'),
  content: z.string()
    .min(10, 'Content must be at least 10 characters')
    .max(5000, 'Content must be 5000 characters or less'),
  email: z.string()
    .email('Invalid email address')
    .optional()
    .or(z.literal('')),
  url: z.string()
    .url('Invalid URL')
    .optional()
    .or(z.literal('')),
});

type PostFormData = z.infer<typeof postSchema>;

export function CreatePostFormWithZod() {
  const createPost = useMutation(api.functions.posts.createPost);

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<PostFormData>({
    resolver: zodResolver(postSchema),
    defaultValues: {
      title: '',
      content: '',
      email: '',
      url: '',
    },
  });

  const onSubmit = async (data: PostFormData) => {
    try {
      await createPost(data);
      toast.success('Post created!');
      reset();
    } catch (error: any) {
      toast.error(error.message || 'Something went wrong');
    }
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="title">Title</Label>
        <Input
          id="title"
          {...register('title')}
          disabled={isSubmitting}
        />
        {errors.title && (
          <p className="text-sm text-destructive">{errors.title.message}</p>
        )}
      </div>

      <div className="space-y-2">
        <Label htmlFor="content">Content</Label>
        <Textarea
          id="content"
          {...register('content')}
          disabled={isSubmitting}
          rows={6}
        />
        {errors.content && (
          <p className="text-sm text-destructive">{errors.content.message}</p>
        )}
      </div>

      <Button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Creating...' : 'Create Post'}
      </Button>
    </form>
  );
}
```

### Common Zod Patterns

```typescript
// Required string
z.string().min(1, 'Required')

// Optional string
z.string().optional()

// Email
z.string().email('Invalid email')

// URL
z.string().url('Invalid URL')

// Number with range
z.number().min(0).max(100)

// Enum
z.enum(['draft', 'published', 'archived'])

// Date
z.date().min(new Date(), 'Must be in the future')

// Password confirmation
const schema = z.object({
  password: z.string().min(8, 'Password must be 8+ characters'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
});

// Conditional validation
z.object({
  type: z.enum(['email', 'phone']),
  contact: z.string(),
}).refine((data) => {
  if (data.type === 'email') {
    return z.string().email().safeParse(data.contact).success;
  }
  return /^\d{10}$/.test(data.contact);
}, {
  message: 'Invalid contact format',
  path: ['contact'],
});
```

---

## Best Practices

### Always Do

- Handle loading states
- Show validation errors with toast
- Disable inputs while submitting
- Clear form on success
- Use proper Labels for accessibility
- Handle keyboard submit (Enter key)

### Never Do

- Validate on every keystroke (too annoying)
- Show multiple toasts at once
- Leave form hanging after error
- Forget to handle submit button state
- Use alert() for errors

---

*Build forms fast. Handle all states.*
