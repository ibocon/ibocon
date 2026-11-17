import { describe, expect, it } from 'vitest';
import { collectGlossaryUsage, type UsagePost } from '../src/lib/glossary-usage';

const post = (id: string, body: string): UsagePost => ({ id, title: `${id} 제목`, body });
const termIds = ['application-layer', 'domain-layer'];

describe('collectGlossaryUsage', () => {
  it('Given_PostsLinkingATerm_When_Collected_Then_ListsThosePostsInInputOrder', () => {
    // Given
    const posts = [
      post('newer', '[Application 레이어](/glossary/#application-layer)를 쓴다.'),
      post('older', '[Application 레이어](/glossary/#application-layer)도 쓴다.'),
    ];

    // When
    const usage = collectGlossaryUsage(posts, termIds);

    // Then
    expect(usage.get('application-layer')?.map((link) => link.id)).toEqual(['newer', 'older']);
  });

  it('Given_ADuplicateLinkInOnePost_When_Collected_Then_ListsThePostOnce', () => {
    // Given
    const posts = [post('only', '[A](/glossary/#domain-layer) 그리고 [B](/glossary/#domain-layer)')];

    // When
    const usage = collectGlossaryUsage(posts, termIds);

    // Then
    expect(usage.get('domain-layer')).toHaveLength(1);
  });

  it('Given_AnUnknownAnchor_When_Collected_Then_IsIgnored', () => {
    // Given
    const posts = [post('typo', '[없는 용어](/glossary/#no-such-term)')];

    // When
    const usage = collectGlossaryUsage(posts, termIds);

    // Then
    expect([...usage.keys()]).toEqual(termIds);
    expect(usage.get('application-layer')).toEqual([]);
  });

  it('Given_NoPostLinksATerm_When_Collected_Then_ReturnsAnEmptyList', () => {
    // Given
    const posts = [post('plain', '용어 링크가 없는 글이다.')];

    // When
    const usage = collectGlossaryUsage(posts, termIds);

    // Then
    expect(usage.get('domain-layer')).toEqual([]);
  });
});
