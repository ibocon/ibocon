export interface PostFilterEntry {
  title: string;
  description: string;
  category: string;
  tags: string[];
}

const ALL_CATEGORY = 'all';

export function normalizeForSearch(value: string): string {
  return value.normalize('NFC').trim().toLowerCase();
}

export function matchesSearch(post: PostFilterEntry, rawQuery: string): boolean {
  const query = normalizeForSearch(rawQuery);
  if (query.length === 0) {
    return true;
  }
  const haystack = [post.title, post.description, post.category, ...post.tags]
    .map((value) => normalizeForSearch(value))
    .join(' ');
  return haystack.includes(query);
}

export function isPostVisible(post: PostFilterEntry, rawQuery: string, activeCategory: string): boolean {
  const categoryMatches = activeCategory === ALL_CATEGORY || post.category === activeCategory;
  return categoryMatches && matchesSearch(post, rawQuery);
}
