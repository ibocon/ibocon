import { readFileSync } from 'node:fs';
import { mkdir, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const CATEGORY_MAP = new Map([
  ['.NET 가이드', 'dotnet'],
  ['MAUI 가이드', 'maui'],
  ['Backend 가이드', 'backend'],
  ['Frontend 가이드', 'frontend'],
  ['소프트웨어 설계', 'architecture'],
]);

const decodeHtml = (value = '') => value
  .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
  .replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, '&')
  .replace(/&lt;/g, '<').replace(/&gt;/g, '>');

const stripTags = (value = '') => decodeHtml(value).replace(/<[^>]*>/g, ' ').replace(/\s+/g, ' ').trim();

const getAttribute = (html, name) => decodeHtml(
  html.match(new RegExp(`(?:^|\\s)${name}="([^"]*)"`, 'i'))?.[1] ?? '',
);

function convertTistoryFigureToMarkdown(figure) {
  const image = figure.match(/<img\b[^>]*>/i)?.[0] ?? '';
  const source = getAttribute(image, 'src');
  if (!source) return '';

  const alt = getAttribute(image, 'alt') || getAttribute(figure, 'data-alt') || getAttribute(figure, 'alt');
  const caption = stripTags(figure.match(/<figcaption\b[^>]*>([\s\S]*?)<\/figcaption>/i)?.[1] ?? '');
  const captionMarkdown = caption && caption !== alt ? `\n\n${caption}` : '';
  return `\n\n![${alt}](${source})${captionMarkdown}\n`;
}

function extractBalancedDiv(html, start) {
  const openingEnd = html.indexOf('>', start);
  if (openingEnd < 0) return '';

  const tags = /<\/?div\b[^>]*>/gi;
  tags.lastIndex = openingEnd + 1;
  let depth = 1;
  for (let tag = tags.exec(html); tag; tag = tags.exec(html)) {
    depth += tag[0].startsWith('</') ? -1 : 1;
    if (depth === 0) return html.slice(openingEnd + 1, tag.index);
  }
  return '';
}

export function extractContentsStyle(html) {
  const start = html.search(/<div\b[^>]*\bcontents_style\b[^>]*>/i);
  return start < 0 ? '' : extractBalancedDiv(html, start);
}

export function mapTistoryCategory(rawCategory) {
  const normalized = (rawCategory ?? '').trim();
  for (const [name, folder] of CATEGORY_MAP) {
    if (normalized.includes(name)) return folder;
  }
  return null;
}

export function convertTistoryHtmlToMarkdown(html) {
  return decodeHtml(html)
    .replace(/<figure\b[\s\S]*?<\/figure>/gi, (figure) => convertTistoryFigureToMarkdown(figure))
    .replace(/<img[^>]*\balt="([^"]*)"[^>]*\bsrc="([^"]+)"[^>]*>/gi, (_, alt, src) => `![${stripTags(alt)}](${src})`)
    .replace(/<img[^>]*\bsrc="([^"]+)"[^>]*\balt="([^"]*)"[^>]*>/gi, (_, src, alt) => `![${stripTags(alt)}](${src})`)
    .replace(/<pre[^>]*><code([^>]*)>([\s\S]*?)<\/code><\/pre>/gi, (_, attributes, code) => {
      const language = attributes.match(/\blanguage-([\w+#-]+)/i)?.[1] ?? '';
      return `\n\n\`\`\`${language}\n${decodeHtml(code).trim()}\n\`\`\`\n`;
    })
    .replace(/<a[^>]*\bhref="([^"]+)"[^>]*>([\s\S]*?)<\/a>/gi, (_, href, content) => `[${stripTags(content)}](${href})`)
    .replace(/<blockquote[^>]*>([\s\S]*?)<\/blockquote>/gi, (_, content) => `\n\n> ${stripTags(content)}\n`)
    .replace(/<h([1-6])[^>]*>([\s\S]*?)<\/h\1>/gi, (_, level, content) => `\n\n${'#'.repeat(Number(level))} ${stripTags(content)}\n`)
    .replace(/<li[^>]*>([\s\S]*?)<\/li>/gi, (_, content) => `\n- ${stripTags(content)}`)
    .replace(/<p[^>]*>([\s\S]*?)<\/p>/gi, (_, content) => {
      const normalized = content.trim();
      return normalized.includes('![') ? `\n\n${normalized}\n` : `\n\n${stripTags(content)}\n`;
    })
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<[^>]*>/g, '')
    .replace(/\n{3,}/g, '\n\n')
    .trim();
}

const SIGNED_IMAGE_PATTERN = /!\[(.*?)\]\((https:\/\/blog\.kakaocdn\.net\/[^)\s]+)\)/g;
const IMAGE_EXTENSIONS = new Map([['image/png', 'png'], ['image/jpeg', 'jpg'], ['image/gif', 'gif'], ['image/webp', 'webp'], ['image/svg+xml', 'svg']]);

// ✅ Tistory 이미지 URL은 만료되는 서명 URL이므로 마이그레이션 시점에 로컬 정적 자산으로 내려받는다.
export async function localizeImages(markdown, { identifier, imageDirectory, fetchImage = fetch }) {
  const matches = [...markdown.matchAll(SIGNED_IMAGE_PATTERN)];
  let result = markdown;
  for (const [index, [whole, alt, url]] of matches.entries()) {
    const response = await fetchImage(url);
    if (!response.ok) throw new Error(`Tistory image request failed: ${response.status} ${url}`);
    const extension = IMAGE_EXTENSIONS.get((response.headers.get('content-type') ?? '').split(';')[0]) ?? 'png';
    const fileName = `${index + 1}.${extension}`;
    await mkdir(resolve(imageDirectory, identifier), { recursive: true });
    await writeFile(resolve(imageDirectory, identifier, fileName), Buffer.from(await response.arrayBuffer()));
    result = result.replace(whole, `![${alt.replace(/\s*width=\s*$/, '').trim()}](/blog-images/${identifier}/${fileName})`);
  }
  return result;
}

