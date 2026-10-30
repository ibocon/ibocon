export type Locale = 'ko' | 'en';
export type LocalizedPage = 'home' | 'about' | 'editorial';

const localePaths: Record<Locale, Record<LocalizedPage, string>> = {
  ko: { home: '/', about: '/about/', editorial: '/editorial-policy/' },
  en: { home: '/en/', about: '/en/about/', editorial: '/en/editorial-policy/' },
};

export const alternatePath = (locale: Locale, page: LocalizedPage): string => localePaths[locale][page];
export const alternateLocale = (locale: Locale): Locale => locale === 'ko' ? 'en' : 'ko';
export const absoluteLocaleUrl = (locale: Locale, page: LocalizedPage): string => new URL(alternatePath(locale, page), 'https://blog.botanicsoft.com').toString();
