import { describe, expect, it } from 'vitest';
import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';

const dist = resolve(process.cwd(), 'dist');
const readBuiltPage = (...segments: string[]) => readFileSync(resolve(dist, ...segments, 'index.html'), 'utf8');

describe('Blog resume navigation', () => {
  it('Given_BuiltEnglishHeader_When_InspectingIdentityNavigation_Then_OrdersNotesAboutMeResumeAndEditorial', () => {
    // Given
    const resumePage = readBuiltPage('en', 'resume');
    const header = resumePage.match(/<nav class="header-nav"[^>]*>([\s\S]*?)<\/nav>/)?.[1] ?? '';

    // When
    const notesIndex = header.indexOf('Notes');
    const aboutIndex = header.indexOf('About Me');
    const resumeIndex = header.indexOf('Resume');
    const editorialIndex = header.indexOf('Editorial Policy');

    // Then
    expect(notesIndex).toBeGreaterThanOrEqual(0);
    expect(notesIndex).toBeLessThan(aboutIndex);
    expect(aboutIndex).toBeLessThan(resumeIndex);
    expect(resumeIndex).toBeLessThan(editorialIndex);
  });

  it('Given_BuiltResumePages_When_InspectingIdentityRoutes_Then_PublishesBothLocales', () => {
    // Given
    const koreanResume = resolve(dist, 'resume', 'index.html');
    const englishResume = resolve(dist, 'en', 'resume', 'index.html');

    // Then
    expect(existsSync(koreanResume)).toBe(true);
    expect(existsSync(englishResume)).toBe(true);
  });

  it('Given_BuiltFooter_When_InspectingIdentityLinks_Then_IncludesAboutMeResumeAndEditorial', () => {
    // Given
    const footer = readBuiltPage('en', 'resume');

    // Then
    expect(footer).toContain('About Me');
    expect(footer).toContain('/en/resume/');
    expect(footer).toContain('Editorial Policy');
  });
});
