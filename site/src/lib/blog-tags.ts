export const BLOG_TAGS = [
  'architecture',
  'backend',
  'clean-architecture',
  'csharp',
  'ddd',
  'dotnet',
  'frontend',
  'kubernetes',
  'maui',
  'observability',
  'postfix',
  'security',
] as const;

export type BlogTag = (typeof BLOG_TAGS)[number];

export function normalizeTags(tags: readonly string[]): string[] {
  return [...new Set(tags.map((tag) => tag.trim().toLowerCase()).filter(Boolean))];
}
