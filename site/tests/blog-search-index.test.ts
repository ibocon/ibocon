import { describe, expect, it } from 'vitest';
import { toSearchEntry } from '../src/lib/blog-search-index';
import { findSlugViolation } from '../src/lib/blog-slug';

describe('Blog search index', () => {
  it('Given_Post_When_ToSearchEntry_Then_KeepsOnlyFieldsTheSearchNeeds', () => {
    // Given
    const post = {
      id: 'clean-architecture-rich-domain',
      data: { title: '제목', description: '설명', tags: ['ddd'], pubDate: new Date('2026-11-01T00:00:00Z') },
    };

    // When
    const entry = toSearchEntry(post);

    // Then
    expect(entry).toEqual({
      title: '제목',
      description: '설명',
      tags: ['ddd'],
      href: '/clean-architecture-rich-domain/',
      date: '2026-11-01',
    });
  });

  it('Given_NewRoutePrefixes_When_FindSlugViolation_Then_ReservesPageTagsAndIndex', () => {
    // Given
    // When
    // Then
    expect(findSlugViolation('page')).toBe('reserved');
    expect(findSlugViolation('tags')).toBe('reserved');
    expect(findSlugViolation('search-index.json')).toBe('format');
  });
});
