# ⬜ Google Analytics 4 데이터 스트림 및 Search Console 연결 사용자 실행 검증

## 계획 관계

> **관계 스키마**: `1`
> **계획 ID**: `ibocon:261016_verify_connect-google-analytics-and-search-console`
> **출처 판정**: `연결`

| 관계 | 대상 계획 ID | 조건 | 근거·인수 범위 |
| --- | --- | --- | --- |
| 검증 대상 | `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` | 해당 없음 | `https://blog.botanicsoft.com`에 삽입된 GA4(`G-K5DYPM14H9`) 태그의 실시간 수집 확인 및 Google Search Console 사이트맵(`sitemap-index.xml`)·GA4 서비스 연결 검증 |

<!-- plan-relations-summary:start -->
> 자동 생성 관계 요약. 원본은 위 관계 표입니다.

| 구분 | 계획·조건 |
| --- | --- |
| 최초 계획 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<../history/2610/W3/261015/261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` |
| 직접 출처 | [⬜ 블로그 Git 저장소 동기화 및 GitHub Actions 배포·README RSS 파이프라인 연동 고도화 계획](<261016_refac_sync-blog-repo-and-ci-workflow-triggers.md>) `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` |
| 직접 후속 | 없음 |
| 계보 경로 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<../history/2610/W3/261015/261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<../history/2610/W3/261015/261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` → [✅ 블로그 Cloudflare Pages 배포 시크릿의 CI 평면 네이밍(`CLOUDFLARE_CI_PAGES_TOKEN`) 정렬 리팩토링](<../history/2610/W3/261015/261015_refac_align-blog-ci-secret-naming.md>) `ibocon:261015_refac_align-blog-ci-secret-naming` → [✅ 블로그 배포 대상을 레거시 Cloudflare Pages에서 Workers Static Assets로 전환](<../history/2610/W3/261016/261016_refac_migrate-blog-to-cloudflare-workers-static-assets.md>) `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` → [⬜ 블로그 Git 저장소 동기화 및 GitHub Actions 배포·README RSS 파이프라인 연동 고도화 계획](<261016_refac_sync-blog-repo-and-ci-workflow-triggers.md>) `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` → [⬜ Google Analytics 4 데이터 스트림 및 Search Console 연결 사용자 실행 검증](<261016_verify_connect-google-analytics-and-search-console.md>) `ibocon:261016_verify_connect-google-analytics-and-search-console` |
| 검증 대상 | [⬜ 블로그 Git 저장소 동기화 및 GitHub Actions 배포·README RSS 파이프라인 연동 고도화 계획](<261016_refac_sync-blog-repo-and-ci-workflow-triggers.md>) `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` — 해당 없음 |
| 착수 조건 | 가능 |
<!-- plan-relations-summary:end -->

## 선행 계획

| 계획 | 계획 ID | 완료 상태 | 이관한 후속 검증 |
| --- | --- | --- | --- |
| [워크플로 동기화 계획](261016_refac_sync-blog-repo-and-ci-workflow-triggers.md) | `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` | ⬜ | Google Analytics 4 (`G-K5DYPM14H9`) 웹 데이터 스트림 도메인(`blog.botanicsoft.com`) 등록·실시간 수집 및 Google Search Console 사이트맵 연동 검증 |

## 배경

`https://blog.botanicsoft.com`의 모든 페이지 `<head>`에는 `Analytics.astro`를 통해 GA4 측정 ID(`G-K5DYPM14H9`, `cookie_domain: 'botanicsoft.com'`)와 사이트맵(`https://blog.botanicsoft.com/sitemap-index.xml`)이 배포되어 있다. 본 검증 계획서에서는 Google Analytics 콘솔과 Google Search Console에서 도메인 스트림 설정, 실시간 이벤트 수신, 사이트맵 제출 및 Search Console ↔ GA4 제품 연결을 최종 확인한다.

## 검증 범위

