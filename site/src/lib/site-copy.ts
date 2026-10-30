import type { Locale } from './locale';

export const siteCopy = {
  ko: {
    brandName: '김예건 엔지니어링 노트', ownerName: '김예건', ownerNameRomanized: 'Yegun Kim',
    technicalScope: '.NET, 프런트엔드, 모바일, 분산 시스템과 운영 경험',
    aboutSummary: '.NET, 프런트엔드, 모바일, 분산 시스템과 운영 경험을 기록하는 개인 기술 출판물입니다.',
    editorialResponsibility: '김예건이 글의 발행, 정정, 갱신을 관리합니다.',
    primaryNavigationLabel: '주 탐색', homeLabel: '게시물', aboutLabel: '소개', resumeLabel: '이력서', editorialLabel: '편집 원칙', githubLabel: 'GitHub', rssLabel: 'RSS', localeSwitchLabel: 'English',
    themeDarkLabel: '어두운 테마로 전환', themeLightLabel: '밝은 테마로 전환', footerLabel: '사이트 정보', footerNotice: '기술 경험과 참고 자료를 지속적으로 갱신합니다.',
    aboutTitle: '소개', aboutDescription: '운영자, 기술 분야, 연락 경로와 콘텐츠 운영 원칙', resumeTitle: '이력서', resumeDescription: '김예건의 소프트웨어 엔지니어링 경력, 핵심 역량, 대표 프로젝트', editorialTitle: '편집 원칙', editorialDescription: '원문 출처, 정정 및 갱신, 광고와 편집 독립 원칙',
  },
  en: {
    brandName: 'Yegun Kim Engineering Notes', ownerName: 'Yegun Kim', ownerNameRomanized: '김예건',
    technicalScope: 'A personal technical publication about .NET, frontend, mobile, distributed systems, and operations.',
    aboutSummary: 'A personal technical publication recording experience with .NET, frontend, mobile, distributed systems, and operations.',
    editorialResponsibility: 'Yegun Kim manages publication, corrections, and updates to this site.',
    primaryNavigationLabel: 'Primary navigation', homeLabel: 'Notes', aboutLabel: 'About Me', resumeLabel: 'Resume', editorialLabel: 'Editorial Policy', githubLabel: 'GitHub', rssLabel: 'RSS', localeSwitchLabel: '한국어',
    themeDarkLabel: 'Switch to dark theme', themeLightLabel: 'Switch to light theme', footerLabel: 'Site information', footerNotice: 'Technical experience and reference material are updated over time.',
    aboutTitle: 'About Me', aboutDescription: 'The publisher, technical scope, contact path, and editorial principles', resumeTitle: 'Resume', resumeDescription: 'Yegun Kim’s software engineering experience, core strengths, and selected projects', editorialTitle: 'Editorial Policy', editorialDescription: 'Source attribution, corrections and updates, advertising, and editorial independence',
  },
} as const satisfies Record<Locale, Record<string, string>>;

export type SiteCopy = (typeof siteCopy)[Locale];
export const koSiteCopy = siteCopy.ko;
