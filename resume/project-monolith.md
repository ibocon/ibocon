# 🧱 [전사 백엔드] .NET 9 모듈 모노레포 & 대규모 API GW (Monolith)

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🧱 [전사 백엔드] .NET 9 모듈 모노레포 & 대규모 API GW (Monolith)](https://app.notion.com/p/3dd4752186758105801dea0310df86f5)  
> **최종 동기화 일시**: 2026-10-14

---

<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2025.08 – 현재</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>망고슬래브 · 모노레포 설계·통합 주도, Oxygen 서비스·클라이언트 전담 개발, 에이전트 하네스 도입</td>
</tr>
<tr>
<td>기여</td>
<td>저장소 전체 커밋의 약 75% (1,634 / 2,191, 나머지 대부분은 Flux 이미지 자동화 봇) · Oxygen 디렉터리 커밋 568 / 569</td>
</tr>
<tr>
<td>규모</td>
<td>Oxygen 기준 C# 2,600+ 파일 · Razor 140+ 파일 · 약 19만 줄, 프로젝트 53개(테스트 25개), 컨테이너 이미지 12종</td>
</tr>
<tr>
<td>상태</td>
<td>staging 운영 중 · 하위 시스템 5개 통합</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`.NET 9` `.NET Aspire` `YARP` `RabbitMQ` `EF Core · PostgreSQL` `Keycloak/OIDC` `Redis` `OpenTelemetry` `Blazor` `MAUI Blazor Hybrid` `Slack · Teams · Zapier` `Roslyn 애널라이저`</td>
</tr>
</table>
## 개요
nemonic 관련 서비스·앱·펌웨어·클러스터 정의를 한 저장소로 통합한 모노레포입니다. 그중 **Oxygen**은 nemonic 프린터를 클라우드에서 연결·인쇄·관리하는 핵심 제품군으로, 마이크로서비스 백엔드와 API 게이트웨이, Slack·Teams·Zapier 커넥터, Blazor 웹·관리 콘솔, Windows 데스크톱(Nemonic Connect)·모바일 앱까지를 하나의 빌드·컨벤션·계획서 체계 안에서 개발합니다.
## 구성 요소 (모노레포)
<table fit-page-width="true" header-row="true">
<tr>
<td>하위 시스템</td>
<td>역할</td>
</tr>
<tr>
<td>Oxygen</td>
<td>서버 서비스·게이트웨이·커넥터, 웹 BFF, 관리 콘솔, 데스크톱·모바일 앱, 로컬 인프라 AppHost (아래 상세)</td>
</tr>
<tr>
<td>Mango</td>
<td>MAUI·Razor 공용 라이브러리(프린터 전송·미리보기 등)</td>
</tr>
<tr>
<td>Lithium</td>
<td>FINECUBE 모바일 앱 (별도 저장소에서 이관)</td>
</tr>
<tr>
<td>Argon</td>
<td>GitOps 클러스터 정의(apps·infra·identity·operands) — Oxygen 이미지의 Flux 배포 대상</td>
</tr>
<tr>
<td>Firmware</td>
<td>nemonic·aesty 프린터 펌웨어</td>
</tr>
</table>
## Oxygen 아키텍처
### 백엔드 서비스 (`src/Oxygen/Svc`)
<table fit-page-width="true" header-row="true">
<tr>
<td>서비스</td>
<td>책임</td>
<td>비고</td>
</tr>
<tr>
<td>ApiGW</td>
<td>YARP 리버스 프록시 API 게이트웨이. JWT Bearer 검증, 클레임→헤더 변환, 요청 속도 제한, 서비스 디스커버리 기반 목적지 해석</td>
<td>업스트림 OpenAPI 문서를 프로필별로 병합해 `/openapi/gateway/{profile}.json`과 Swagger UI로 공개</td>
</tr>
<tr>
<td>User</td>
<td>사용자 계정 생성·조회·수정·삭제, 연결된 외부 플랫폼(Slack·Teams) 관리, 데스크톱 로그인 콜백</td>
<td>Keycloak 연동, RabbitMQ로 사용자 삭제 이벤트 발행</td>
</tr>
<tr>
<td>Printer</td>
<td>프린터 등록·검색·PIN 코드·소유자 매핑, 사용자 삭제 시 정리</td>
<td>PostgreSQL, 상태 변경 이벤트 발행</td>
</tr>
<tr>
<td>PrintJob</td>
<td>텍스트·이미지·SVG 인쇄 요청, 래스터 데이터 pull 방식 전달, 작업 제어·이력·삭제</td>
<td>SkiaSharp·Svg.Skia로 서버 측 래스터 변환, S3 호환 저장</td>
</tr>
<tr>
<td>Temp</td>
<td>인쇄 템플릿·메모 저장과 관리</td>
<td>Redis 캐시, 파일 저장소</td>
</tr>
<tr>
<td>Notifier</td>
<td>PrintJob 요청·상태 변경, Printer 상태 변경 이벤트를 구독해 알림 전달</td>
<td>RabbitMQ 컨슈머 전용 호스트</td>
</tr>
<tr>
<td>Web</td>
<td>Blazor Interactive Server 기반 웹 BFF. OIDC 로그인, 기기·인쇄 작업·템플릿 화면, 계정 삭제, 다국어</td>
<td>Printer·PrintJob·User·Slack 클라이언트 어댑터를 한 DI 컴포지션 루트로 구성</td>
</tr>
<tr>
<td>Cnctr/Slack</td>
<td>Slack 앱 커넥터. 슬래시 커맨드·인터랙션·숏컷·모달·이벤트 수신, 홈 탭 대시보드, 프린터 등록·테스트·설정</td>
<td>Block Kit 빌더 계층 별도 분리</td>
</tr>
<tr>
<td>Cnctr/Teams</td>
<td>Microsoft Teams 앱 커넥터. Teams SDK 기반 에이전트(NemonicAgent), 카드 UI, 인쇄·프린터·템플릿 명령</td>
<td>Microsoft Graph 연동, 한국어·영어 리소스</td>
</tr>
<tr>
<td>Cnctr/Zap</td>
<td>Zapier 연동 REST API. v2·v3 인쇄 엔드포인트, 인쇄 소스 해석, 사용자 해석 오류 매핑</td>
<td>API 버전 관리(Asp.Versioning)</td>
</tr>
<tr>
<td>Contract</td>
<td>서비스 간 공유 계약: 요청·응답 DTO, 오류 응답 규격, RabbitMQ 라우팅 키</td>
<td>User·Printer·PrintJob·Temp 각각 `.Client` 프로젝트로 타입 안전 HTTP 클라이언트 제공</td>
</tr>
<tr>
<td>Bootstrap · Aspire</td>
<td>서비스별 `bootstrap` 인자로 실행되는 마이그레이션·시드 단계 오케스트레이션과, 전 서비스를 한 번에 띄우는 Aspire AppHost</td>
<td>Tailscale 앰배서더 컨테이너로 로컬 개발 환경을 tailnet에 노출</td>
</tr>
</table>
### 클라이언트·관리
<table fit-page-width="true" header-row="true">
<tr>
<td>구성</td>
<td>내용</td>
</tr>
<tr>
<td>Desktop (`Oxy.Desktop`)</td>
<td>Windows용 .NET MAUI Blazor Hybrid 앱 **Nemonic Connect**. 빌드 시 어셈블리에 포함한 환경 메타데이터로 appsettings·개발자 도구 정책을 결정, `client_credentials` 비대화형 OIDC 인증, MSIX staging 카탈로그 배포. `Oxy.Desktop.Web`은 Web Bluetooth/WebUSB 프린터 검색을 검증하는 브라우저 미리보기 호스트</td>
</tr>
<tr>
<td>Mobile (`Oxygen.Mobile`)</td>
<td>Android·iOS .NET MAUI 앱과 공용 Razor 코어(`Mobile.Core`)·웹 미리보기 호스트(`Mobile.Web`)</td>
</tr>
<tr>
<td>Mgmt (`Oxy.Mgmt`)</td>
<td>운영자용 Blazor 관리 콘솔. 사용자·프린터·템플릿·데스크톱 수명주기·아이덴티티 관리, MudBlazor + Garden.Razor 디자인 시스템, Redis 분산 상태</td>
</tr>
<tr>
<td>Infra (`Oxygen.Infra.Aspire`)</td>
<td>로컬 개발 인프라 AppHost: PostgreSQL(pgAdmin)·Redis(RedisInsight)·RabbitMQ·Keycloak·Seq·OpenTelemetry Collector를 한 번에 기동하고, Bootstrap 프로젝트가 Seq 관리자·API 키를 시드</td>
</tr>
</table>
## 기술 스택
<table fit-page-width="true" header-row="true">
<tr>
<td>영역</td>
<td>구성</td>
</tr>
<tr>
<td>런타임 · 오케스트레이션</td>
<td>.NET 9, .NET Aspire AppHost 2종(Infra·Svc), Garden.Aspire 확장(Tailscale·Keycloak·Seq·OTel Collector 리소스)</td>
</tr>
<tr>
<td>백엔드</td>
<td>[ASP.NET](http://ASP.NET) Core Minimal API·Controllers, YARP 리버스 프록시, RabbitMQ.Client 메시징, EF Core + Npgsql(PostgreSQL), Garden.Share 자체 Mediator·도메인 이벤트 디스패치, Scrutor DI 스캔</td>
</tr>
<tr>
<td>인증 · 세션 · 캐시</td>
<td>Keycloak OIDC / JWT Bearer, Redis 기반 DataProtection 키링·분산 캐시·HybridCache</td>
</tr>
<tr>
<td>클라이언트</td>
<td>Blazor Interactive Server, .NET MAUI Blazor Hybrid(Windows)·MAUI(Android·iOS), MudBlazor, CommunityToolkit.Mvvm/Maui, WebView2</td>
</tr>
<tr>
<td>연동</td>
<td>Slack Web API·Block Kit, Microsoft Teams SDK(Agents)·Microsoft Graph, Zapier REST, AWS S3 호환 스토리지, SkiaSharp·Svg.Skia 래스터 렌더링</td>
</tr>
<tr>
<td>관측성</td>
<td>OpenTelemetry OTLP 트레이스·로그 → Collector → Seq, Serilog 구조화 로깅, HealthChecks(`/health`·`/healthz`) Kubernetes probe</td>
</tr>
<tr>
<td>API 계약</td>
<td>OpenAPI(Swashbuckle·Microsoft.AspNetCore.OpenApi), Asp.Versioning, 게이트웨이 OpenAPI 카탈로그 병합, Flurl·Polly 재시도 기반 타입 안전 클라이언트</td>
</tr>
<tr>
<td>품질</td>
<td>xUnit·FluentAssertions·NSubstitute, bunit(Razor), [WireMock.Net](http://WireMock.Net), Testcontainers(PostgreSQL) 통합 테스트, NetArchTest 아키텍처 테스트, Roslyn 커스텀 애널라이저(Garden.Analyzers)</td>
</tr>
<tr>
<td>CI/CD · 배포</td>
<td>GitHub Actions 서비스별 이미지 퍼블리시 워크플로 13종, Desktop MSIX staging 배포·카탈로그 등록, Teams 앱 릴리스, Argon(Flux GitOps)로 Kubernetes 반영, 자체 호스팅 러너 라우팅</td>
</tr>
</table>
## 주요 작업
- 하위 시스템 5개를 하나의 빌드·컨벤션·계획서 체계로 통합하고 공용 라이브러리(Garden.Share·Garden.AspNetCore·Garden.Aspire·Garden.Razor)를 서비스 공통 기반으로 정착
- Oxygen 백엔드를 User·Printer·PrintJob·Temp·Notifier 서비스와 YARP 게이트웨이로 분리하고, Contract·Client 프로젝트로 서비스 간 계약을 타입 안전하게 정의
- Slack·Microsoft Teams·Zapier 세 채널에서 nemonic 프린터 등록과 인쇄를 수행하는 커넥터 서비스를 설계·구현
- Blazor 웹 BFF와 운영자 관리 콘솔, Windows 데스크톱(Nemonic Connect)·모바일 앱까지 클라이언트 전 계층을 동일한 인증(Keycloak)·관측성(OTLP) 계약으로 통일
- Aspire AppHost 2종으로 인프라(PostgreSQL·Redis·RabbitMQ·Keycloak·Seq·OTel Collector)와 전 서비스를 한 명령으로 기동하는 로컬 개발 환경 구축, Tailscale 앰배서더 컨테이너로 외부 웹훅 수신까지 로컬에서 검증
- Claude Code·Codex·Gemini CLI가 공유하는 AI 코딩 에이전트 하네스(컨벤션·가드·계획서 규약)를 도입해 AI 보조 개발을 팀 표준으로 정착
- 계획서(docs/planning) 작성 → 구현 → 검증 → 아카이브(docs/history) 흐름과 이를 강제하는 PowerShell 정적 가드 구축
- Roslyn 커스텀 애널라이저로 네임스페이스·DI 등록·메서드 체인 래핑 규약을 빌드 단계에서 강제
- 서비스별 GitHub Actions 이미지 퍼블리시와 Flux 이미지 자동화, 자체 호스팅 러너 라우팅으로 staging 자동 배포 파이프라인 구성
## 링크
- 저장소: [github.com/MANGOSLABCoLtd/Monolith](https://github.com/MANGOSLABCoLtd/Monolith) (private)
- 이관된 프로젝트: <mention-page url="https://app.notion.com/p/3dd4752186758104a1e1d8e1f9174433"/> · <mention-page url="https://app.notion.com/p/3dd475218675813aa4cdfa7fca9e534a"/>
- 하네스·라이브러리 원류: <mention-page url="https://app.notion.com/p/3dd475218675812db4c9cdc9aa23003f"/>
---
## 📂 세부 기여 저장소 및 기술 이력 상세 (14개 저장소 연계)
<table header-row="true">
<tr>
<td>저장소</td>
<td>활동 기간</td>
<td>기여량</td>
<td>핵심 역할 및 기술적 성과</td>
</tr>
<tr>
<td>**Monolith**</td>
<td>2026.01 – 현재</td>
<td>132 Commits, 70 PRs, 84 Issues</td>
<td>회사 통합 .NET 모노레포 설계·통합 주도, 전체 커밋의 75% 기여, Oxygen 12개 마이크로서비스 백엔드 및 YARP 게이트웨이 전담 개발, AI 코딩 에이전트 하네스 도입</td>
</tr>
<tr>
<td>**Oxygen.Hub**</td>
<td>2023.01 – 2026.01</td>
<td>37 Commits, 6 Issues</td>
<td>분산 인쇄 서비스를 중계하던 중앙 허브 서버 개발 및 Monolith ApiGW/마이크로서비스 흡수 이관</td>
</tr>
<tr>
<td>**Oxygen.Teams**</td>
<td>2022.09 – 2025.12</td>
<td>101 Commits, 2 PRs</td>
<td>Microsoft Teams 인쇄 봇(NemonicAgent) 개발, Microsoft Graph 연동, 모노레포 커넥터(Cnctr/Teams)로 통합</td>
</tr>
<tr>
<td>**Oxygen.Slack**</td>
<td>2023.02 – 2025.12</td>
<td>43 Commits, 1 PR, 9 Issues</td>
<td>Slack Block Kit 기반 인쇄 앱, 슬래시 커맨드/인터랙션/홈 탭 대시보드 개발, Cnctr/Slack으로 통합</td>
</tr>
<tr>
<td>**Zinc.Zapier**</td>
<td>2025.11 – 2025.11</td>
<td>1 Commit</td>
<td>Zapier 연동 프로젝트 환경별 설정 구성 및 Monolith Cnctr/Zap 이관 후 v2/v3 인쇄 API(Asp.Versioning) 개발</td>
</tr>
<tr>
<td>**Oxygen.Web**</td>
<td>2025.09 – 2025.09</td>
<td>19 Commits</td>
<td>Blazor Interactive Server 기반 Web BFF 및 관리/인쇄 웹 포털 개발, Svc/Web으로 통합</td>
</tr>
<tr>
<td>**Oxygen.Amplitude**</td>
<td>2023.04 – 2025.11</td>
<td>2 Commits, 2 Issues</td>
<td>Amplitude 클라이언트 인터페이스 추상화(테스트 모킹 지원) 및 의존성·리소스 구성 정리</td>
</tr>
<tr>
<td>[**Oxygen.Nemonic.Pro**](http://Oxygen.Nemonic.Pro)**.SettingsApp**</td>
<td>2022.09 – 2023.08</td>
<td>4 Commits, 3 PRs, 3 Issues</td>
<td>nemonic Pro 전용 장치 설정 및 진단 데스크톱 앱 개발 (Nemonic Connect Desktop 전신)</td>
</tr>
<tr>
<td>**Mangoslab.Nemonic**</td>
<td>2022.06 – 2025.06</td>
<td>77 Commits, 41 PRs, 22 Issues</td>
<td>네모닉 프린터 제어 핵심 도메인 로직 및 패킷 인코딩 라이브러리 (사내 공용 Mango.Nemonic SDK로 흡수)</td>
</tr>
<tr>
<td>**Mangoslab.Drawing**</td>
<td>2021.12 – 2025.06</td>
<td>71 Commits, 26 PRs, 29 Issues</td>
<td>SkiaSharp 기반 캔버스 그리기 및 레이어 편집기 코어 라이브러리 (Mango.Drawing으로 흡수)</td>
</tr>
<tr>
<td>**Mangoslab.Usb**</td>
<td>2022.06 – 2022.06</td>
<td>4 Commits</td>
<td>디바이스 USB 통신 공통 라이브러리 초기 저장소 구성 (이후 Monolith Mango.Usb로 통합)</td>
</tr>
<tr>
<td>**Mangoslab.Bluetooth**</td>
<td>2022.06 – 2023.07</td>
<td>47 Commits, 25 PRs, 10 Issues</td>
<td>크로스 플랫폼 BLE 디바이스 검색, 연결 수명주기 및 예외 재연결 표준화 모듈 개발</td>
</tr>
<tr>
<td>**Radium**</td>
<td>2026.03 – 2026.03</td>
<td>52 Commits</td>
<td>현대화된 .NET 9 아키텍처 및 Vertical Slice Architecture 기반 차세대 서비스 프로토타입 구현</td>
</tr>
<tr>
<td>**Nemonic.Sdk.Image.Flutter**</td>
<td>2026.07 – 2026.07</td>
<td>1 Commit</td>
<td>Flutter용 네모닉 이미지 전처리 SDK 저장소 초기 설정 지원</td>
</tr>
</table>
### 기술 이력서 반영 핵심 포인트
- **\[모노레포 아키텍처 통합\]** 개별 분산 저장소로 파편화되어 있던 서비스들(Hub, Teams, Slack, Zapier, Web, Mango SDK)을 단일 Monolith 모노레포로 통합하여 공유 계약(Contract) 및 빌드·배포 체계 일원화
- **\[로컬 개발 생산성 혁신\]** .NET Aspire AppHost를 구축하여 PostgreSQL, Redis, RabbitMQ, Keycloak, Seq, OTel Collector 등 전사 인프라 및 서비스를 원클릭 기동하는 환경 수립
- **\[AI 코딩 에이전트 하네스 정착\]** Claude Code, Codex, Gemini CLI가 공유하는 코딩 규약, 계획서(docs/planning) 승인 루프 및 정적 가드 자동화를 전사 표준으로 정착
### ➕ 추가 연동 및 데스크톱 유틸리티 저장소
<table header-row="true">
<tr>
<td>저장소</td>
<td>활동 기간</td>
<td>기여량</td>
<td>핵심 역할 및 기술적 성과</td>
</tr>
<tr>
<td>[**Oxygen.Nemonic.Pro**](http://Oxygen.Nemonic.Pro)**.SettingsApp**</td>
<td>2022.09 – 2023.08</td>
<td>4 Commits, 3 PRs, 3 Issues</td>
<td>nemonic Pro 전용 장치 설정 및 진단 데스크톱 애플리케이션 개발 (Nemonic Connect Desktop 전신)</td>
</tr>
<tr>
<td>**Oxygen.Jira**</td>
<td>2022.09 – 2022.09</td>
<td>1 Issue</td>
<td>Atlassian Jira 연동 인쇄 앱 공증 배포 요건 검토 이슈 등록</td>
</tr>
</table>
- `Oxygen.Nemonic.Pro.SettingsApp` (nemonic Pro 전용 장치 설정 및 진단 앱)
### 🏛️ 기술 거버넌스 및 백엔드 아키텍처 분리 (조은 / 김석현 벤치마킹)
- **조직적 엔지니어링 리드**: 단순 구현을 넘어 Claude Code, Codex, Gemini CLI를 위한 공통 에이전트 하네스(`Garden.Harness`) 및 Roslyn 정적 애널라이저를 구축하여 전사 코드 컨벤션과 계획서(`docs/planning`) 승인 루프를 단일 표준으로 정착시킴.
- **마이크로서비스 분리 구조 (문제 - 해결 - 구조적 효과)**:
	- *문제 정의*: 인쇄 요청 접수, 템플릿 렌더링, 외부 알림 처리가 단일 경로에 결합되어 외부 웹훅 지연이 인쇄 요청 처리에 전파됨.
	- *해결책*: YARP ApiGW 리버스 프록시 도입, Notifier 서비스를 RabbitMQ 컨슈머 전용 호스트로 분리, Redis HybridCache 및 Keycloak OIDC 통합.
	- *구조적 효과*: 인쇄 접수 경로와 외부 채널(Slack/Teams) 알림 발송을 비동기 큐로 격리하여 서비스 간 장애 전파 차단.

