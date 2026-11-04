// ✅ 글 슬러그 규약: 소문자 영숫자와 하이픈, 예약 경로·임시 패턴 금지
export const RESERVED_SLUGS: ReadonlySet<string> = new Set([
  'about', 'resume', 'en', 'editorial-policy', 'rss.xml', 'blog-images', 'sitemap-index', '404',
]);

const SLUG_PATTERN = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const TEMPORARY_PATTERN = /^\d{4}-\d{2}-\d{2}(?:-|$)|(?:^|-)tistory-\d+$/;
const MAX_SLUG_LENGTH = 80;

export type SlugViolation = 'format' | 'tooLong' | 'reserved' | 'temporary';

export function findSlugViolation(slug: string): SlugViolation | null {
  if (TEMPORARY_PATTERN.test(slug)) return 'temporary';
  if (!SLUG_PATTERN.test(slug)) return 'format';
  if (slug.length > MAX_SLUG_LENGTH) return 'tooLong';
  if (RESERVED_SLUGS.has(slug)) return 'reserved';
  return null;
}
