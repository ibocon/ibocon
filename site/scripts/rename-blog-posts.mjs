import { readFileSync, readdirSync, renameSync, rmdirSync, statSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, '..', '..', 'blog');
const manifest = JSON.parse(readFileSync(resolve(here, 'blog-slugs.json'), 'utf8'));
const exists = (path) => statSync(path, { throwIfNoEntry: false }) !== undefined;

// ✅ legacyPath(/{category}/{stem}/)를 원본 파일 위치로 되돌려 slug 파일명으로 이동한다
for (const { legacyPath, slug } of manifest) {
  const [category, stem] = legacyPath.split('/').filter(Boolean);
  const from = join(root, category, `${stem}.md`);
  const to = join(root, `${slug}.md`);
  if (!exists(from)) throw new Error(`Missing source post: ${from}`);
  if (exists(to)) throw new Error(`Slug already exists: ${to}`);
  renameSync(from, to);
}

for (const entry of readdirSync(root, { withFileTypes: true }).filter((item) => item.isDirectory())) {
  rmdirSync(join(root, entry.name)); // ✅ 비어 있지 않으면 매니페스트 누락이므로 예외로 중단한다
}
