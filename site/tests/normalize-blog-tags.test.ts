import { describe, expect, it } from 'vitest';
import { normalizeFrontMatter } from '../scripts/normalize-blog-tags.mjs';

describe('Blog tag normalization', () => {
  it('Given_CategoryAndTistoryTag_When_Normalized_Then_PreservesOnePublicTagAndSource', () => {
    // Given
    const source = '---\ncategory: "dotnet"\ntags: ["dotnet", "tistory"]\n---\n';

    // When
    const actual = normalizeFrontMatter(source);

    // Then
    expect(actual).not.toContain('category:');
    expect(actual).toContain('tags: ["dotnet"]');
    expect(actual).toContain('source: "tistory"');
  });
});
