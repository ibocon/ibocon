import { createMarkdownProcessor } from '@astrojs/markdown-remark';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import astroConfig from '../astro.config.mjs';
import { getTocHeadings } from '../src/lib/toc';

const markdown = '본문에 용어[^a]를 쓴다.\n\n## 다음 절\n\n[^a]: 용어의 설명이다.\n';

describe('Footnotes', () => {
  it('Given_FootnoteMarkdown_When_Rendered_Then_UsesKoreanLabels', async () => {
    // Given
    const processor = await createMarkdownProcessor(astroConfig.markdown);

    // When
    const { code } = await processor.render(markdown);

    // Then
    expect(code).toContain('data-footnote-ref');
    expect(code).toContain('>각주</h2>');
    expect(code).toContain('본문으로 돌아가기');
    expect(code).not.toContain('Footnotes');
    expect(code).not.toContain('Back to reference');
  });

  it('Given_FootnoteHeading_When_BuildingToc_Then_ExcludesIt', async () => {
    // Given
    const processor = await createMarkdownProcessor(astroConfig.markdown);
    const { metadata } = await processor.render(markdown);

    // When
    const toc = getTocHeadings(metadata.headings);

    // Then
    expect(metadata.headings.map((heading) => heading.slug)).toContain('footnote-label');
    expect(toc.map((heading) => heading.text)).toEqual(['다음 절']);
  });

  it('Given_Stylesheet_When_Inspected_Then_HidesFootnoteHeadingVisually', () => {
    // Given
    const css = readFileSync(resolve(process.cwd(), 'src/styles/global.css'), 'utf-8');

    // When / Then
    expect(css).toMatch(/\.sr-only\s*\{[^}]*clip:/);
    expect(css).toContain('.prose .footnotes');
  });
});
