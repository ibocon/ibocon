export interface PostFilterEntry {
  title: string;
  description: string;
  tags: string[];
}

const ALL_TAG = 'all';

export function normalizeForSearch(value: string): string {
  return value.normalize('NFC').trim().toLowerCase();
}

export function getSearchScore(post: PostFilterEntry, rawQuery: string): number {
  const query = normalizeForSearch(rawQuery);
  if (query.length === 0) {
    return 0;
  }

  if (normalizeForSearch(post.title).includes(query)) {
    return 3;
  }

  if (post.tags.some((tag) => normalizeForSearch(tag).includes(query))) {
    return 2;
  }

  return normalizeForSearch(post.description).includes(query) ? 1 : -1;
}

export function compareSearchRelevance(left: PostFilterEntry, right: PostFilterEntry, query: string): number {
  return getSearchScore(right, query) - getSearchScore(left, query);
}

export function matchesSearch(post: PostFilterEntry, rawQuery: string): boolean {
  return getSearchScore(post, rawQuery) >= 0;
}

export function matchesTag(post: PostFilterEntry, activeTag: string): boolean {
  return activeTag === ALL_TAG || post.tags.includes(activeTag);
}

export function isPostVisible(
  post: PostFilterEntry,
  rawQuery: string,
  activeTag: string = ALL_TAG,
): boolean {
  return matchesTag(post, activeTag) && matchesSearch(post, rawQuery);
}
