import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';
import { resumeEducation, resumeSkillGroups, splitDomainName, splitSkillValues } from '../src/data/resume';

const readPage = (...segments: string[]): string => readFileSync(resolve(process.cwd(), 'dist', ...segments, 'index.html'), 'utf8');

describe('Resume two-column layout', () => {
  it('Given_BuiltKoreanResume_When_InspectingStructure_Then_SkillsAndEducationLiveInSideAfterMain', () => {
    // Given
    const page = readPage('resume');

    // When
    const mainIndex = page.indexOf('class="resume-main"');
    const sideIndex = page.indexOf('class="resume-side"');
    const side = page.slice(sideIndex);

    // Then
    expect(page).toContain('class="resume-layout"');
    expect(mainIndex).toBeGreaterThanOrEqual(0);
    expect(sideIndex).toBeGreaterThan(mainIndex);
    expect(side).toContain('id="skills"');
    expect(side).toContain('id="education"');
  });

  it('Given_BuiltKoreanResume_When_InspectingSkills_Then_RendersEverySkillValueAsChip', () => {
    // Given
    const page = readPage('resume');

    // When
    const values = resumeSkillGroups.flatMap(([, group]) => splitSkillValues(group));

    // Then
    expect(values.length).toBeGreaterThan(0);
    for (const value of values) {
      expect(page).toContain(`<li>${value}</li>`);
    }
  });

  it('Given_BuiltKoreanResume_When_InspectingCareerAndEducation_Then_RendersTimelineAndEveryEducationRow', () => {
    // Given
    const page = readPage('resume');

    // When
    const timelineIndex = page.indexOf('class="resume-timeline"');

    // Then
    expect(timelineIndex).toBeGreaterThanOrEqual(0);
    for (const [period] of resumeEducation) {
      expect(page).toContain(period);
    }
  });

  it('Given_BuiltEnglishResume_When_InspectingStructure_Then_UsesSharedLayoutClassesWithoutSidebar', () => {
    // Given
    const page = readPage('en', 'resume');

    // When
    const hasHero = page.includes('class="resume-hero"');

    // Then
    expect(hasHero).toBe(true);
    expect(page).toContain('resume-layout-single');
    expect(page).not.toContain('class="resume-side"');
  });

  it('Given_DomainNames_When_Split_Then_SeparatesNumberAndTitle', () => {
    // Given
    const name = '02. .NET 백엔드 엔지니어링';

    // When
    const result = splitDomainName(name);

    // Then
    expect(result).toEqual({ number: '02', title: '.NET 백엔드 엔지니어링' });
  });
});
