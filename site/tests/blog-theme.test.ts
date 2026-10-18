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
    expect(header).toContain('id="theme-toggle"');
    expect(index).toContain('class="post-card"');
    expect(index).toContain('data-category');
    expect(post).toContain('class="container post-layout"');
    expect(post).toContain('aria-labelledby="post-title"');
    expect(post).toContain('aria-label="Table of Contents"');
  });
});
