# ⬜ Google AdSense 도메인·`ads.txt`·광고 슬롯 연결 사용자 실행 검증

## 계획 관계

> **관계 스키마**: `1`
> **계획 ID**: `ibocon:261016_verify_connect-google-adsense-domain-and-slots`
> **출처 판정**: `연결`

| 관계 | 대상 계획 ID | 조건 | 근거·인수 범위 |
| --- | --- | --- | --- |
| 검증 대상 | `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` | 해당 없음 | `https://blog.botanicsoft.com`에 배포된 Google AdSense(`ca-pub-7956207626240628`) 및 `/ads.txt`의 AdSense 콘솔 사이트 등록·승인·GA4 수익 연동 검증 |

<!-- plan-relations-summary:start -->
> 자동 생성 관계 요약. 원본은 위 관계 표입니다.

| 구분 | 계획·조건 |
| --- | --- |
| 최초 계획 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<../history/2610/W3/261015/261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` |
| 직접 출처 | [⬜ 블로그 Git 저장소 동기화 및 GitHub Actions 배포·README RSS 파이프라인 연동 고도화 계획](<261016_refac_sync-blog-repo-and-ci-workflow-triggers.md>) `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` |
| 직접 후속 | 없음 |
| 계보 경로 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<../history/2610/W3/261015/261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<../history/2610/W3/261015/261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` → [✅ 블로그 Cloudflare Pages 배포 시크릿의 CI 평면 네이밍(`CLOUDFLARE_CI_PAGES_TOKEN`) 정렬 리팩토링](<../history/2610/W3/261015/261015_refac_align-blog-ci-secret-naming.md>) `ibocon:261015_refac_align-blog-ci-secret-naming` → [✅ 블로그 배포 대상을 레거시 Cloudflare Pages에서 Workers Static Assets로 전환](<../history/2610/W3/261016/261016_refac_migrate-blog-to-cloudflare-workers-static-assets.md>) `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` → [⬜ 블로그 Git 저장소 동기화 및 GitHub Actions 배포·README RSS 파이프라인 연동 고도화 계획](<261016_refac_sync-blog-repo-and-ci-workflow-triggers.md>) `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` → [⬜ Google AdSense 도메인·`ads.txt`·광고 슬롯 연결 사용자 실행 검증](<261016_verify_connect-google-adsense-domain-and-slots.md>) `ibocon:261016_verify_connect-google-adsense-domain-and-slots` |
| 검증 대상 | [⬜ 블로그 Git 저장소 동기화 및 GitHub Actions 배포·README RSS 파이프라인 연동 고도화 계획](<261016_refac_sync-blog-repo-and-ci-workflow-triggers.md>) `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` — 해당 없음 |
| 착수 조건 | 가능 |
<!-- plan-relations-summary:end -->

## 선행 계획

| 계획 | 계획 ID | 완료 상태 | 이관한 후속 검증 |
| --- | --- | --- | --- |
| [워크플로 동기화 계획](261016_refac_sync-blog-repo-and-ci-workflow-triggers.md) | `ibocon:261016_refac_sync-blog-repo-and-ci-workflow-triggers` | ⬜ | Google AdSense (`ca-pub-7956207626240628`) 사이트(`botanicsoft.com`, `blog.botanicsoft.com`) 등록·`ads.txt` 승인 및 광고 슬롯 활성화 검증 |

## 배경

`https://blog.botanicsoft.com/ads.txt`에는 `google.com, pub-7956207626240628, DIRECT, f08c47fec0942fa0` 레코드가 배포되어 있으며, 블로그 홈 및 포스트 상세 페이지에는 `AdSenseSlot.astro`(`ca-pub-7956207626240628`) 컴포넌트가 삽입되어 있다. 본 검증 계획서에서는 Google AdSense 콘솔에서 `botanicsoft.com` 및 하위 도메인 `blog.botanicsoft.com`을 사이트로 등록하고, `ads.txt` 상태 확인과 자동 광고(Auto ads)·GA4 수익 연동 설정을 마무리한다.

## 검증 범위

| ID | 실행 주체 | 환경 | 대상 | 사용자 시나리오 | 필수 |
| --- | --- | --- | --- | --- | :---: |
| V1 | 사용자 | Google AdSense 콘솔 | `botanicsoft.com` 및 `blog.botanicsoft.com` | AdSense **사이트(Sites)** 메뉴에 `botanicsoft.com` 추가 및 하위 도메인 `blog.botanicsoft.com` 등록·소유권 확인 요청 | 예 |
| V2 | 사용자 | Google AdSense 및 GA4 콘솔 | `ca-pub-7956207626240628` 광고 설정 및 GA4 연동 | AdSense **광고(Ads)** 메뉴에서 자동 광고(Auto ads) 활성화 및 GA4 **제품 연결 > AdSense 연결** 설정 확인 | 예 |

## 신호 도달 가능성

