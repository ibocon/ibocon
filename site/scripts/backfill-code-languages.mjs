import { readdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { detectCodeLanguage } from './code-language.mjs';

// ✅ 펜스 안/밖 상태를 추적해 언어 없는 여는 펜스에만 언어를 기록한다 (멱등).
export function backfillCodeLanguages(markdown, detect = detectCodeLanguage) {
  const lines = markdown.split('\n');
  let open = -1;
  for (let index = 0; index < lines.length; index++) {
    if (!lines[index].trimEnd().startsWith('```')) continue;
    if (open < 0) { open = index; continue; }
    if (lines[open].trimEnd() === '```') lines[open] = `\`\`\`${detect(lines.slice(open + 1, index).join('\n'))}`;
    open = -1;
  }
  return lines.join('\n');
}

async function markdownFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const nested = await Promise.all(entries.map((entry) => (entry.isDirectory() ? markdownFiles(resolve(directory, entry.name)) : entry.name.endsWith('.md') ? [resolve(directory, entry.name)] : [])));
  return nested.flat();
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const blogDirectory = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', 'blog');
  const distribution = {};
  for (const path of await markdownFiles(blogDirectory)) {
    const source = await readFile(path, 'utf8');
    const result = backfillCodeLanguages(source);
    for (const [, language] of result.matchAll(/^```(\w+)$/gm)) distribution[language] = (distribution[language] ?? 0) + 1;
    if (result !== source) await writeFile(path, result, 'utf8');
  }
  console.log(JSON.stringify(distribution, null, 2));
}
