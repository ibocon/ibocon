import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

describe('Blog theme and content rendering', () => {
  it('includes the theme toggle, cards, category filter, and TOC contract', () => {
    const index = readFileSync(resolve(process.cwd(), 'src/pages/index.astro'), 'utf8');
    const post = readFileSync(resolve(process.cwd(), 'src/pages/[...slug].astro'), 'utf8');
    const header = readFileSync(resolve(process.cwd(), 'src/components/Header.astro'), 'utf8');
    expect(header).toContain('id="theme-toggle"');
    expect(index).toContain('class="post-card"');
    expect(index).toContain('data-category');
    expect(post).toContain('aria-label="Table of Contents"');
  });
});