| ID | 판정 신호 | 발화 지점 | 조작에서 발화까지의 경로 | 차단 가드 | 도달 판정 |
| --- | --- | --- | --- | --- | :---: |
| V1 | AdSense 사이트 목록에 `botanicsoft.com`(하위 도메인 `blog.botanicsoft.com` 포함)이 등록되고 소유권 확인(코드 스니펫 또는 `ads.txt`) 통과 표시 | `site/src/components/AdSenseSlot.astro:16` | AdSense 크롤러가 `https://blog.botanicsoft.com`의 `adsbygoogle.js?client=ca-pub-7956207626240628` 및 `/ads.txt`를 스캔 → 소유권 확인 완료 | 루트 `https://botanicsoft.com/ads.txt` 조회 시 리다이렉트 미설정이면 AdSense 코드 스니펫 방식으로 소유권 확인 통과 가능 | 도달 가능 |
| V2 | AdSense 광고 설정에서 `Auto ads`가 `켜짐(On)`으로 표시되고 GA4 제품 연결의 AdSense 링크가 `연결됨`으로 표시됨 | `site/src/components/AdSenseSlot.astro:21` | AdSense 콘솔 > 광고 > 사이트별 설정 > 자동 광고 활성화 → 사이트에 적용 클릭 | 없음 | 도달 가능 |

## 사전 조건

| 항목 | 확인 방법 | 기대값 | 상태 |
| --- | --- | --- | --- |
| `https://blog.botanicsoft.com/ads.txt` 응답 | `Invoke-WebRequest https://blog.botanicsoft.com/ads.txt` | `google.com, pub-7956207626240628, DIRECT, f08c47fec0942fa0` (`200 OK`) | 충족 |
| 페이지 내 AdSense 클라이언트 스크립트 | `Invoke-WebRequest https://blog.botanicsoft.com/` | `ca-pub-7956207626240628` 포함 (`HAS_ADSENSE=True`) | 충족 |

## 사용자 실행 절차

### V1: Google AdSense 사이트(`botanicsoft.com` 및 `blog.botanicsoft.com`) 등록 및 소유권 확인

#### 에이전트 안내문

사용자에게 Google AdSense 콘솔의 **사이트(Sites)** 메뉴에서 도메인 등록 및 소유권 확인 절차를 안내한다.

#### 사용자 수행 동작

1. [Google AdSense 콘솔](https://www.google.com/adsense/)에 로그인한 뒤 좌측 메뉴 **사이트(Sites) > `+ 새 사이트(New site)`** 를 클릭한다.
2. 사이트 URL에 `botanicsoft.com`을 입력하고 **저장**을 클릭한다.
3. 소유권 확인 방법으로 **애드센스 코드 스니펫(AdSense code snippet)** 또는 **ads.txt 스니펫**을 선택하고 **확인(Verify) → 검토 요청(Request review)** 을 클릭한다.
4. 등록된 `botanicsoft.com` 사이트 상세 화면의 **하위 도메인(Subdomains)** 섹션에서 **`blog.botanicsoft.com`** 을 추가한다.

#### 사용자 필수 답변

- 실행 시각
- AdSense 사이트 목록에 `botanicsoft.com` 및 하위 도메인 `blog.botanicsoft.com` 추가 완료 여부

#### 필수 스크린샷 또는 로그

- Google AdSense **사이트(Sites)** 등록 결과 화면 스크린샷 1장

#### 통과 기준

AdSense 사이트 목록에 `botanicsoft.com`(하위 도메인 `blog.botanicsoft.com`)이 등록되고 검토 요청(또는 준비 완료) 상태가 표시된다.

#### 응답 대기 게이트

사용자의 필수 답변과 증거가 모두 도착하기 전에는 다음 시나리오를 안내하지 않는다.

#### 판정 후 다음 단계

- PASS: 증거와 판정을 기록한 뒤 다음 시나리오로 전환한다.
- FAIL: 실제 결과와 증거 및 후속 변경 계획 링크를 기록한 뒤 다음 시나리오로 전환한다.
- BLOCKED: 해소 조건을 기록하고 계획을 미완료로 유지하며, 독립적인 다음 시나리오로 전환할 수 있다.

### V2: Google AdSense 자동 광고(Auto ads) 활성화 및 GA4 수익 연동 확인

#### 에이전트 안내문

사용자에게 AdSense 자동 광고(Auto ads) 활성화 및 Google Analytics 4(`G-K5DYPM14H9`)와의 AdSense 제품 연결 절차를 안내한다.

#### 사용자 수행 동작

1. Google AdSense 콘솔 좌측 메뉴 **광고(Ads) > 사이트 기준(By site)** 에서 `botanicsoft.com` 우측의 **수정(연필 아이콘)** 을 클릭한다.
2. 우측 패널 상단의 **자동 광고(Auto ads)** 토글을 켜고, 하단의 **사이트에 적용(Apply to site)** 을 클릭한다.
3. [Google Analytics 4 콘솔](https://analytics.google.com/)(`G-K5DYPM14H9`)의 **관리(Admin) > 제품 연결(Product links) > 애드센스 연결(AdSense links)** 로 이동하여 **`연결(Link)`** 버튼을 클릭하고 본인 AdSense 계정(`pub-7956207626240628`)과 웹 데이터 스트림을 연결한다.

#### 사용자 필수 답변

- 실행 시각
- AdSense 자동 광고 `켜짐(On)` 적용 여부 및 GA4 AdSense 제품 연결 완료 여부

#### 필수 스크린샷 또는 로그

- AdSense 자동 광고 활성화 화면 또는 GA4 애드센스 연결 완료 화면 스크린샷 1장

#### 통과 기준

AdSense 자동 광고가 활성화(`On`)되고 GA4 애드센스 연결 목록에 `pub-7956207626240628` 연결이 표시된다.

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
