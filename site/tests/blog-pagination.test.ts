import { describe, expect, it } from 'vitest';
import { paginate, pagePath } from '../src/lib/blog-pagination';

const stubItems = (count: number) => Array.from({ length: count }, (_, index) => `post-${index + 1}`);

describe('Blog pagination', () => {
  it('Given_105Items_When_PaginatedBy12_Then_Makes9PagesWithLastHolding9', () => {
    // Given
    const items = stubItems(105);

    // When
    const slices = paginate(items, 12, '/');

    // Then
    expect(slices).toHaveLength(9);
    expect(slices[0].items).toHaveLength(12);
    expect(slices[8].items).toHaveLength(9);
  });

  it('Given_FirstAndLastPage_When_Paginated_Then_PrevNextAreNullAtEdges', () => {
    // Given
    const slices = paginate(stubItems(30), 12, '/');

    // When
    // Then
    expect(slices[0].prevHref).toBeNull();
    expect(slices[0].nextHref).toBe('/page/2/');
    expect(slices[2].nextHref).toBeNull();
  });

  it('Given_TagBasePath_When_PagePath_Then_KeepsPageOneAtTheBase', () => {
    // Given
    // When
    // Then
    expect(pagePath('/tags/ddd/', 1)).toBe('/tags/ddd/');
    expect(pagePath('/tags/ddd/', 3)).toBe('/tags/ddd/page/3/');
  });

  it('Given_NoItems_When_Paginated_Then_ReturnsOneEmptyPage', () => {
    // Given
    // When
    const slices = paginate([], 12, '/');

    // Then
    expect(slices).toHaveLength(1);
    expect(slices[0].items).toEqual([]);
  });
});