| ID | 실행 주체 | 환경 | 대상 | 사용자 시나리오 | 필수 |
| --- | --- | --- | --- | --- | :---: |
| V1 | 사용자 | Google Analytics 4 콘솔 | `G-K5DYPM14H9` (`blog.botanicsoft.com`) | GA4 데이터 스트림 URL 확인 및 `https://blog.botanicsoft.com` 접속 시 실시간(Realtime) 리포트에서 활성 사용자 1명 이상 감지 확인 | 예 |
| V2 | 사용자 | Google Search Console 및 GA4 콘솔 | `botanicsoft.com` (`sitemap-index.xml`) | Search Console에 `https://blog.botanicsoft.com/sitemap-index.xml` 제출 및 GA4 관리 > 제품 연결 > Search Console 연결 확인 | 예 |

## 신호 도달 가능성

| ID | 판정 신호 | 발화 지점 | 조작에서 발화까지의 경로 | 차단 가드 | 도달 판정 |
| --- | --- | --- | --- | --- | :---: |
| V1 | GA4 실시간 개요(Realtime overview) 화면에 `page_view` 이벤트 및 활성 사용자 수 1 이상 표시 | `site/src/components/Analytics.astro:18` | 브라우저에서 `https://blog.botanicsoft.com` 접속 → `gtag('config', 'G-K5DYPM14H9', { cookie_domain: 'botanicsoft.com', send_page_view: true })` 실행 → Google Analytics 수집 서버 전송 | 브라우저 광고 차단기(AdBlock) 활성화 시 차단 가능 (시크릿 모드 또는 차단기 해제 필요) | 도달 가능 |
| V2 | Search Console Sitemaps 상태가 `성공(Success)`으로 표시되고 GA4 Search Console 링크가 `연결됨`으로 표시됨 | `site/astro.config.mjs:8` | `@astrojs/sitemap` 빌드 → `https://blog.botanicsoft.com/sitemap-index.xml` 배포 → Search Console 제출 | DNS TXT 소유권 미인증 시 차단 (`dns.tf`에 `google-site-verification` 이미 등록됨) | 도달 가능 |

## 사전 조건

| 항목 | 확인 방법 | 기대값 | 상태 |
| --- | --- | --- | --- |
| `blog.botanicsoft.com` GA4 스크립트 삽입 여부 | `Invoke-WebRequest https://blog.botanicsoft.com` 내 `G-K5DYPM14H9` 존재 확인 | `HAS_GA=True` | 충족 |
| `sitemap-index.xml` 정적 배포 여부 | `Invoke-WebRequest https://blog.botanicsoft.com/sitemap-index.xml` | HTTP `200 OK` | 충족 |
| Google DNS 소유권 TXT 레코드 | `lib/Garden.Cluster/infra/cloudflare/dns.tf` 내 `google-site-verification` 확인 | 등록 완료 | 충족 |

## 사용자 실행 절차

### V1: GA4(`G-K5DYPM14H9`) 웹 데이터 스트림 도메인 및 실시간(Realtime) 수집 확인

#### 에이전트 안내문

사용자에게 Google Analytics 4(`G-K5DYPM14H9`) 콘솔의 데이터 스트림 확인 및 실시간(Realtime) 리포트 확인 절차를 안내한다.

#### 사용자 수행 동작

