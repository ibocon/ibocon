import { describe, expect, it } from 'vitest';
import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import glossary from '../src/data/glossary.json';

const dist = resolve(process.cwd(), 'dist');
const readBuiltPage = (...segments: string[]) => readFileSync(resolve(dist, ...segments, 'index.html'), 'utf8');

describe('Blog glossary', () => {
  it('Given_BuiltGlossaryPage_When_Inspected_Then_ExposesEveryTermAsAnchor', () => {
    // Given
    const html = readBuiltPage('glossary');

    // When
    const missing = glossary.terms.filter((term) => !html.includes(`id="${term.id}"`));

    // Then
    expect(existsSync(resolve(dist, 'glossary', 'index.html'))).toBe(true);
    expect(html).toContain('<html lang="ko"');
    expect(missing.map((term) => term.id)).toEqual([]);
    glossary.terms.forEach((term) => expect(html).toContain(term.term));
  });

  it('Given_BuiltFooters_When_Inspected_Then_OnlyKoreanPagesLinkTheGlossary', () => {
    // Given
    const koreanFooter = readBuiltPage('about');
    const englishFooter = readBuiltPage('en', 'about');

    // When & Then
    expect(koreanFooter).toContain('href="/glossary/"');
    expect(englishFooter).not.toContain('href="/glossary/"');
  });

  it('Given_BuiltPosts_When_FollowingGlossaryLinks_Then_EveryAnchorExistsInTheGlossaryPage', () => {
    // Given
    const glossaryHtml = readBuiltPage('glossary');
    const slugs = readdirSync(dist, { withFileTypes: true }).filter((entry) => entry.isDirectory()).map((entry) => entry.name);

    // When
    const broken = slugs.flatMap((slug) => {
      const page = resolve(dist, slug, 'index.html');
      if (!existsSync(page)) {
        return [];
      }

      const anchors = [...readFileSync(page, 'utf8').matchAll(/href="\/glossary\/#([^"]+)"/g)].map((match) => match[1]);
      return anchors.filter((id) => !glossaryHtml.includes(`id="${id}"`)).map((id) => `${slug}#${id}`);
    });

    // Then
    // ✅ 끊어진 앵커가 있으면 글 slug와 앵커 id가 실패 메시지에 나타난다
    expect(broken).toEqual([]);
  });
});