// ✅ 글별 최종 슬러그는 blog-slugs.json 단일 원본에서만 찾는다.
export function slugByTistoryId(tistoryId, manifestPath = resolve(dirname(fileURLToPath(import.meta.url)), 'blog-slugs.json')) {
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  return manifest.find((entry) => entry.tistoryId === String(tistoryId))?.slug;
}

export function buildMigratedMarkdown({ title, description, pubDate, category, originalUrl, bodyMarkdown, draft = false }) {
  const quote = (value) => String(value ?? '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
  return ['---', `title: "${quote(title)}"`, `description: "${quote(description)}"`, `pubDate: ${pubDate}`, `tags: ["${category}"]`, 'source: "tistory"', `originalUrl: "${originalUrl}"`, `draft: ${draft}`, '---', '', bodyMarkdown, ''].join('\n');
}

export function parseRssItems(xml) {
  return [...xml.matchAll(/<item>([\s\S]*?)<\/item>/gi)].map((match) => {
    const item = match[1];
    const text = (name) => decodeHtml(item.match(new RegExp(`<${name}[^>]*>([\\s\\S]*?)<\\/${name}>`, 'i'))?.[1] ?? '');
    const categories = [...item.matchAll(/<category>([\s\S]*?)<\/category>/gi)].map((category) => decodeHtml(category[1]));
    return { title: text('title'), link: text('link'), description: text('description'), pubDate: text('pubDate'), categories };
  });
}

export function parseTistoryPage(html, url) {
  const match = (pattern) => decodeHtml(html.match(pattern)?.[1] ?? '');
  const category = match(/"categoryLabel":"([^"]+)"/i);
  const title = match(/<meta property="og:title" content="([^"]+)"/i) || match(/<title>([\s\S]*?)<\/title>/i);
  const description = match(/<meta name="description" content="([^"]*)"/i);
  const published = match(/<meta property="article:published_time" content="([^"]+)"/i);
  const body = extractContentsStyle(html);
  return { title: stripTags(title), link: url, description, pubDate: published, categories: [category], body };
}

async function mapWithConcurrency(values, concurrency, callback) {
  const results = [];
  let index = 0;
  await Promise.all(Array.from({ length: Math.min(concurrency, values.length) }, async () => {
    while (index < values.length) {
      const current = values[index++];
      const result = await callback(current);
      if (result) results.push(result);
    }
  }));
  return results;
}

export async function migrateTistoryPosts({ rssUrl = 'https://ibocon.tistory.com/rss', sitemapUrl = 'https://ibocon.tistory.com/sitemap.xml', outputDirectory, dryRun = false, full = false } = {}) {
  const response = await fetch(rssUrl);
  if (!response.ok) throw new Error(`Tistory RSS request failed: ${response.status}`);
  let items = parseRssItems(await response.text());
  if (full) {
    const sitemap = await fetch(sitemapUrl);
    if (!sitemap.ok) throw new Error(`Tistory sitemap request failed: ${sitemap.status}`);
    const urls = [...(await sitemap.text()).matchAll(/<loc>(https:\/\/ibocon\.tistory\.com\/\d+)<\/loc>/g)].map((match) => match[1]);
    items = await mapWithConcurrency(urls, 6, async (url) => {
      const page = await fetch(url);
      return page.ok ? parseTistoryPage(await page.text(), url) : null;
    });
  }
  const posts = items.map((item) => ({ ...item, category: item.categories.map(mapTistoryCategory).find(Boolean) })).filter((item) => item.category);
  const destination = outputDirectory ?? resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', 'blog');
  const imageDirectory = resolve(dirname(fileURLToPath(import.meta.url)), '..', 'public', 'blog-images');
  const written = [];
  for (const post of posts) {
    const date = new Date(post.pubDate).toISOString().slice(0, 10);
    const identifier = post.link.match(/\/(\d+)\/?$/)?.[1] ?? 'post';
    // ✅ 매니페스트에 슬러그가 있으면 최종 파일명, 없으면 임시 초안(draft)으로만 쓴다
    const slug = slugByTistoryId(identifier);
    const path = resolve(destination, `${slug ?? `tistory-${identifier}`}.md`);
    const draft = slug === undefined;
    let bodyMarkdown = convertTistoryHtmlToMarkdown(post.body || post.description);
    if (!dryRun) bodyMarkdown = await localizeImages(bodyMarkdown, { identifier, imageDirectory });
    const markdown = buildMigratedMarkdown({ title: post.title, description: stripTags(post.description).slice(0, 160) || post.title, pubDate: date, category: post.category, originalUrl: post.link, bodyMarkdown, draft });
    if (!dryRun) { await mkdir(dirname(path), { recursive: true }); await writeFile(path, markdown, 'utf8'); }
    written.push(path);
  }
  return { fetched: items.length, migrated: written.length, written };
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const result = await migrateTistoryPosts({ dryRun: process.argv.includes('--dry-run'), full: process.argv.includes('--full') });
  console.log(JSON.stringify({ fetched: result.fetched, migrated: result.migrated }, null, 2));
}
