// ✅ 리포지토리 루트의 ../blog 폴더 하위 마크다운(.md)을 스캔하는 컬렉션 로더
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { BLOG_TAGS } from './lib/blog-tags';

const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: '../blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    tags: z.array(z.enum(BLOG_TAGS)).min(1),
    source: z.enum(['tistory']).optional(),
    draft: z.boolean().default(false),
    originalUrl: z.string().url().optional(),
  }),
});

export const collections = { blog };
