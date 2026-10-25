export interface PostFilterEntry {
  title: string;
  description: string;
  category: string;
  tags: string[];
}

const ALL_CATEGORY = 'all';
const ALL_TAG = 'all';

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

export function matchesTag(post: PostFilterEntry, activeTag: string): boolean {
  return activeTag === ALL_TAG || post.tags.includes(activeTag);
}

export function isPostVisible(
  post: PostFilterEntry,
  rawQuery: string,
  activeCategory: string,
  activeTag: string = ALL_TAG,
): boolean {
  const categoryMatches = activeCategory === ALL_CATEGORY || post.category === activeCategory;
  const tagMatches = matchesTag(post, activeTag);
  return categoryMatches && tagMatches && matchesSearch(post, rawQuery);
}
