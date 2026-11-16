import type { PostFilterEntry } from './blog-filter';

export interface SearchEntry extends PostFilterEntry {
  href: string;
  date: string;
}

export function toSearchEntry(post: {
  id: string;
  data: { title: string; description: string; tags: string[]; pubDate: Date };
}): SearchEntry {
  return {
    title: post.data.title,
    description: post.data.description,
    tags: post.data.tags,
    href: `/${post.id}/`,
    date: post.data.pubDate.toISOString().slice(0, 10),
  };
}
