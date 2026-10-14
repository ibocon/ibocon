# 🌸 개인 프로젝트 — 가계부 모바일 서비스

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🌸 개인 프로젝트 — 가계부 모바일 서비스](https://app.notion.com/p/3dd475218675812db4c9cdc9aa23003f)  
> **최종 동기화 일시**: 2026-10-13

---

<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2021.06 – 현재</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>개인 · 기획부터 앱·백엔드·인프라·개발 도구까지 단독 개발·운영</td>
</tr>
<tr>
<td>기여</td>
<td>100% (단독)</td>
</tr>
<tr>
<td>상태</td>
<td>운영 중 · Google Play 내부 테스트 배포</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`.NET MAUI` `.NET Aspire` `PostgreSQL` `RabbitMQ` `Kubernetes` `Flux` `OpenBao` `OpenTelemetry` `Roslyn 애널라이저`</td>
</tr>
</table>
## 개요
가계부 모바일 서비스를 기획부터 앱, 백엔드, 인프라, 개발 도구까지 혼자 설계·구현·운영하는 프로젝트입니다. 서비스 본체(Peony)와 그 아래 세 개의 서브모듈 저장소(Garden, Garden.Cluster, Garden.Harness)로 나뉘며, 공용 라이브러리와 에이전트 하네스는 회사 프로젝트(Monolith)에도 도입해 사용합니다.
<table fit-page-width="true" header-row="true">
<tr>
<td>저장소</td>
<td>기간</td>
<td>역할</td>
</tr>
<tr>
<td>Peony</td>
<td>2021.06 – 현재</td>
<td>가계부 서비스 본체 — 모바일 앱·모바일 웹, 마이크로서비스 10종, BFF 게이트웨이, 운영 콘솔</td>
</tr>
<tr>
<td>Garden</td>
<td>2021.11 – 현재</td>
<td>서비스·앱 공통 기반 NuGet 라이브러리 9종과 Roslyn 애널라이저·코드픽스</td>
</tr>
<tr>
<td>Garden.Cluster</td>
<td>2025.04 – 현재</td>
<td>On-Premise Kubernetes + Azure AKS를 Flux GitOps로 운영하는 클러스터 정의·운영 도구</td>
</tr>
<tr>
<td>Garden.Harness</td>
<td>2026.05 – 현재</td>
<td>Claude Code·Codex·Gemini·OpenCode가 공유하는 AI 코딩 에이전트 하네스</td>
</tr>
</table>
## Peony — 가계부 서비스 본체
<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2021.06 – 현재</td>
</tr>
<tr>
<td>스택</td>
<td>`.NET MAUI Blazor Hybrid` `.NET Aspire` `EF Core` `PostgreSQL` `RabbitMQ` `Redis` `SignalR` `Keycloak OIDC` `Elasticsearch` `Firebase Cloud Messaging` `Amplitude` `Sentry` `GitHub Actions`</td>
</tr>
<tr>
<td>구성</td>
<td>모바일 앱(Android)·모바일 웹 / 마이크로서비스 Ledger, User, Billing, Autofill, Counterparty, Importer, Product, Provisioning, Notifier + ApiGateway(BFF) / Frontdoor 랜딩 / Management 운영 콘솔 / Bootstrap 초기화 잡 / 아키텍처 테스트</td>
</tr>
</table>
- .NET MAUI Blazor Hybrid로 Android 앱을 만들고, 같은 Razor 코드를 모바일 웹으로도 제공해 앱·웹 UI를 단일 코드베이스로 유지
- 도메인별 마이크로서비스 9종과 BFF 게이트웨이를 .NET Aspire로 오케스트레이션하고 Keycloak OIDC·SignalR·RabbitMQ로 연결
- Garden.Share의 CQRS·Mediator·도메인 이벤트 디스패처 위에 Rich Domain Model과 Result 패턴으로 서비스 계층 구성, 아키텍처 테스트로 계층 의존 규칙 고정
- 알림 인식 규칙·자동 입력(Autofill)·거래처(Counterparty)·가져오기(Importer)·구독 결제(Billing) 등 가계부 도메인 기능 설계·구현
- Firebase Cloud Messaging 푸시, Amplitude 이벤트 트래킹, Sentry 크래시 리포팅을 앱·서비스에 연동
- GitHub Actions 19개 워크플로 — 서비스별 컨테이너 이미지 퍼블리시, Google Play 내부 테스트·내부 앱 공유 업로드, 모바일 브라우저 테스트
## Garden — 공통 기반 라이브러리·애널라이저
<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2021.11 – 현재</td>
</tr>
<tr>
<td>스택</td>
<td>`.NET` `Blazor` `Material 3` `SCSS` `Roslyn` `NuGet (SemVer 2.0.0)` `BaGetter`</td>
</tr>
<tr>
<td>구성</td>
<td>NuGet 패키지 9종 — 각 패키지에 단위 테스트 프로젝트 동반, 상세는 아래 하위 페이지</td>
</tr>
</table>
<table fit-page-width="true" header-row="true">
<tr>
<td>패키지</td>
<td>역할</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd4752186758188aa8bd9022c7b1828">Garden.Share — 서비스·앱 공통 기반 계층</mention-page></td>
<td>CQRS·자체 Mediator·도메인 이벤트, Result 패턴, EF Core 리포지터리, MVVM·Navigation 등 서비스와 앱 공통 기반</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd475218675818dbc2ecf10106cf2fe">Garden.Razor — Material 3 Blazor 컴포넌트 라이브러리</mention-page></td>
<td>Material 3 디자인 시스템 기반 자체 Blazor 컴포넌트 44종과 SCSS 디자인 토큰</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd47521867581418667e68931599072">Garden.Razor.Gallery — 컴포넌트 갤러리</mention-page></td>
<td>전 컴포넌트를 둘러보는 Blazor WebAssembly 갤러리, 컨테이너로 배포</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd475218675814aa780daf1b2ac7074">Garden.Aspire — Aspire 호스트 리소스·ServiceDefaults</mention-page></td>
<td>Aspire 커스텀 호스팅 리소스(PostgreSQL·RabbitMQ·Keycloak·PostHog·Tunnel 등)와 ServiceDefaults</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd47521867581d8a8fcd90583147bef">Garden.AspNetCore — 웹 호스트 공통 미들웨어</mention-page></td>
<td>ETag 조건부 GET, ProblemDetails, 일회성 Bootstrap 호스트 등 `ASP.NET Core` 공통 미들웨어</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd475218675818d8ea8d1638af0b561">Garden.Maui — MAUI 플랫폼 서비스 추상화</mention-page></td>
<td>Identity·Navigation·StatusBar·WindowInsets·SecureStorage 등 MAUI 플랫폼 서비스 구현</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd47521867581999c6cc23c2973cb2b">Garden.Bluetooth — BLE 추상화 라이브러리</mention-page></td>
<td>GAP·GATT·SMP·L2CAP 계층을 분리한 5개 플랫폼 BLE 추상화</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd475218675810db019cbce2658c31f">Garden.Usb — 크로스플랫폼 USB 라이브러리</mention-page></td>
<td>WinUSB·IOKit/libusb·WebUSB를 단일 인터페이스로 묶은 USB 라이브러리</td>
</tr>
<tr>
<td><mention-page url="https://app.notion.com/p/3dd475218675819688c5e9a90d41afbe">Garden.Analyzers — Roslyn 규약 애널라이저·코드픽스</mention-page></td>
<td>네임스페이스·DI 명명·ConfigureAwait·메서드 체인 래핑 등 7종 애널라이저와 코드픽스</td>
</tr>
</table>
- SemVer 2.0.0·.NET Library Guidance 기반 버전 정책과 GitHub Actions NuGet 퍼블리시, On-Premise BaGetter 내부 피드로 배포
- 각 패키지는 플랫폼별 부분 클래스 파일 규약(`*.Android.cs`·`*.iOS.cs` 등)과 Marker 인터페이스 스캔 DI 등록 규약을 공유
## Garden.Cluster — GitOps 클러스터 정의·운영
<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2025.04 – 현재</td>
</tr>
<tr>
<td>스택</td>
<td>`Kubernetes` `Flux` `Kustomize` `Proxmox` `Azure AKS` `OpenTofu` `Rook-Ceph` `CloudNativePG` `Harbor` `OpenBao` `External Secrets` `cert-manager` `MetalLB` `ingress-nginx` `Tailscale` `Cloudflare` `Prometheus` `Loki` `Tempo` `OpenTelemetry Collector` `Seq` `Alertmanager` `PowerShell` `Python`</td>
</tr>
<tr>
<td>구성</td>
<td>clusters/hanul(On-Premise) · clusters/eastus2(AKS) / secrets → foundation → infra → operands → apps(staging·production overlay) 계층 / 운영 스크립트 PowerShell 147개·Python 52개 / 런북 10편</td>
</tr>
</table>
- Proxmox 위 On-Premise Kubernetes 클러스터(Hanul)를 구축하고 Azure AKS(East US 2)를 OpenTofu로 프로비저닝해 Flux가 각 클러스터 경로를 독립 reconcile하는 다중 클러스터 GitOps 구성
- Flux Kustomization을 secrets·foundation·infra·operands(platform/application)·apps 순서로 계층화하고 staging/production overlay로 환경 승격 흐름 분리
- Rook-Ceph 스토리지, CloudNativePG PostgreSQL, RabbitMQ·Keycloak·Redis 오퍼레이터, Harbor 레지스트리·BaGetter 피드, MetalLB·ingress-nginx·Tailscale 네트워크, OLM v1 오퍼레이터 관리 구성
- OpenBao + External Secrets로 시크릿 관리, Kubernetes auth 전환, 격리 복원 훈련(drill)과 부트스트랩 스크립트 작성
- Prometheus·Loki·Tempo·OTel Collector·Seq·Sentry 관측 스택과 Alertmanager 알림 라우팅 구성, Cloudflare DNS를 OpenTofu + external-dns로 선언
- Flux 롤아웃·승격·이미지 태그 고정(pin)·반영 완료(reconcile) 증거 수집 스크립트와 노드 유지보수·etcd·Ceph·RabbitMQ 장애 대응 런북 작성
## Garden.Harness — AI 에이전트 하네스
<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2026.05 – 현재 (Garden에서 분리)</td>
</tr>
<tr>
<td>스택</td>
<td>`Claude Code` `Codex` `Gemini CLI` `OpenCode` `MCP` `PowerShell` `Pester` `.NET` `Figma API` `Penpot Plugin API`</td>
</tr>
<tr>
<td>구성</td>
<td>스킬 42종 / PowerShell 스크립트 671개 / Pester 테스트 255개 / 컨벤션·가이드·독서 노트 문서 / MCP 서버 정의 / 호스트 프로파일(peony·monolith) / FigmaSync·PenpotSync .NET 도구</td>
</tr>
</table>
- 네 가지 코딩 에이전트가 같은 원칙(PRINCIPLES)·컨벤션·스킬·MCP 정의를 공유하도록 단일 하네스로 설계, git submodule로 소비 저장소에 심볼릭 링크 진입점만 노출
- 계획서(docs/planning) 워크플로 — AS-IS/TO-BE 기반 계획 작성·리뷰·검증·완료 아카이브를 스킬과 정적 가드로 강제
- pre-commit·HarnessAll 가드 — 트렁크 브랜치, 하네스 경계·독립성, 공유 상태, 프레임워크 경계, 워크플로 라우팅 등 PowerShell 정적 검사와 Pester 회귀 테스트
- 배포·운영 스킬 — staging 서비스 배포, 모바일 앱 스토어 배포, 환경 승격, Kubernetes 건강 진단, Sentry 트리아지, OpenBao 시크릿 추가, 저장소 동기화
- Figma·Penpot 디자인 동기화 .NET 도구와 검증 스킬로 디자인과 Razor 컴포넌트 일치 유지
- harness-manifest 프로파일로 호스트별(peony·monolith·hanul) 가드 세트를 선언해 회사 프로젝트(Monolith)에 도입
## 링크
- 저장소: 비공개
- 도입 대상: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>
<page url="https://app.notion.com/p/3dd4752186758188aa8bd9022c7b1828">Garden.Share — 서비스·앱 공통 기반 계층</page>
<page url="https://app.notion.com/p/3dd475218675818dbc2ecf10106cf2fe">Garden.Razor — Material 3 Blazor 컴포넌트 라이브러리</page>
<page url="https://app.notion.com/p/3dd47521867581418667e68931599072">`Garden.Razor.Gallery` — 컴포넌트 갤러리</page>
<page url="https://app.notion.com/p/3dd475218675814aa780daf1b2ac7074">Garden.Aspire — Aspire 호스트 리소스·ServiceDefaults</page>
<page url="https://app.notion.com/p/3dd47521867581d8a8fcd90583147bef">Garden.AspNetCore — 웹 호스트 공통 미들웨어</page>
<page url="https://app.notion.com/p/3dd475218675818d8ea8d1638af0b561">Garden.Maui — MAUI 플랫폼 서비스 추상화</page>
<page url="https://app.notion.com/p/3dd47521867581999c6cc23c2973cb2b">Garden.Bluetooth — BLE 추상화 라이브러리</page>
<page url="https://app.notion.com/p/3dd475218675810db019cbce2658c31f">Garden.Usb — 크로스플랫폼 USB 라이브러리</page>
<page url="https://app.notion.com/p/3dd475218675819688c5e9a90d41afbe">Garden.Analyzers — Roslyn 규약 애널라이저·코드픽스</page>
---
## 📂 사내 플랫폼 기술 전파 및 연계 저장소
<table header-row="true">
<tr>
<td>저장소</td>
<td>활동 기간</td>
<td>기여량</td>
<td>핵심 역할 및 기술적 성과</td>
</tr>
<tr>
<td>**History**</td>
<td>2023.06 – 2023.12</td>
<td>5 Commits, 22 PRs, 1 Issue</td>
<td>전사 계획서(Planning) 및 아키텍처 결정(ADR) 아카이브 거버넌스 체계 구축</td>
</tr>
<tr>
<td>**Mangoslab.Infrastructure**</td>
<td>2022.06 – 2026.05</td>
<td>129+ Commits, 23 PRs, 85 Issues</td>
<td>사내 공통 백엔드 인프라 프레임워크 구축 (자체 Mediator, 도메인 이벤트 디스패처, Scrutor DI 스캔)</td>
</tr>
<tr>
<td>**Peony / Garden**</td>
<td>2021.06 – 현재</td>
<td>1인 단독 풀스택</td>
<td>모바일 앱(MAUI)부터 마이크로서비스 백엔드까지 설계·운영하며 사내 Monolith에 도입된 공용 기반(Garden 라이브러리, AI 하네스)의 원류</td>
</tr>
<tr>
<td>**Garden.Cluster**</td>
<td>2021.06 – 현재</td>
<td>1인 단독 운영</td>
<td>On-Premise Kubernetes GitOps 클러스터 설계 원류 (Argon 이중 사이트 클러스터 설계로 기술 전파)</td>
</tr>
</table>
### 기술 이력서 반영 핵심 포인트
- **\\[사내 기술 이전(Technology Transfer)\\]** 개인 프로젝트에서 선제적으로 검증한 Clean Architecture, Mediator, Roslyn 애널라이저, AI 코딩 에이전트 하네스를 전사 통합 모노레포(Monolith)의 공식 표준으로 성공적으로 확산
- **\\[풀스택 & 플랫폼 엔지니어링\\]** 단독으로 모바일 클라이언트, 분산 마이크로서비스 백엔드, On-Premise GitOps 인프라 전 계층을 설계하고 운영하는 실증적 엔지니어링 역량 입증

