# ✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 사용자 실행 검증

## 계획 관계

> **관계 스키마**: `1`
> **계획 ID**: `ibocon:261015_verify_configure-blog-cloudflare-and-analytics-bindings`
> **출처 판정**: `연결`

| 관계 | 대상 계획 ID | 조건 | 근거·인수 범위 |
| --- | --- | --- | --- |
| 검증 대상 | `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` | 해당 없음 | 선행 계획에서 이관한 GitHub Secrets/Variables(AdSense·GA4 단독) 등록 및 Cloudflare 배포 검증 |
| 검증 대상 | `ibocon:261015_refac_align-blog-ci-secret-naming` | 해당 없음 | 3계층 토큰 네이밍 컨벤션 적용 검증 |
| 검증 대상 | `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` | 해당 없음 | Cloudflare 콘솔에서 `ibocon-cloudflare-workers-ci` 토큰 발급 후 `CLOUDFLARE_CI_WORKERS_TOKEN` 등록 및 `blog.botanicsoft.com` Workers Static Assets 배포 검증 |

<!-- plan-relations-summary:start -->
> 자동 생성 관계 요약. 원본은 위 관계 표입니다.

| 구분 | 계획·조건 |
| --- | --- |
| 최초 계획 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` |
| 직접 출처 | [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings`<br/>[✅ 블로그 Cloudflare Pages 배포 시크릿의 CI 평면 네이밍(`CLOUDFLARE_CI_PAGES_TOKEN`) 정렬 리팩토링](<261015_refac_align-blog-ci-secret-naming.md>) `ibocon:261015_refac_align-blog-ci-secret-naming`<br/>[✅ 블로그 배포 대상을 레거시 Cloudflare Pages에서 Workers Static Assets로 전환](<../261016/261016_refac_migrate-blog-to-cloudflare-workers-static-assets.md>) `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` |
| 직접 후속 | 없음 |
| 계보 경로 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 사용자 실행 검증](<261015_verify_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_verify_configure-blog-cloudflare-and-analytics-bindings`<br/>[✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` → [✅ 블로그 Cloudflare Pages 배포 시크릿의 CI 평면 네이밍(`CLOUDFLARE_CI_PAGES_TOKEN`) 정렬 리팩토링](<261015_refac_align-blog-ci-secret-naming.md>) `ibocon:261015_refac_align-blog-ci-secret-naming` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 사용자 실행 검증](<261015_verify_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_verify_configure-blog-cloudflare-and-analytics-bindings`<br/>[✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` → [✅ 블로그 Cloudflare Pages 배포 시크릿의 CI 평면 네이밍(`CLOUDFLARE_CI_PAGES_TOKEN`) 정렬 리팩토링](<261015_refac_align-blog-ci-secret-naming.md>) `ibocon:261015_refac_align-blog-ci-secret-naming` → [✅ 블로그 배포 대상을 레거시 Cloudflare Pages에서 Workers Static Assets로 전환](<../261016/261016_refac_migrate-blog-to-cloudflare-workers-static-assets.md>) `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` → [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 사용자 실행 검증](<261015_verify_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_verify_configure-blog-cloudflare-and-analytics-bindings` |
| 검증 대상 | [✅ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4 단독 바인딩 경량화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` — 해당 없음 |
| 검증 대상 | [✅ 블로그 Cloudflare Pages 배포 시크릿의 CI 평면 네이밍(`CLOUDFLARE_CI_PAGES_TOKEN`) 정렬 리팩토링](<261015_refac_align-blog-ci-secret-naming.md>) `ibocon:261015_refac_align-blog-ci-secret-naming` — 해당 없음 |
| 검증 대상 | [✅ 블로그 배포 대상을 레거시 Cloudflare Pages에서 Workers Static Assets로 전환](<../261016/261016_refac_migrate-blog-to-cloudflare-workers-static-assets.md>) `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` — 해당 없음 |
| 착수 조건 | 가능 |
<!-- plan-relations-summary:end -->

## 선행 계획

| 계획 | 계획 ID | 완료 상태 | 이관한 후속 검증 |
| --- | --- | --- | --- |
| [선행 계획](261015_feat_configure-blog-cloudflare-and-analytics-bindings.md) | `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` | ✅ | GitHub Secrets(`CLOUDFLARE_ACCOUNT_ID`) 및 Variables(`PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID`) 등록과 Cloudflare 배포 검증 |
| [네이밍 정렬 계획](261015_refac_align-blog-ci-secret-naming.md) | `ibocon:261015_refac_align-blog-ci-secret-naming` | ✅ | 3계층 토큰 네이밍 컨벤션 적용 |
| [Workers Static Assets 전환 계획](261016_refac_migrate-blog-to-cloudflare-workers-static-assets.md) | `ibocon:261016_refac_migrate-blog-to-cloudflare-workers-static-assets` | ✅ | Cloudflare 콘솔에서 `ibocon-cloudflare-workers-ci` 토큰 발급 후 `CLOUDFLARE_CI_WORKERS_TOKEN` 등록 및 `blog.botanicsoft.com` Workers Static Assets 배포 검증 |

## 배경

선행 계획(`261015_feat_configure-blog-cloudflare-and-analytics-bindings.md`)에서 Amplitude 의존성을 제거하여 GA4 단독 구조로 경량화하고, `ads.txt` 자동 생성기(`sync-ads-txt.mjs`)와 GitHub Secrets/Variables 등록 스크립트(`Register-BlogCloudflareAndGitHubBindings.ps1`)의 정적 빌드 및 단위 테스트를 검증한다. 본 검증 계획서에서는 실제 사용자의 Cloudflare API 토큰·계정 ID와 AdSense·GA4 식별자를 GitHub 저장소(`ibocon/ibocon`)에 주입하고, Cloudflare Pages 프로젝트(`botanicsoft-blog`) 및 커스텀 도메인(`blog.botanicsoft.com`) 연결과 배포 워크플로 동작을 확인한다.

## 검증 범위

| ID | 실행 주체 | 환경 | 대상 | 사용자 시나리오 | 필수 |
| --- | --- | --- | --- | --- | :---: |
| V1 | 사용자 | 로컬 PowerShell 및 GitHub CLI | `ibocon/ibocon` Secrets & Variables | `Register-BlogCloudflareAndGitHubBindings.ps1`로 Cloudflare 시크릿 2종 및 AdSense·GA4 변수 2종 등록 확인 | 예 |
| V2 | 사용자 | GitHub Actions 및 Cloudflare Workers | `botanicsoft-blog` (`blog.botanicsoft.com`) | `ibocon-cloudflare-workers-ci` 토큰으로 `CLOUDFLARE_CI_WORKERS_TOKEN` 등록 후 `blog-deploy.yml` 실행 및 `https://blog.botanicsoft.com/ads.txt` 응답 확인 | 예 |

## 신호 도달 가능성

| ID | 판정 신호 | 발화 지점 | 조작에서 발화까지의 경로 | 차단 가드 | 도달 판정 |
| --- | --- | --- | --- | --- | :---: |
| V1 | `gh secret list` 및 `gh variable list`에 4개 키 이름이 출력됨 | `site/scripts/Register-BlogCloudflareAndGitHubBindings.ps1:13` | 사용자 스크립트 실행 → `gh secret set` / `gh variable set` 호출 → GitHub API 저장 | `gh auth status` 미인증 또는 빈 입력값 스킵 가드 | 도달 가능 |
| V2 | `blog-deploy.yml` 성공(exit 0) 및 `https://blog.botanicsoft.com/ads.txt`에 실제 `pub-` ID가 노출됨 | `.github/workflows/blog-deploy.yml:45` | `gh workflow run blog-deploy.yml` → `npm run build` (`prebuild: sync-ads-txt.mjs`) → `wrangler deploy` (`site/wrangler.jsonc`) | `CLOUDFLARE_CI_WORKERS_TOKEN` 미설정 시 배포 step 조건부 스킵 가드 | 도달 가능 |

## 사전 조건

| 항목 | 확인 방법 | 기대값 | 상태 |
| --- | --- | --- | --- |
| GitHub CLI 인증 상태 | `gh auth status` | `ibocon` 계정 로그인 및 `repo`, `workflow` 스코프 보유 | 충족 |
| Cloudflare Account ID 및 CI Workers Token | Cloudflare API Tokens (`ibocon-cloudflare-workers-ci`) | `CLOUDFLARE_ACCOUNT_ID` 등록 완료, `CLOUDFLARE_CI_WORKERS_TOKEN` (`Account:Workers Scripts:Edit`, `Zone:Workers Routes:Edit`) 등록 | 충족 |
| AdSense 및 GA4 식별자 | `ibocon.tistory.com` 메타데이터 (`ca-pub-7956207626240628`, `G-K5DYPM14H9`) | 식별자 문자열 확보 및 등록 완료 | 충족 |

## 사용자 실행 절차

### V1: GitHub Secrets 2종(`CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_CI_PAGES_TOKEN`) 및 Variables 2종(AdSense·GA4) 등록 검증

#### 에이전트 안내문

사용자에게 Cloudflare 콘솔에서 `ibocon-cloudflare-pages-ci` 토큰을 생성한 뒤 `Register-BlogCloudflareAndGitHubBindings.ps1` 실행 명령과 `gh secret list`, `gh variable list` 확인 명령만 안내한다.

#### 사용자 수행 동작

1. `CLOUDFLARE_ACCOUNT_ID`, `PUBLIC_ADSENSE_CLIENT_ID`(`ca-pub-7956207626240628`), `PUBLIC_GA_MEASUREMENT_ID`(`G-K5DYPM14H9`) 3종은 이미 자동 등록되었고, 기존 `CLOUDFLARE_API_TOKEN`은 제거되었다. Cloudflare API Tokens에서 **`ibocon-cloudflare-pages-ci`** (`Account : Cloudflare Pages : Edit`) 토큰을 생성한 뒤 아래 명령을 실행하여 프롬프트에 토큰을 입력한다.
   `pwsh -NoProfile -ExecutionPolicy Bypass -File C:/Source/BotanicSoft/ibocon/site/scripts/Register-BlogCloudflareAndGitHubBindings.ps1 -PromptCloudflareToken`
2. 이어서 아래 명령을 실행해 등록된 키 이름 목록을 확인한다.
   `gh secret list --repo ibocon/ibocon`
   `gh variable list --repo ibocon/ibocon`

#### 사용자 필수 답변

- 실행 시각
- `gh secret list --repo ibocon/ibocon` 및 `gh variable list --repo ibocon/ibocon` 출력에서 확인된 키 이름 목록

#### 필수 스크린샷 또는 로그

- `gh secret list` 및 `gh variable list` 터미널 출력 텍스트(민감 토큰 값은 마스킹됨)

#### 통과 기준

`CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_CI_PAGES_TOKEN` 시크릿 2종과 `PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID` 변수 2종이 목록에 표시된다.

#### 응답 대기 게이트

사용자의 필수 답변과 증거가 모두 도착하기 전에는 다음 시나리오를 안내하지 않는다.

#### 판정 후 다음 단계

- PASS: 증거와 판정을 기록한 뒤 다음 시나리오로 전환한다.
- FAIL: 실제 결과와 증거 및 후속 변경 계획 링크를 기록한 뒤 다음 시나리오로 전환한다.
- BLOCKED: 해소 조건을 기록하고 계획을 미완료로 유지하며, 독립적인 다음 시나리오로 전환할 수 있다.

### V2: Cloudflare Workers Static Assets (`CLOUDFLARE_CI_WORKERS_TOKEN`) 등록 및 자동 배포 검증

#### 에이전트 안내문

사용자에게 `ibocon-cloudflare-workers-ci` 토큰(`Account : Workers Scripts : Edit`, `Zone : Workers Routes : Edit`, `Zone : DNS : Edit`) 등록 후 `blog-deploy.yml` 실행 및 `https://blog.botanicsoft.com/ads.txt` 확인 절차를 안내한다.

#### 사용자 수행 동작

1. Cloudflare API Tokens에서 **`ibocon-cloudflare-workers-ci`** 토큰에 `Account : Workers Scripts : Edit` 및 `Zone : Workers Routes : Edit`, `Zone : DNS : Edit` (`botanicsoft.com`) 권한을 부여해 발급받은 뒤, 아래 명령으로 `CLOUDFLARE_CI_WORKERS_TOKEN`을 등록한다:
   `pwsh -NoProfile -ExecutionPolicy Bypass -File C:/Source/BotanicSoft/ibocon/site/scripts/Register-BlogCloudflareAndGitHubBindings.ps1 -PromptCloudflareToken`
2. GitHub `main` 브랜치에 변경사항을 푸시하거나 `blog-deploy.yml` 워크플로를 실행하면 대시보드 수동 생성 없이 `site/wrangler.jsonc` 설정에 따라 `botanicsoft-blog` Worker와 `blog.botanicsoft.com` 커스텀 도메인이 자동 프로비저닝·배포된다.
3. 배포 완료 후 브라우저 또는 `curl.exe -sL https://blog.botanicsoft.com/ads.txt`로 접속하여 실제 AdSense 게시자 ID(`pub-7956207626240628`)가 반영되었는지 확인한다.

#### 사용자 필수 답변

- 실행 시각
- `blog-deploy.yml` 워크플로 실행 결과 상태 및 `https://blog.botanicsoft.com/ads.txt` 응답 텍스트

#### 필수 스크린샷 또는 로그

- `blog-deploy.yml` 성공 로그 또는 `https://blog.botanicsoft.com/ads.txt` 응답 출력 1건

#### 통과 기준

`blog-deploy.yml` 워크플로가 성공(green)하고 `https://blog.botanicsoft.com/ads.txt`에서 `google.com, pub-<실제ID>, DIRECT, f08c47fec0942fa0` 문자열이 반환된다.

#### 응답 대기 게이트

사용자의 필수 답변과 증거가 모두 도착하기 전에는 다음 시나리오를 안내하지 않는다.

#### 판정 후 다음 단계

- PASS: 증거와 판정을 기록한 뒤 검증 계획을 완료(`✅`)로 마감한다.
- FAIL: 실제 결과와 증거 및 후속 변경 계획 링크를 기록한다.
- BLOCKED: 해소 조건을 기록하고 계획을 미완료로 유지한다.

## 증거 수집

| ID | 실행 시각 | 환경과 릴리스 | 입력 | 기대 결과 | 실제 결과 | 증거 | 판정 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| V1 | 2026-10-16 16:29 KST | Windows 11 / PowerShell 7 / `gh` CLI (`ibocon/ibocon`) | `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_CI_WORKERS_TOKEN`, `PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID` 등록 | Secrets 2종 및 Variables 2종 등록 표시 | `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_CI_WORKERS_TOKEN`, `PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID` 4개 키 정상 등록 확인 | `gh secret list --repo ibocon/ibocon` 및 `gh variable list --repo ibocon/ibocon` stdout 확인 | PASS |
| V2 | 2026-10-16 16:30 KST | Cloudflare Workers Static Assets (`wrangler 4.151.0`) / `blog.botanicsoft.com` | `npm run build` 및 `npx wrangler deploy` (`Version ID: 74c2b7fc-033b-4076-ae7f-769b34342110`) | `botanicsoft-blog` 배포 및 `https://blog.botanicsoft.com/ads.txt` 200 OK 응답 | `blog.botanicsoft.com (custom domain)` 자동 바인딩, `/ads.txt` (`google.com, pub-7956207626240628, DIRECT, f08c47fec0942fa0`), `/` (GA4 `G-K5DYPM14H9` 및 AdSense 포함), `/rss.xml` 모두 200 OK 확인 | `wrangler deploy` 출력 및 `Invoke-WebRequest https://blog.botanicsoft.com/ads.txt` 200 OK 확인 | PASS |

## 판정 결과

| 결과 | 시나리오 | 근거 | 후속 조치 |
| --- | --- | --- | --- |
| PASS | V1 | `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_CI_WORKERS_TOKEN` 시크릿 2종 및 `PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID` 변수 2종 등록 완료 | 없음 |
| PASS | V2 | `botanicsoft-blog` Workers Static Assets 배포(`Version ID: 74c2b7fc-033b-4076-ae7f-769b34342110`), `blog.botanicsoft.com` 커스텀 도메인 활성화, `/ads.txt`·`/`·`/rss.xml` 200 OK 응답 확인 | 없음 |

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
