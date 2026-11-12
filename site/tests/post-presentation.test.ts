import { describe, expect, it } from 'vitest';
import { getPostPresentation } from '../src/lib/post-presentation';

describe('Post presentation', () => {
  it('Given_ExplicitCover_When_Presented_Then_PrefersItAndRoundsReadingTimeUp', () => {
    // Given
    const markdown = 'word '.repeat(301);

    // When
    const presentation = getPostPresentation({ coverImage: '/post-covers/example.svg', tags: ['architecture'] }, markdown);

    // Then
    expect(presentation.coverImage).toBe('/post-covers/example.svg');
    expect(presentation.readingMinutes).toBe(2);
  });

  it('Given_LocalMarkdownImage_When_Presented_Then_UsesTheFirstImage', () => {
    // Given
    const markdown = '![First](/blog-images/1/1.png)\n![Second](/blog-images/2/1.png)';

    // When
    const presentation = getPostPresentation({ tags: ['frontend'] }, markdown);

    // Then
    expect(presentation.coverImage).toBe('/blog-images/1/1.png');
  });

  it('Given_CodeFenceImage_When_Presented_Then_UsesTagSvgFallback', () => {
    // Given
    const markdown = '```md\n![Ignored](/blog-images/1/1.png)\n```';

    // When
    const presentation = getPostPresentation({ tags: ['security'] }, markdown);

    // Then
    expect(presentation.coverImage).toContain('data:image/svg+xml,');
    expect(decodeURIComponent(presentation.coverImage)).toContain('security');
  });

  it('Given_CodeAndImageSyntax_When_Presented_Then_ExcludesThemAndKeepsOneMinuteMinimum', () => {
    // Given
    const markdown = '```ts\nconst ignored = 500;\n```\n![Diagram](/blog-images/1/1.png)\n짧은 본문';

    // When
    const presentation = getPostPresentation({ tags: ['architecture'] }, markdown);

    // Then
    expect(presentation.readingMinutes).toBe(1);
  });
});
