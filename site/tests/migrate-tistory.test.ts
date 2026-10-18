import { describe, expect, it } from 'vitest';
import { buildMigratedMarkdown, convertTistoryHtmlToMarkdown, extractContentsStyle, mapTistoryCategory, parseRssItems, parseTistoryPage } from '../scripts/migrate-tistory-posts.mjs';

describe('Tistory tech post migration', () => {
  it('maps only the approved technical categories', () => {
    expect(mapTistoryCategory('Develop/.NET 가이드')).toBe('dotnet');
    expect(mapTistoryCategory('Develop/MAUI 가이드')).toBe('maui');
    expect(mapTistoryCategory('단독주택 집짓기')).toBeNull();
  });

  it('converts RSS post HTML into schema-compatible markdown', () => {
    const body = convertTistoryHtmlToMarkdown('<h2>제목</h2><p>본문</p><pre><code>const x = 1;</code></pre>');
    const markdown = buildMigratedMarkdown({ title: '제목', description: '설명', pubDate: '2026-10-16', category: 'dotnet', originalUrl: 'https://ibocon.tistory.com/278', bodyMarkdown: body });
    expect(body).toContain('## 제목');
    expect(markdown).toContain('originalUrl: "https://ibocon.tistory.com/278"');
    expect(parseRssItems('<rss><item><title>글</title><link>https://ibocon.tistory.com/1</link><category>Develop/.NET 가이드</category></item></rss>')).toHaveLength(1);
    expect(parseTistoryPage('<script>window.T.entryInfo = {"categoryLabel":"Develop/.NET 가이드"};</script><meta property="og:title" content="글"><meta property="article:published_time" content="2026-10-16T00:00:00+09:00"><div class="contents_style"><p>본문</p></div><!-- System', 'https://ibocon.tistory.com/1').categories[0]).toContain('.NET 가이드');
  });

  it('preserves nested containers and article media beyond the first nested div', () => {
    const html = '<div class="tt_article_useless_p_margin contents_style"><p>첫 본문</p><div><p>중첩 본문</p></div><figure alt="설명"><img src="https://example.test/image.png"></figure><blockquote>인용문</blockquote><h2>후속 제목</h2></div><!-- System';

    const body = extractContentsStyle(html);
    const markdown = convertTistoryHtmlToMarkdown(body);

    expect(body).toContain('중첩 본문');
    expect(markdown).toContain('![설명](https://example.test/image.png)');
    expect(markdown).toContain('> 인용문');
    expect(markdown).toContain('## 후속 제목');
  });
});
