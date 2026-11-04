import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const dist = resolve(process.cwd(), 'dist');
const readBuiltPage = (...segments: string[]) => readFileSync(resolve(dist, ...segments, 'index.html'), 'utf8');
const localeMenu = (html: string) => html.match(/<details class="locale-menu"[\s\S]*?<\/details>/)?.[0] ?? '';

describe('Blog locale dropdown', () => {
  it('Given_BuiltKoreanHome_When_InspectingLocaleMenu_Then_MarksKoreanCurrentAndLinksEnglish', () => {
    // Given
    const menu = localeMenu(readBuiltPage());

    // When
    const summary = menu.match(/<summary[\s\S]*?<\/summary>/)?.[0] ?? '';

    // Then
    expect(menu).toContain('data-locale-menu');
    expect(summary).toContain('aria-label="언어 선택: 한국어"');
    expect(menu).toMatch(/<a href="\/"[^>]*aria-current="true"[^>]*>\s*한국어\s*<\/a>/);
    expect(menu).toMatch(/<a href="\/en\/"[^>]*lang="en"[^>]*>\s*English\s*<\/a>/);
  });

  it('Given_BuiltEnglishAbout_When_InspectingLocaleMenu_Then_MarksEnglishCurrentAndLinksKoreanAbout', () => {
    // Given
    const menu = localeMenu(readBuiltPage('en', 'about'));

    // Then
    expect(menu).toContain('aria-label="Select language: English"');
    expect(menu).toMatch(/<a href="\/en\/about\/"[^>]*aria-current="true"[^>]*>\s*English\s*<\/a>/);
    expect(menu).toMatch(/<a href="\/about\/"[^>]*lang="ko"[^>]*>\s*한국어\s*<\/a>/);
  });

  it('Given_BuiltKoreanPost_When_InspectingLocaleMenu_Then_LinksLocaleHomesWithoutClaimingTranslation', () => {
    // Given
    const menu = localeMenu(readBuiltPage('web-api-websocket'));

    // Then
    expect(menu).toMatch(/<a href="\/en\/"[^>]*>\s*English\s*<\/a>/);
    expect(menu).not.toContain('/en/web-api-websocket/');
  });
});
