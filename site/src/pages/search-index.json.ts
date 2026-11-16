import type { APIRoute } from 'astro';
import { getPublishedPosts } from '../lib/blog-posts';
import { toSearchEntry } from '../lib/blog-search-index';

export const GET: APIRoute = async () => {
  const posts = await getPublishedPosts();
  return new Response(JSON.stringify(posts.map(toSearchEntry)), {
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  });
};
