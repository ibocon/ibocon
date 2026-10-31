import { existsSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { describe, expect, it } from 'vitest';

const dist = resolve(process.cwd(), 'dist', 'resume', 'index.html');
const navigation = JSON.parse(readFileSync(resolve(process.cwd(), '..', 'resume', 'resume-navigation.json'), 'utf8')) as {
  sections: Array<{ id: string }>;
  projects: Array<{ url: string }>;
  domains: Array<{ url: string }>;
};

describe('Resume content parity', () => {
  it('Given_BuiltKoreanResume_When_InspectingSections_Then_ExposesEveryCanonicalAnchorInOrder', () => {
    expect(existsSync(dist)).toBe(true);
    const page = readFileSync(dist, 'utf8');
    const positions = navigation.sections.map(({ id }) => page.indexOf(`id="${id}"`));
    expect(positions.every((position) => position >= 0)).toBe(true);
    expect([...positions].sort((left, right) => left - right)).toEqual(positions);
  });

  it('Given_BuiltKoreanResume_When_InspectingNotionNavigation_Then_IncludesProjectAndDomainTargets', () => {
    const page = readFileSync(dist, 'utf8');
    for (const { url } of [...navigation.projects, ...navigation.domains]) {
      expect(page).toContain(url);
    }
  });
});
