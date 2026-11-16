import { getCollection } from 'astro:content';

export async function getPublishedPosts() {
  const includeDrafts = import.meta.env.DEV;
  return (await getCollection('blog'))
    .filter((post) => includeDrafts || !post.data.draft)
    .sort((a, b) => b.data.pubDate.valueOf() - a.data.pubDate.valueOf());
}
