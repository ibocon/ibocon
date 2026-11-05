import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const readBuiltPage = (...segments: string[]) =>
  readFileSync(resolve(process.cwd(), 'dist', ...segments, 'index.html'), 'utf8');
const utility = (html: string) =>
  html.match(/<div class="header-nav-utility">([\s\S]*?)<\/div>\s*<details/)?.[1] ?? '';

describe('Blog header icon links', () => {
  it('Given_BuiltKoreanHome_When_InspectingUtility_Then_GithubAndRssAreLabelledIconLinks', () => {
    // Given
    const html = utility(readBuiltPage());

    // Then
    expect(html).toMatch(/<a class="icon-button" href="https:\/\/github\.com\/ibocon"[^>]*rel="noopener noreferrer"[^>]*aria-label="GitHub"/);
    expect(html).toMatch(/<a class="icon-button" href="\/rss\.xml"[^>]*aria-label="RSS"/);
    expect(html.match(/<svg[^>]*aria-hidden="true"/g)).toHaveLength(2);
  });

  it('Given_BuiltEnglishHome_When_InspectingUtility_Then_NoVisibleTextLabelsRemain', () => {
    // Given
    const html = utility(readBuiltPage('en'));

    // When
    const visibleText = html.replace(/<svg[\s\S]*?<\/svg>/g, '').replace(/<[^>]+>/g, '').trim();

    // Then
    expect(visibleText).toBe('');
  });
});
