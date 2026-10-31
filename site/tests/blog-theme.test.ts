import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

describe('Blog theme and content rendering', () => {
  it('Given_PostTemplateAndStyles_When_Inspected_Then_UsesBoundedProseAndAccessibleToc', () => {
    // Given
    const styles = readFileSync(resolve(process.cwd(), 'src/styles/global.css'), 'utf8');
    const index = readFileSync(resolve(process.cwd(), 'src/pages/index.astro'), 'utf8');
    const post = readFileSync(resolve(process.cwd(), 'src/pages/[...slug].astro'), 'utf8');
    const header = readFileSync(resolve(process.cwd(), 'src/components/Header.astro'), 'utf8');

    // When
    const hasBoundedProse = styles.includes('--prose-measure: 46rem');

    // Then
    expect(hasBoundedProse).toBe(true);
    expect(styles).toContain('grid-template-columns: minmax(0, var(--prose-measure))');
    expect(styles).toContain(':focus-visible');
    expect(styles).toContain('white-space: pre !important');
    expect(styles).toContain('overflow-wrap: normal');
    expect(styles).toContain('word-break: normal');
    expect(styles).toContain('.adsense-container { max-width: 100%; min-width: 0; overflow-x: clip; }');
    expect(styles).toContain('.adsense-container .adsbygoogle { display: block; max-width: 100%; min-width: 0; }');
    expect(header).toContain('id="theme-toggle"');
    expect(header).toContain('class="theme-icon"');
    expect(header).toContain('aria-pressed');
    expect(header).not.toContain('>Theme</button>');
    expect(styles).toContain('.theme-toggle { inline-size: 36px; block-size: 36px;');
    expect(styles).toContain('.theme-icon { inline-size: 18px; block-size: 18px; }');
    expect(index).toContain('class="post-card"');
    expect(index).not.toContain('data-category');
    expect(post).toContain('class="container post-layout"');
    expect(post).toContain('aria-labelledby="post-title"');
    expect(post).toContain('aria-label="Table of Contents"');
  });

  it('Given_HomePageMarkup_When_Inspected_Then_RendersProgressiveTagFilterWithPressedState', () => {
    // Given
    const index = readFileSync(resolve(process.cwd(), 'src/pages/index.astro'), 'utf8');

    // When
    const hasTagFilter = index.includes('id="tag-filter"') && index.includes('aria-label="게시물 태그"');

    // Then
    expect(hasTagFilter).toBe(true);
    expect(index).toContain('태그로 좁히기');
    expect(index).toContain('전체 태그');
    expect(index).toContain('data-tag="all"');
    expect(index).toContain('data-tag={tag}');
    expect(index).toContain('isPostVisible(entry, query, activeTag)');
  });

  it('Given_GlobalStyles_When_Inspected_Then_HiddenAttributeOverridesComponentDisplay', () => {
    // Given
    const styles = readFileSync(resolve(process.cwd(), 'src/styles/global.css'), 'utf8');

    // When
    const hiddenRule = styles.match(/\[hidden\]\s*\{[^}]*display:\s*none\s*!important/);

    // Then
    expect(hiddenRule).not.toBeNull();
  });

  it('Given_Header_When_Inspected_Then_DefinesDeploymentRefreshContract', () => {
    // Given
    const header = readFileSync(resolve(process.cwd(), 'src/components/Header.astro'), 'utf8');

    // When
    // Then
    expect(header).toContain('data-deployment-id');
    expect(header).toContain('GITHUB_RUN_ID');
    expect(header).toContain("cache: 'no-store'");
    expect(header).toContain('document.visibilityState');
    expect(header).toContain('window.location.reload()');
  });
});
