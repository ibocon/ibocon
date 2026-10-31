import { readFile, readdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';

const allowedTags = new Set(['architecture', 'backend', 'clean-architecture', 'csharp', 'ddd', 'dotnet', 'frontend', 'kubernetes', 'maui', 'observability', 'postfix', 'security']);
const write = process.argv.includes('--write');

async function markdownFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const nested = await Promise.all(entries.map(async (entry) => entry.isDirectory()
    ? markdownFiles(join(directory, entry.name))
    : entry.name.endsWith('.md') ? [join(directory, entry.name)] : []));
  return nested.flat();
}

export function normalizeFrontMatter(source) {
  const category = source.match(/^category:\s*"?([^"\r\n]+)"?\r?$/m)?.[1]?.trim();
  const tagMatch = source.match(/^tags:\s*\[([^\]]*)\]\r?$/m);
  if (!category || !tagMatch) throw new Error('blog-frontmatter-category-or-tags-missing');
  const tags = [...new Set([category, ...tagMatch[1].match(/[a-z0-9-]+/g) ?? []]
    .map((tag) => tag.toLowerCase()).filter((tag) => tag !== 'tistory'))];
  if (tags.length === 0 || tags.length > 5 || tags.some((tag) => !allowedTags.has(tag))) {
    throw new Error(`blog-tag-contract-invalid: ${tags.join(',')}`);
  }
  return source.replace(/^category:.*\r?\n/m, '').replace(tagMatch[0], `tags: [${tags.map((tag) => `"${tag}"`).join(', ')}]\nsource: "tistory"\n`);
}

if (process.argv[1]?.endsWith('normalize-blog-tags.mjs')) {
  const files = await markdownFiles(fileURLToPath(new URL('../../blog/', import.meta.url)));
  const changes = [];
  for (const file of files) {
    const source = await readFile(file, 'utf8');
    const normalized = normalizeFrontMatter(source);
    if (source !== normalized) changes.push([file, normalized]);
  }
  console.log(`blog-tag-normalization: ${changes.length}/${files.length} files would change`);
  if (write) await Promise.all(changes.map(([file, content]) => writeFile(file, content)));
}
