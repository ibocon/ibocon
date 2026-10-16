# 🌸 02.02. 가계부 마이크로서비스 백엔드 및 BFF

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [🌸 02.02. 가계부 마이크로서비스 백엔드 및 BFF](https://app.notion.com/p/3dd475218675812db4c9cdc9aa23003f)  
> **최종 동기화 일시**: 2026-10-16

---

<callout icon="🌸" color="gray_bg">
	**핵심 요약**: 가계부 도메인을 구성하는 **9개 마이크로서비스(`Ledger`, `User`, `Billing`, `Autofill`, `Counterparty`, `Importer`, `Product`, `Provisioning`, `Notifier`)**와 **YARP 기반 `ApiGateway(BFF)`**, 운영 콘솔(`Management`), 초기화 잡(`Bootstrap`)을 `.NET Aspire`로 오케스트레이션하고 `Keycloak OIDC` · `RabbitMQ` · `SignalR`로 연결한 분산 백엔드 시스템입니다.
</callout>
<table fit-page-width="true" header-column="true">
<colgroup>
<col width="140">
<col width="560">
</colgroup>
<tr>
<td>관련 프로젝트</td>
<td>`Peony` (가계부 9개 마이크로서비스 · `Peony.ApiGateway` BFF · `Garden.Share` · `Garden.Aspire` · `Garden.AspNetCore`)</td>
</tr>
<tr>
<td>기간</td>
<td>2021.06 – 현재</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>개인 · 가계부 마이크로서비스 9종, BFF 게이트웨이, 운영 콘솔 설계·구현·운영 (100% 단독)</td>
</tr>
<tr>
<td>상태</td>
<td>운영 중 (`Garden.Cluster` 배포 및 Google Play 내부 테스트 연동)</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`.NET 9` `.NET Aspire` `ASP.NET Core` `YARP` `EF Core` `PostgreSQL` `RabbitMQ` `Redis` `SignalR` `Keycloak OIDC` `Elasticsearch` `OpenTelemetry`</td>
</tr>
</table>
---
## 1. `Peony` 9개 마이크로서비스 및 BFF 아키텍처 다이어그램
- **1. 클라이언트 & Edge BFF (`YARP`)**: `Peony Web` (Blazor) · `Peony Mobile` (MAUI Blazor Hybrid) · `Peony.ApiGateway` (OIDC · SignalR Hub) · `Management` 운영 콘솔 · `Frontdoor` 랜딩
- **2. 코어 가계부 마이크로서비스 (9종)**: `Ledger` (원장/거래/예산) · `Autofill` (알림 자동분류) · `Counterparty` (거래처) · `Importer` (명세서 반입) · `User` · `Billing` · `Product` · `Provisioning` · `Notifier`
- **3. 데이터 · 메시징 & GitOps 인프라**: `PostgreSQL` (서비스별 DB 격리) · `Redis` · `RabbitMQ` 비동기 이벤트 버스 · `Elasticsearch` · `.NET Aspire` & `Garden.Cluster` GitOps 운영
---
## 2. 9개 도메인 마이크로서비스 및 호스트 책임 매트릭스
<table fit-page-width="true" header-row="true">
<tr>
<td>서비스 / 호스트</td>
<td>도메인 경계 (Bounded Context)</td>
<td>핵심 기능 및 이벤트 연동</td>
<td>데이터 스토어 / 프로토콜</td>
</tr>
<tr>
<td>**`Ledger` (원장 코어)**</td>
<td>가계부 장부 · 계정과목 · 거래 · 예산</td>
<td>거래 생성/수정/삭제 불변식 검증, 잔액 집계, 거래 확정 도메인 이벤트 발행</td>
<td>`PostgreSQL` · `RabbitMQ` · `Redis`</td>
</tr>
<tr>
<td>**`Autofill` & `Counterparty`**</td>
<td>금융 알림 파싱 · 거래처 학습/정규화</td>
<td>모바일 푸시/SMS 결제 문구에서 금액·가맹점 추출 후 정규화된 거래처 및 카테고리로 자동 매핑</td>
<td>`PostgreSQL` · `Elasticsearch`</td>
</tr>
<tr>
<td>**`Importer`**</td>
<td>외부 금융 데이터 반입 파이프라인</td>
<td>은행/카드사 엑셀·CSV 명세서 파싱, 중복 거래 검출 및 `Ledger` 일괄 반영 요청</td>
<td>비동기 배치 · `RabbitMQ`</td>
</tr>
<tr>
<td>**`User` · `Billing` · `Product` · `Provisioning`**</td>
<td>회원 · 플랜 상품 · 구독 결제 · 테넌트 초기화</td>
<td>Keycloak 사용자 동기화, 구독 상태 전이, 신규 가입 시 기본 가계부/카테고리 자동 프로비저닝</td>
<td>`PostgreSQL` · `Keycloak`</td>
</tr>
<tr>
<td>**`Notifier` & `ApiGateway(BFF)`**</td>
<td>실시간 알림 및 클라이언트 단일 진입점</td>
<td>`Firebase Cloud Messaging(FCM)` 모바일 푸시 발송, `SignalR` 멀티 디바이스 실시간 동기화, YARP 라우팅</td>
<td>`SignalR` · `FCM` · `YARP`</td>
</tr>
</table>
---
## 3. 대표 백엔드 엔지니어링 문제 해결 사례 (Problem · Action · Result)
- **[사례 1] 신규 가입 및 거래 입력 시 다중 마이크로서비스 간 동기 결합 제거 (이벤트 기반 사가/프로비저닝)**
	- **문제(Problem)**: 사용자 가입 직후 기본 장부·카테고리 생성(`Provisioning`, `Ledger`)이나 거래 입력 후 거래처 학습(`Counterparty`)·자동분류(`Autofill`) 갱신을 동기 HTTP 체인으로 묶으면 지연 시간 증가 및 부분 실패 복구 복잡도가 발생함.
	- **해결(Action)**: 각 마이크로서비스가 자신의 DB 트랜잭션을 커밋한 뒤 `RabbitMQ` 통합 이벤트를 발행하고, 후속 서비스들이 이를 비동기 소비하여 독립적으로 프로젝션과 알림(`Notifier`)을 처리하도록 설계함.
	- **결과(Result)**: 코어 원장(`Ledger`) API의 빠른 응답 속도를 유지하면서 9개 서비스의 도메인 경계를 명확히 분리.
- **[사례 2] 사내 엔터프라이즈 모노레포(`Monolith`) 아키텍처의 선행 레퍼런스 베드 구축**
	- **문제(Problem)**: 사내 시스템(`Monolith`)에 `.NET Aspire`, `Garden.Share`(Rich Domain + Result), `Garden.Razor`, `NetArchTest`를 도입하기 전에 실제 멀티 서비스 환경에서의 검증이 필요했음.
	- **해결(Action)**: `Peony`의 9개 마이크로서비스와 19개 GitHub Actions 워크플로에서 먼저 아키텍처 테스트(`NetArchTest`)와 컨테이너 배포 파이프라인을 실전 운영하며 검증함.
	- **결과(Result)**: 검증된 패턴과 `Garden.*` 패키지 생태계를 사내 `Monolith` 통합 작업에 그대로 이식하여 아키텍처 전환 리스크를 최소화.
---
## 4. 연계 아키텍처 및 플랫폼 페이지
- 아키텍처 및 공통 기반: <mention-page url="https://app.notion.com/p/3fa47521867581858317c5bba15dc785"/> · <mention-page url="https://app.notion.com/p/3dd4752186758188aa8bd9022c7b1828"/> · <mention-page url="https://app.notion.com/p/3fa475218675819f8f31ed43ded0baac"/>
- 오케스트레이션 및 웹 미들웨어: <mention-page url="https://app.notion.com/p/3dd475218675814aa780daf1b2ac7074"/> · <mention-page url="https://app.notion.com/p/3dd47521867581d8a8fcd90583147bef"/>
- 디자인 시스템 및 모바일 클라이언트: <mention-page url="https://app.notion.com/p/3dd475218675818dbc2ecf10106cf2fe"/> · <mention-page url="https://app.notion.com/p/3f9475218675816481e0e0938b9380f1"/> · <mention-page url="https://app.notion.com/p/3dd475218675818d8ea8d1638af0b561"/>
- 클러스터 인프라 및 개발 도구: <mention-page url="https://app.notion.com/p/3f947521867581d88fbff700c1586f6f"/> · <mention-page url="https://app.notion.com/p/3f947521867581fbaa5def020f156512"/> · <mention-page url="https://app.notion.com/p/3dd475218675819688c5e9a90d41afbe"/>
- 사내 모노레포 도입 대상: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>

