import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const dist = resolve(process.cwd(), 'dist');
const readBuiltPage = (...segments: string[]) => readFileSync(resolve(dist, ...segments, 'index.html'), 'utf8');

describe('Blog locale surface', () => {
  it('Given_BuiltTrustPages_When_InspectingLocales_Then_PublishesKoreanAndEnglishWithMatchedAlternates', () => {
    // Given
    const koreanAbout = readBuiltPage('about');
    const englishAbout = readBuiltPage('en', 'about');
    const koreanEditorial = readBuiltPage('editorial-policy');
    const englishEditorial = readBuiltPage('en', 'editorial-policy');

    // When
    const englishTrustRoutes = [resolve(dist, 'en', 'index.html'), resolve(dist, 'en', 'about', 'index.html'), resolve(dist, 'en', 'editorial-policy', 'index.html')];

    // Then
    englishTrustRoutes.forEach((route) => expect(existsSync(route)).toBe(true));
    expect(koreanAbout).toContain('<html lang="ko"');
    expect(englishAbout).toContain('<html lang="en"');
    expect(englishAbout).toContain('Yegun Kim (김예건)');
    expect(englishEditorial).toContain('Source attribution and migration');
    expect(englishEditorial).toContain('Advertising and editorial independence');
    [koreanAbout, koreanEditorial].forEach((html) => {
      expect(html).toContain('hreflang="en"');
      expect(html).toContain('https://blog.botanicsoft.com/en/');
    });
    expect(englishAbout).toContain('hreflang="ko"');
    expect(englishAbout).toContain('https://blog.botanicsoft.com/about/');
    expect(englishEditorial).toContain('hreflang="ko"');
    expect(englishEditorial).toContain('https://blog.botanicsoft.com/editorial-policy/');
  });

  it('Given_BuiltKoreanPostsAndRss_When_InspectingEnglishRoutes_Then_DoesNotClaimUntranslatedPosts', () => {
    // Given
    const koreanPost = readBuiltPage('frontend', '2021-05-30-tistory-268');
    const rss = readFileSync(resolve(dist, 'rss.xml'), 'utf8');
    const untranslatedEnglishPost = resolve(dist, 'en', 'frontend', '2021-05-30-tistory-268', 'index.html');

    // When
    const hasEnglishPost = existsSync(untranslatedEnglishPost);

    // Then
    expect(koreanPost).toContain('<html lang="ko"');
    expect(koreanPost).not.toContain('hreflang="en"');
    expect(rss).toContain('김예건 엔지니어링 노트');
    expect(hasEnglishPost).toBe(false);
  });
});