1. [Google Analytics 콘솔](https://analytics.google.com/)에 접속하여 측정 ID `G-K5DYPM14H9` 속성의 **관리(Admin) > 데이터 수집 및 수정 > 데이터 스트림(Data Streams)** 을 연다.
2. 해당 웹 스트림의 URL을 `https://blog.botanicsoft.com`으로 갱신(또는 교차 도메인에 `botanicsoft.com` 포함 확인)하고 **향상된 측정(Enhanced measurement)** 이 켜져 있는지 확인한다.
3. 새 브라우저 탭에서 `https://blog.botanicsoft.com/` 및 포스트 상세 페이지를 클릭한 뒤, GA4 좌측 메뉴 **보고서(Reports) > 실시간(Realtime)** 화면에서 지난 30분 동안의 활성 사용자 및 `page_view` 이벤트가 집계되는지 확인한다.

#### 사용자 필수 답변

- 실행 시각
- GA4 실시간(Realtime) 화면에서 관찰된 활성 사용자 수 및 `page_view` 수신 여부

#### 필수 스크린샷 또는 로그

- GA4 실시간(Realtime) 리포트 화면 스크린샷 1장

#### 통과 기준

GA4 실시간 리포트에서 활성 사용자 1명 이상과 `page_view` 이벤트가 표시된다.

#### 응답 대기 게이트

사용자의 필수 답변과 증거가 모두 도착하기 전에는 다음 시나리오를 안내하지 않는다.

#### 판정 후 다음 단계

- PASS: 증거와 판정을 기록한 뒤 다음 시나리오로 전환한다.
- FAIL: 실제 결과와 증거 및 후속 변경 계획 링크를 기록한 뒤 다음 시나리오로 전환한다.
- BLOCKED: 해소 조건을 기록하고 계획을 미완료로 유지하며, 독립적인 다음 시나리오로 전환할 수 있다.

### V2: Google Search Console 사이트맵 제출 및 GA4 서비스 연결 확인

#### 에이전트 안내문

사용자에게 Google Search Console의 `sitemap-index.xml` 제출 및 GA4 내 Search Console 링크 연결 절차를 안내한다.

#### 사용자 수행 동작

1. [Google Search Console](https://search.google.com/search-console)에 접속하여 `botanicsoft.com` 도메인 속성(또는 `https://blog.botanicsoft.com` URL 접두어 속성)을 선택한다.
2. 좌측 메뉴 **Sitemaps(사이트맵)** 에서 새 사이트맵 URL로 `https://blog.botanicsoft.com/sitemap-index.xml`을 입력하고 **제출(Submit)** 을 클릭한다.
3. Google Analytics 4 콘솔 **관리(Admin) > 제품 연결(Product links) > Search Console 연결(Search Console links)** 에서 방금 확인한 Search Console 속성과 웹 데이터 스트림을 연결한다.

#### 사용자 필수 답변

- 실행 시각
- Search Console 사이트맵 제출 상태(`성공` 여부) 및 GA4 Search Console 연결 완료 여부

#### 필수 스크린샷 또는 로그

- Search Console Sitemaps 제출 결과 또는 GA4 Search Console 연결 완료 화면 스크린샷 1장

#### 통과 기준

`sitemap-index.xml` 상태가 정상 제출되고 GA4의 Search Console 연결 목록에 속성이 표시된다.

#### 응답 대기 게이트

사용자의 필수 답변과 증거가 모두 도착하기 전에는 다음 시나리오를 안내하지 않는다.

#### 판정 후 다음 단계

- PASS: 증거와 판정을 기록한 뒤 검증 계획을 완료(`✅`)로 마감한다.
- FAIL: 실제 결과와 증거 및 후속 변경 계획 링크를 기록한다.
- BLOCKED: 해소 조건을 기록하고 계획을 미완료로 유지한다.

## 증거 수집

| ID | 실행 시각 | 환경과 릴리스 | 입력 | 기대 결과 | 실제 결과 | 증거 | 판정 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V1 | — | — | — | — | — | — | 미실행 |
| V2 | — | — | — | — | — | — | 미실행 |

## 판정 결과

| 결과 | 시나리오 | 근거 | 후속 조치 |
| --- | --- | --- | --- |
| 미실행 | V1 | — | — |
| 미실행 | V2 | — | — |

## 결함 승격

| 실패 시나리오 | 변경 유형 | 후속 계획 | 상태 |
| --- | --- | --- | --- |
| — | — | — | 해당 없음 |

## 작업 순서

1. 사전 조건을 확인한다.
2. 현재 시나리오 하나를 `진행 중`으로 전환하고 안내한다.
3. 사용자의 필수 답변과 증거를 기다리고, 누락 항목은 같은 시나리오에서 보완 요청한다.
4. 실행 시각, 환경, 릴리스, 입력, 실제 결과와 증거 위치를 기록한다.
5. 시나리오를 `PASS`, `FAIL` 또는 `BLOCKED`로 판정한다.
6. `PASS` 또는 완전한 `FAIL`을 기록한 뒤 다음 시나리오로 전환한다.
7. `BLOCKED`는 해소 조건을 기록하고 계획을 미완료로 유지한 채 독립적인 다음 시나리오로 전환할 수 있다.
