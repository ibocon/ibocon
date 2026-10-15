# 🌸 02. [마이크로서비스 백엔드] .NET Aspire 기반 가계부 9개 서비스 & BFF (Peony)

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🌸 02. [마이크로서비스 백엔드] .NET Aspire 기반 가계부 9개 서비스 & BFF (Peony)](https://app.notion.com/p/3dd475218675812db4c9cdc9aa23003f)  
> **최종 동기화 일시**: 2026-10-15

---

<table fit-page-width="true" header-column="true">
<tr>
<td>기간</td>
<td>2021.06 – 현재</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>개인 · 가계부 마이크로서비스 9종, BFF 게이트웨이, 운영 콘솔 설계·구현·운영</td>
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
<td>`.NET Aspire` `ASP.NET Core` `EF Core` `PostgreSQL` `RabbitMQ` `Redis` `SignalR` `Keycloak OIDC` `Elasticsearch` `OpenTelemetry`</td>
</tr>
</table>
## 개요
가계부 서비스를 구성하는 도메인별 마이크로서비스 9종과 BFF 게이트웨이, 운영 콘솔(`Management`), 초기화 잡(`Bootstrap`)을 `.NET Aspire`로 오케스트레이션하고 `Keycloak OIDC`·`SignalR`·`RabbitMQ`로 연결한 백엔드 시스템입니다.
## 마이크로서비스 구성
<table fit-page-width="true" header-column="true">
<tr>
<td>스택</td>
<td>`.NET Aspire` `ASP.NET Core` `EF Core` `PostgreSQL` `RabbitMQ` `Redis` `SignalR` `Keycloak OIDC` `Elasticsearch` `Firebase Cloud Messaging` `Amplitude` `Sentry` `GitHub Actions`</td>
</tr>
<tr>
<td>서비스 목록</td>
<td>마이크로서비스 9종(`Ledger`, `User`, `Billing`, `Autofill`, `Counterparty`, `Importer`, `Product`, `Provisioning`, `Notifier`) + `ApiGateway(BFF)` / `Frontdoor` 랜딩 / `Management` 운영 콘솔 / `Bootstrap` 초기화 잡 / 아키텍처 테스트</td>
</tr>
</table>
- 도메인별 마이크로서비스 9종과 BFF 게이트웨이를 `.NET Aspire`로 오케스트레이션하고 `Keycloak OIDC`·`SignalR`·`RabbitMQ`로 연결
- CQRS·자체 Mediator·도메인 이벤트 디스패처 위에 Rich Domain Model과 Result 패턴으로 서비스 계층 구성, 아키텍처 테스트(`NetArchTest`)로 계층 의존 규칙 고정
- 알림 인식 규칙·자동 입력(`Autofill`)·거래처(`Counterparty`)·가져오기(`Importer`)·구독 결제(`Billing`) 등 가계부 도메인 기능 설계·구현
- `Firebase Cloud Messaging` 푸시, `Amplitude` 이벤트 트래킹, `Sentry` 크래시 리포팅 연동
- GitHub Actions 19개 워크플로 — 서비스별 컨테이너 이미지 퍼블리시, Google Play 내부 테스트 업로드, 모바일 브라우저 테스트
## 연계 아키텍처 및 플랫폼 페이지
- 아키텍처 및 공통 기반: <mention-page url="https://app.notion.com/p/3fa47521867581858317c5bba15dc785"/> · <mention-page url="https://app.notion.com/p/3dd4752186758188aa8bd9022c7b1828"/> · <mention-page url="https://app.notion.com/p/3fa475218675819f8f31ed43ded0baac"/>
- 오케스트레이션 및 웹 미들웨어: <mention-page url="https://app.notion.com/p/3dd475218675814aa780daf1b2ac7074"/> · <mention-page url="https://app.notion.com/p/3dd47521867581d8a8fcd90583147bef"/>
- 디자인 시스템 및 모바일 클라이언트: <mention-page url="https://app.notion.com/p/3dd475218675818dbc2ecf10106cf2fe"/> · <mention-page url="https://app.notion.com/p/3f9475218675816481e0e0938b9380f1"/> · <mention-page url="https://app.notion.com/p/3dd475218675818d8ea8d1638af0b561"/>
- 클러스터 인프라 및 개발 도구: <mention-page url="https://app.notion.com/p/3f947521867581d88fbff700c1586f6f"/> · <mention-page url="https://app.notion.com/p/3f947521867581fbaa5def020f156512"/> · <mention-page url="https://app.notion.com/p/3dd475218675819688c5e9a90d41afbe"/>
- 사내 모노레포 도입 대상: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>

