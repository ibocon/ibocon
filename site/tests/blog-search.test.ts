import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { compareSearchRelevance, getSearchScore, isPostVisible, matchesSearch, type PostFilterEntry } from '../src/lib/blog-filter';

const entry: PostFilterEntry = {
  title: 'Clean Architecture와 Rich Domain Model 실전 적용 원칙',
  description: '빈혈 도메인 모델을 탈피하고 불변식 캡슐화와 Result 패턴으로 테스트 가능한 백엔드를 구축하는 방법',
  tags: ['dotnet', 'clean-architecture', 'ddd'],
};

describe('Blog post search filter', () => {
  it('Given_Entry_When_MatchesSearch_Then_MatchesTitleDescriptionAndTag', () => {
    // Given
    // When
    // Then
    expect(matchesSearch(entry, 'rich domain')).toBe(true);
    expect(matchesSearch(entry, 'result 패턴')).toBe(true);
    expect(matchesSearch(entry, 'dotnet')).toBe(true);
    expect(matchesSearch(entry, 'ddd')).toBe(true);
    expect(matchesSearch(entry, '블레이저')).toBe(false);
  });

  it('Given_MixedCaseOrNfdQuery_When_MatchesSearch_Then_NormalizesBeforeCompare', () => {
    // Given
    // When
    // Then
    expect(matchesSearch(entry, 'CLEAN')).toBe(true);
    expect(matchesSearch(entry, 'Clean'.normalize('NFD'))).toBe(true);
  });

  it('Given_MatchesAcrossFields_When_GetSearchScore_Then_PrioritizesTitleBeforeTagBeforeDescription', () => {
    // Given
    const titleMatch: PostFilterEntry = { title: 'DDD 시작하기', description: '도메인 모델', tags: ['backend'] };
    const tagMatch: PostFilterEntry = { title: '설계 노트', description: '도메인 모델', tags: ['ddd'] };
    const descriptionMatch: PostFilterEntry = { title: '설계 노트', description: 'DDD를 설명한다', tags: ['backend'] };

    // When
    const scores = [titleMatch, tagMatch, descriptionMatch].map((post) => getSearchScore(post, 'ddd'));

    // Then
    expect(scores).toEqual([3, 2, 1]);
    expect(getSearchScore(entry, '없는 검색어')).toBe(-1);
  });

  it('Given_EqualScores_When_Compared_Then_KeepsTheCallerOrder', () => {
    // Given
    const left: PostFilterEntry = { title: 'DDD 첫 글', description: '', tags: [] };
    const right: PostFilterEntry = { title: 'DDD 다음 글', description: '', tags: [] };

    // When
    const result = compareSearchRelevance(left, right, 'ddd');

    // Then
    expect(result).toBe(0);
  });

  it('Given_EmptyQuery_When_MatchesSearch_Then_ReturnsTrue', () => {
    // Given
    // When
    // Then
    expect(matchesSearch(entry, '')).toBe(true);
    expect(matchesSearch(entry, '   ')).toBe(true);
  });

  it('Given_QueryAndTag_When_IsPostVisible_Then_AppliesBothFilters', () => {
    // Given
    // When
    // Then
    expect(isPostVisible(entry, 'rich domain', 'dotnet')).toBe(true);
    expect(isPostVisible(entry, 'rich domain', 'frontend')).toBe(false);
    expect(isPostVisible(entry, '블레이저', 'dotnet')).toBe(false);
    expect(isPostVisible(entry, '', 'frontend')).toBe(false);
  });

  it('Given_AllTags_When_IsPostVisible_Then_SearchOnlyDecides', () => {
    // Given
    // When
    // Then
    expect(isPostVisible(entry, 'rich domain', 'all')).toBe(true);
    expect(isPostVisible(entry, '블레이저', 'all')).toBe(false);
  });

  it('Given_MultiTaggedEntry_When_IsPostVisible_Then_EachTagFindsTheEntry', () => {
    // Given
    // When
    // Then
    expect(isPostVisible(entry, '', 'ddd')).toBe(true);
    expect(isPostVisible(entry, '', 'tistory')).toBe(false);
    expect(isPostVisible(entry, '', 'dotnet')).toBe(true);
    expect(isPostVisible(entry, 'rich domain', 'ddd')).toBe(true);
    expect(isPostVisible(entry, '블레이저', 'ddd')).toBe(false);
  });
});

describe('Blog search markup', () => {
  it('Given_IndexPage_When_Inspected_Then_ExposesSearchInputStatusAndCardData', () => {
    // Given
    const index = readFileSync(resolve(process.cwd(), 'src/pages/index.astro'), 'utf8');

    // When
    // Then
    expect(index).toContain('id="post-search"');
    expect(index).toContain('role="search"');
    expect(index).toContain('class="post-discovery"');
    expect(index).toContain('id="clear-post-search"');
    expect(index).toContain('id="tag-filter"');
    expect(index).toContain('태그로 좁히기');
    expect(index).toContain('전체 태그');
    expect(index).toContain('id="search-status"');
    expect(index).toContain('role="status"');
    expect(index).toContain('id="search-empty"');
    expect(index).toContain('data-title');
    expect(index).toContain('data-description');
    expect(index).toContain('data-tags');
    expect(index).not.toContain('data-category');
    expect(index).toContain('compareSearchRelevance');
    expect(index).toContain("../lib/blog-filter'");
  });
});
