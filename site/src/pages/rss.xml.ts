// ✅ blog/ 마크다운 글 목록을 기반으로 표준 RSS 2.0 피드 생성
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';
import type { APIContext } from 'astro';
import { koSiteCopy } from '../lib/site-copy';

export async function GET(context: APIContext) {
  const posts = (await getCollection('blog'))
    .filter((post) => !post.data.draft)
    .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());

  return rss({
    title: `${koSiteCopy.brandName} | BotanicSoft`,
    description: koSiteCopy.technicalScope,
    site: context.site ?? 'https://blog.botanicsoft.com',
    items: posts.map((post) => ({
      title: post.data.title,
      pubDate: post.data.pubDate,
      description: post.data.description,
      categories: [post.data.category, ...post.data.tags],
      link: `/${post.id}/`,
    })),
  });
}
