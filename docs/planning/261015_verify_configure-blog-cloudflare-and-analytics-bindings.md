# ⬜ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4·Amplitude 바인딩 사용자 실행 검증

## 계획 관계

> **관계 스키마**: `1`
> **계획 ID**: `ibocon:261015_verify_configure-blog-cloudflare-and-analytics-bindings`
> **출처 판정**: `연결`

| 관계 | 대상 계획 ID | 조건 | 근거·인수 범위 |
| --- | --- | --- | --- |
| 검증 대상 | `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` | 해당 없음 | 선행 계획에서 이관한 GitHub Secrets/Variables 등록 및 Cloudflare Pages `blog.botanicsoft.com` 실배포·수익화·분석 연동 검증 |

<!-- plan-relations-summary:start -->
> 자동 생성 관계 요약. 원본은 위 관계 표입니다.

| 구분 | 계획·조건 |
| --- | --- |
| 최초 계획 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<../history/2610/W3/261015/261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` |
| 직접 출처 | [⬜ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4·Amplitude 바인딩 자동화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` |
| 직접 후속 | 없음 |
| 계보 경로 | [✅ Astro 및 Cloudflare Pages 기반 마크다운 기술 블로그 구축 계획](<../history/2610/W3/261015/261015_feat_astro-markdown-blog-cloudflare-pages.md>) `ibocon:261015_feat_astro-markdown-blog-cloudflare-pages` → [⬜ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4·Amplitude 바인딩 자동화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` → [⬜ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4·Amplitude 바인딩 사용자 실행 검증](<261015_verify_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_verify_configure-blog-cloudflare-and-analytics-bindings` |
| 검증 대상 | [⬜ 블로그 Cloudflare Pages 배포 시크릿 및 AdSense·GA4·Amplitude 바인딩 자동화 계획](<261015_feat_configure-blog-cloudflare-and-analytics-bindings.md>) `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` — 해당 없음 |
| 착수 조건 | 가능 |
<!-- plan-relations-summary:end -->

## 선행 계획

| 계획 | 계획 ID | 완료 상태 | 이관한 후속 검증 |
| --- | --- | --- | --- |
| [선행 계획](261015_feat_configure-blog-cloudflare-and-analytics-bindings.md) | `ibocon:261015_feat_configure-blog-cloudflare-and-analytics-bindings` | ⬜ | GitHub Secrets(`CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`) 및 Variables(`PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID`, `PUBLIC_AMPLITUDE_API_KEY`) 등록과 Cloudflare Pages(`botanicsoft-blog`, `blog.botanicsoft.com`) 실배포 검증 |

## 배경

선행 계획(`261015_feat_configure-blog-cloudflare-and-analytics-bindings.md`)에서 `ads.txt` 자동 생성기(`sync-ads-txt.mjs`)와 GitHub Secrets/Variables 등록 스크립트(`Register-BlogCloudflareAndGitHubBindings.ps1`)의 정적 빌드 및 단위 테스트를 검증한다. 본 검증 계획서에서는 실제 사용자의 Cloudflare API 토큰·계정 ID와 AdSense·GA4·Amplitude 식별자를 GitHub 저장소(`ibocon/ibocon`)에 주입하고, Cloudflare Pages 프로젝트(`botanicsoft-blog`) 및 커스텀 도메인(`blog.botanicsoft.com`) 연결과 배포 워크플로 동작을 확인한다.

## 검증 범위

| ID | 실행 주체 | 환경 | 대상 | 사용자 시나리오 | 필수 |
| --- | --- | --- | --- | --- | :---: |
| V1 | 사용자 | 로컬 PowerShell 및 GitHub CLI | `ibocon/ibocon` Secrets & Variables | `Register-BlogCloudflareAndGitHubBindings.ps1`로 Cloudflare 시크릿 2종 및 AdSense·GA4·Amplitude 변수 3종 등록 확인 | 예 |
| V2 | 사용자 | Cloudflare Dashboard 및 GitHub Actions | `botanicsoft-blog` (`blog.botanicsoft.com`) | Cloudflare Pages 프로젝트 생성·도메인 연결 후 `blog-deploy.yml` 워크플로 실행 및 `https://blog.botanicsoft.com/ads.txt` 응답 확인 | 예 |

## 신호 도달 가능성

| ID | 판정 신호 | 발화 지점 | 조작에서 발화까지의 경로 | 차단 가드 | 도달 판정 |
| --- | --- | --- | --- | --- | :---: |
| V1 | `gh secret list` 및 `gh variable list`에 5개 키 이름이 출력됨 | `site/scripts/Register-BlogCloudflareAndGitHubBindings.ps1:14` | 사용자 스크립트 실행 → `gh secret set` / `gh variable set` 호출 → GitHub API 저장 | `gh auth status` 미인증 또는 빈 입력값 스킵 가드 | 도달 가능 |
| V2 | `blog-deploy.yml` 성공(exit 0) 및 `https://blog.botanicsoft.com/ads.txt`에 실제 `pub-` ID가 노출됨 | `.github/workflows/blog-deploy.yml:41` | `gh workflow run blog-deploy.yml` → `npm run build` (`prebuild: sync-ads-txt.mjs`) → `wrangler pages deploy` | `CLOUDFLARE_API_TOKEN` 미설정 시 배포 step 조건부 스킵 가드 | 도달 가능 |

## 사전 조건

| 항목 | 확인 방법 | 기대값 | 상태 |
| --- | --- | --- | --- |
| GitHub CLI 인증 상태 | `gh auth status` | `ibocon` 계정 로그인 및 `repo`, `workflow` 스코프 보유 | 미충족 |
| Cloudflare Account ID 및 API Token | Cloudflare 대시보드 > My Profile > API Tokens (`Cloudflare Pages: Edit` 권한) | 32자리 Account ID 및 API Token 준비 | 미충족 |
| AdSense / GA4 / Amplitude 식별자 | 각 콘솔에서 `ca-pub-...`, `G-...`, Amplitude Project API Key 확인 | 식별자 문자열 준비 | 미충족 |

## 사용자 실행 절차

### V1: GitHub Secrets 2종 및 Variables 3종 등록 검증

#### 에이전트 안내문

사용자에게 `Register-BlogCloudflareAndGitHubBindings.ps1` 실행 명령과 `gh secret list`, `gh variable list` 확인 명령만 안내한다.

#### 사용자 수행 동작

1. 로컬 PowerShell 터미널에서 아래 명령을 실행하여 Cloudflare 계정 ID와 AdSense·GA4·Amplitude 식별자를 전달하고, 프롬프트가 뜨면 `CLOUDFLARE_API_TOKEN`을 입력한다(비밀값 원문은 대화창에 붙여넣지 않는다).
   `pwsh -NoProfile -ExecutionPolicy Bypass -File site/scripts/Register-BlogCloudflareAndGitHubBindings.ps1 -CloudflareAccountId "<ACCOUNT_ID>" -AdSenseClientId "<CA_PUB_ID>" -GaMeasurementId "<G_ID>" -AmplitudeApiKey "<AMPLITUDE_KEY>" -PromptCloudflareToken`
2. 이어서 아래 명령을 실행해 등록된 키 이름 목록을 확인한다.
   `gh secret list --repo ibocon/ibocon`
   `gh variable list --repo ibocon/ibocon`

#### 사용자 필수 답변

- 실행 시각
- `gh secret list --repo ibocon/ibocon` 및 `gh variable list --repo ibocon/ibocon` 출력에서 확인된 키 이름 목록

#### 필수 스크린샷 또는 로그

- `gh secret list` 및 `gh variable list` 터미널 출력 텍스트(민감 토큰 값은 마스킹됨)

#### 통과 기준

`CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_API_TOKEN` 시크릿 2종과 `PUBLIC_ADSENSE_CLIENT_ID`, `PUBLIC_GA_MEASUREMENT_ID`, `PUBLIC_AMPLITUDE_API_KEY` 변수 3종이 목록에 표시된다.

#### 응답 대기 게이트

사용자의 필수 답변과 증거가 모두 도착하기 전에는 다음 시나리오를 안내하지 않는다.

#### 판정 후 다음 단계

- PASS: 증거와 판정을 기록한 뒤 다음 시나리오로 전환한다.
- FAIL: 실제 결과와 증거 및 후속 변경 계획 링크를 기록한 뒤 다음 시나리오로 전환한다.
- BLOCKED: 해소 조건을 기록하고 계획을 미완료로 유지하며, 독립적인 다음 시나리오로 전환할 수 있다.

### V2: Cloudflare Pages 프로젝트·커스텀 도메인 연결 및 실배포 검증

#### 에이전트 안내문

사용자에게 Cloudflare Pages `botanicsoft-blog` 프로젝트 생성, `blog.botanicsoft.com` 커스텀 도메인 연결, 그리고 `blog-deploy.yml` 워크플로 디스패치 및 `/ads.txt` 확인 절차를 안내한다.

#### 사용자 수행 동작

1. Cloudflare 대시보드(Workers & Pages)에서 `botanicsoft-blog` Pages 프로젝트를 생성하고 Custom Domains 탭에서 `blog.botanicsoft.com`을 연결한다.
2. GitHub Actions에서 `Build and Deploy Blog to Cloudflare Pages` (`blog-deploy.yml`) 워크플로를 실행한다.
3. 배포 완료 후 브라우저 또는 `curl https://blog.botanicsoft.com/ads.txt`로 접속하여 실제 AdSense 게시자 ID(`pub-...`)가 반영되었는지 확인한다.

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
