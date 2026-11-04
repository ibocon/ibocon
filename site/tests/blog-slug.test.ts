import { existsSync, readFileSync, readdirSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { buildRedirects } from '../scripts/generate-blog-redirects.mjs';
import { findSlugViolation } from '../src/lib/blog-slug';

const blogRoot = resolve(__dirname, '..', '..', 'blog');
const manifest: { tistoryId?: string; legacyPath: string; slug: string }[] =
  JSON.parse(readFileSync(resolve(__dirname, '..', 'scripts', 'blog-slugs.json'), 'utf8'));

describe('blog slug surface', () => {
  it('Given_SlugCandidates_When_Checked_Then_RejectsTemporaryReservedAndMalformed', () => {
    // Given
    const candidates = ['spring-bean', '2020-04-12-spring-bean', 'tistory-169', 'about', 'Spring_Bean'];

    // When
    const violations = candidates.map(findSlugViolation);

    // Then
    expect(violations).toEqual([null, 'temporary', 'temporary', 'reserved', 'format']);
  });

  it('Given_BlogDirectory_When_Listed_Then_FlatMarkdownFilesWithValidSlugs', () => {
    // Given
    const entries = readdirSync(blogRoot, { withFileTypes: true });

    // When
    const directories = entries.filter((entry) => entry.isDirectory());
    const slugs = entries.filter((entry) => entry.name.endsWith('.md')).map((entry) => entry.name.replace(/\.md$/, ''));

    // Then
    expect(directories).toHaveLength(0);
    expect(slugs.filter((slug) => findSlugViolation(slug) !== null && !/^tistory-\d+$/.test(slug))).toEqual([]);
  });

  it('Given_TemporaryNamedPosts_When_Loaded_Then_AllAreDrafts', () => {
    // Given
    const temporary = readdirSync(blogRoot).filter((name) => /^tistory-\d+\.md$/.test(name));

    // When
    const published = temporary.filter((name) => !readFileSync(resolve(blogRoot, name), 'utf8').includes('draft: true'));

    // Then
    expect(published).toEqual([]);
  });

  it('Given_Manifest_When_Compared_Then_EverySlugHasFileAndIsUnique', () => {
    // Given
    const slugs = manifest.map((entry) => entry.slug);

    // When
    const missing = slugs.filter((slug) => !existsSync(resolve(blogRoot, `${slug}.md`)));

    // Then
    expect(new Set(slugs).size).toBe(slugs.length);
    expect(new Set(manifest.map((entry) => entry.legacyPath)).size).toBe(manifest.length);
    expect(slugs.filter((slug) => findSlugViolation(slug) !== null)).toEqual([]);
    expect(missing).toEqual([]);
  });

  it('Given_Manifest_When_RedirectsBuilt_Then_LegacyPathsMapTo301WithAndWithoutSlash', () => {
    // Given
    const sample = [{ legacyPath: '/backend/2020-04-12-tistory-169/', slug: 'spring-security-architecture' }];

    // When
    const redirects = buildRedirects(sample);

    // Then
    expect(redirects).toContain('/backend/2020-04-12-tistory-169/ /spring-security-architecture/ 301');
    expect(redirects).toContain('/backend/2020-04-12-tistory-169 /spring-security-architecture/ 301');
  });
});
