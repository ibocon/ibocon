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

  it('Given_BuiltGlossaryPage_When_Inspected_Then_RendersOneEntryPerTermInADefinitionList', () => {
    // Given
    const html = readBuiltPage('glossary');

    // When
    const entries = [...html.matchAll(/<div id="([a-z0-9-]+)" class="glossary-entry[^"]*"/g)].map((match) => match[1]);

    // Then
    expect(html).toContain('<dl');
    expect(entries).toEqual(glossary.terms.map((term) => term.id));
  });

  it('Given_BuiltGlossaryPage_When_Inspected_Then_IndexLinksEveryTerm', () => {
    // Given
    const html = readBuiltPage('glossary');
    const index = html.match(/<nav class="toc glossary-index[^"]*"[\s\S]*?<\/nav>/)?.[0] ?? '';

    // When
    const missing = glossary.terms.filter((term) => !index.includes(`href="#${term.id}"`));

    // Then
    expect(missing.map((term) => term.id)).toEqual([]);
  });

  it('Given_ATermLinkedByAPost_When_Inspected_Then_ItsEntryListsThatPost', () => {
    // Given
    const html = readBuiltPage('glossary');

    // When
    const entry = html.match(/<div id="application-layer"[\s\S]*?<\/div>/)?.[0] ?? '';

    // Then
    expect(entry).toContain('href="/clean-architecture-rich-domain/"');
  });

  it('Given_TermsWithForbiddenVariants_When_Inspected_Then_VariantsAreFoldedWithTheirCount', () => {
    // Given
    const html = readBuiltPage('glossary');

    // When
    const missing = glossary.terms.filter((term) => !html.includes(`쓰지 않는 표기 ${term.forbidden.length}개`));

    // Then
    expect(html).toContain('<details');
    expect(missing.map((term) => term.id)).toEqual([]);
  });

  it('Given_GlobalStyles_When_Inspected_Then_GlossaryLinksInPostsHaveADottedUnderline', () => {
    // Given
    const css = readFileSync(resolve(process.cwd(), 'src/styles/global.css'), 'utf8');

    // When & Then
    expect(css).toMatch(/\.prose a\[href\^="\/glossary\/#"\][^}]*dotted/);
  });
});
