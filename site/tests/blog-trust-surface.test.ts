import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const dist = resolve(process.cwd(), 'dist');
const readBuiltPage = (...segments: string[]) => readFileSync(resolve(dist, ...segments, 'index.html'), 'utf8');

describe('Blog trust surface', () => {
  it('Given_BuiltKoreanTrustPages_When_InspectingIdentitySurface_Then_PublishesVerifiedOwnerAndEditorialPath', () => {
    // Given
    const aboutPath = resolve(dist, 'about', 'index.html');
    const editorialPath = resolve(dist, 'editorial-policy', 'index.html');

    // When
    const aboutHtml = readBuiltPage('about');
    const editorialHtml = readBuiltPage('editorial-policy');

    // Then
    expect(existsSync(aboutPath)).toBe(true);
    expect(existsSync(editorialPath)).toBe(true);
    expect(aboutHtml).toContain('김예건 엔지니어링 노트');
    expect(aboutHtml).toContain('김예건');
    expect(aboutHtml).toContain('발행, 정정, 갱신');
    expect(aboutHtml).toContain('/editorial-policy/');
    expect(aboutHtml).toContain('운영자와 콘텐츠 책임');
    expect(editorialHtml).toContain('김예건 엔지니어링 노트');
    expect(editorialHtml).toContain('원문 출처와 이관');
  });

  it('Given_BuiltHomeAndPost_When_InspectingNavigation_Then_LinksToTrustPages', () => {
    // Given
    const homeHtml = readBuiltPage();
    const postHtml = readBuiltPage('web-api-websocket');

    // When
    const trustLinks = ['/about/', '/editorial-policy/'];

    // Then
    trustLinks.forEach((link) => {
      expect(homeHtml).toContain(link);
      expect(postHtml).toContain(link);
    });
  });

  it('Given_MigratedPost_When_Built_Then_ShowsItsPublicationDateOnceWithoutSourceLabel', () => {
    // Given
    const postHtml = readBuiltPage('web-api-websocket');

    // When
    const sourceLabel = '원문 출처';
    const publicationDateTextOccurrences = postHtml.match(/>\s*2021-05-30\s*</g) ?? [];

    // Then
    expect(publicationDateTextOccurrences).toHaveLength(1);
    expect(postHtml).not.toContain('최초 게시:');
    expect(postHtml).not.toContain(sourceLabel);
  });

  it('Given_DevelopmentDraft_When_Presented_Then_ExposesItsCoverAndReadingTime', () => {
    // Given
    const route = readFileSync(resolve(process.cwd(), 'src', 'pages', '[...slug].astro'), 'utf8');
    const home = readFileSync(resolve(process.cwd(), 'src', 'pages', 'index.astro'), 'utf8');

    // When
    const draft = readFileSync(resolve(process.cwd(), '..', 'blog', 'kubernetes-alertmanager-postfix-open-relay.md'), 'utf8');

    // Then
    expect(route).toContain('post-cover');
    expect(route).toContain('readingMinutes');
    expect(home).toContain('post-card-cover');
    expect(home).toContain('readingMinutes');
    expect(draft).toContain('coverImage: "/post-covers/kubernetes-alertmanager-postfix-open-relay.svg"');
  });
});
