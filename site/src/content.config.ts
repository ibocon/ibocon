// ✅ 리포지토리 루트의 ../blog 폴더 하위 마크다운(.md)을 스캔하는 컬렉션 로더
import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';
import { BLOG_TAGS } from './lib/blog-tags';

const blog = defineCollection({
  // ✅ 카테고리는 tags 가 담당하므로 폴더 중첩 없이 blog 바로 아래 파일만 글로 인식한다
  loader: glob({ pattern: '*.{md,mdx}', base: '../blog' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    pubDate: z.coerce.date(),
    updatedDate: z.coerce.date().optional(),
    tags: z.array(z.enum(BLOG_TAGS)).min(1),
    coverImage: z.string().startsWith('/').optional(),
    authoringVersion: z.literal(1).optional(),
    audience: z.enum(['topic-new-developer']).optional(),
    articleType: z.enum(['concept', 'tutorial', 'incident', 'design']).optional(),
    source: z.enum(['tistory']).optional(),
    draft: z.boolean().default(false),
    originalUrl: z.string().url().optional(),
  }),
});

export const collections = { blog };
