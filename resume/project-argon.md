# ☸️ 04.01. 듀얼 사이트 GitOps 배포 및 재해복구 자동화

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [☸️ 04.01. 듀얼 사이트 GitOps 배포 및 재해복구 자동화](https://app.notion.com/p/3dd4752186758104a1e1d8e1f9174433)  
> **최종 동기화 일시**: 2026-10-16

---

<table fit-page-width="true" header-column="true">
<colgroup>
<col width="140">
<col width="560">
</colgroup>
<tr>
<td>관련 프로젝트</td>
<td>`Argon` (`Monolith/src/Argon` 듀얼 사이트 GitOps · `pameus` 및 `kc5` 클러스터 · `Mangoslab.IaC`)</td>
</tr>
<tr>
<td>기간</td>
<td>2026.06 – 현재 (전신인 kc5 단일 클러스터 GitOps 저장소는 2025.05부터 운영)</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>Argon 설계·구축·운영 담당 (GitOps 구조, 이중 사이트 DR, 시크릿·인증 플랫폼)</td>
</tr>
<tr>
<td>기여</td>
<td>Argon 사람 커밋의 99% (950 / 954, Flux 이미지 자동 커밋 554건 제외) · 전신 kc5 저장소 커밋의 약 48% (127 / 262)</td>
</tr>
<tr>
<td>상태</td>
<td>운영 중 · pameus·kc5 두 클러스터가 Argon 한 트리를 Flux source로 사용, kc5 원본 저장소는 read-only archive</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`Kubernetes 1.34` `Flux 2.8` `Kustomize` `Rook-Ceph` `CloudNativePG` `Keycloak` `OpenBao` `External Secrets` `Harbor` `Proxmox VE` `Ansible` `OpenTofu` `Pester`</td>
</tr>
</table>
## 개요
Argon은 Monolith 모노레포의 `src/Argon`에 있는 GitOps 하위 시스템으로, 회사 서비스(Oxygen 12개 서비스, NemonicStudy, Zinc AI)를 운영하는 On-Premise Kubernetes 클러스터 두 곳(pameus, kc5)의 선언 상태를 한 트리에서 소유합니다. 각 클러스터의 Flux `GitRepository`가 Monolith를 source로 삼고, Monolith 루트 기준 `spec.path`로 자기 평면만 reconcile합니다.
두 클러스터는 서로 연동하지 않는 독립 클러스터이며, 환경별로 writer 사이트를 하나만 두는 **Active / Fenced Standby** 구조입니다. staging은 pameus가 primary이고 kc5가 replica 0 standby, production은 kc5가 primary이고 pameus가 standby입니다. 사이트 전환은 DNS 변경보다 쓰기 차단(fence)과 데이터 일치(parity) 검증을 먼저 완료하도록 계약 YAML과 정적 검사로 강제합니다.
전신은 kc5 단일 클러스터를 별도 저장소로 운영한 GitOps 구성이며, Argon이 이를 실패 시 차단(fail-closed) 전환 계약으로 이관해 `clusters/kc5/legacy` snapshot 경계로 보존합니다.
## 기술 스택
<table fit-page-width="true" header-row="true">
<colgroup>
<col width="140">
<col width="560">
</colgroup>
<tr>
<td>영역</td>
<td>구성</td>
</tr>
<tr>
<td>GitOps</td>
<td>Flux v2.8 (Kustomize·Helm·image-automation controller), Monolith 루트 기준 `spec.path`, `secrets → infra → operands / identity → apps` 의존 순서, Capacitor UI</td>
</tr>
<tr>
<td>클러스터 기반</td>
<td>Proxmox VE 9 노트북 기반 노드 5대(pameus) + 3대(kc5), Ansible로 노드 프로비저닝·Kubernetes 1.34 마이너 업그레이드, flannel, MetalLB, ingress-nginx, cert-manager, metrics-server, descheduler, node-tuner, Spegel 이미지 미러</td>
</tr>
<tr>
<td>스토리지 · 데이터</td>
<td>Rook-Ceph v1.19 (RBD·RGW 오브젝트 스토어·OBC), CloudNativePG + Barman Cloud 플러그인(Azure Blob WAL 아카이브), RabbitMQ Cluster Operator + Topology Operator, Redis, Elasticsearch·Kibana</td>
</tr>
<tr>
<td>시크릿 · 인증</td>
<td>OpenBao HA Raft(Kubernetes auth, KV v2 경로 규약) → External Secrets Operator, Keycloak Operator(realm 3종: oxygen-staging·oxygen-production·mangoslab 회사 realm, Slack·Google·Microsoft IdP 브로커), oauth2-proxy</td>
</tr>
<tr>
<td>아티팩트 · CI</td>
<td>Harbor(pameus Active, kc5 warm standby, OIDC 로그인), BaGetter NuGet, GitHub Actions Runner Controller(ARC) Linux·MAUI Android 러너, Flux ImageUpdateAutomation으로 staging 이미지 자동 커밋</td>
</tr>
<tr>
<td>관측</td>
<td>kube-prometheus-stack(Grafana OIDC), Loki, Tempo, OpenTelemetry Collector, Seq(Keycloak OIDC), Alertmanager 이중 사이트 복제·백업 경보</td>
</tr>
<tr>
<td>DNS · 외부</td>
<td>Azure DNS를 OpenTofu로 선언(레코드 56개), ExternalDNS upsert-only, 환경 CNAME(`stag`·`prod`)으로 사이트 전환, Azure Blob 백업을 Bicep으로 선언</td>
</tr>
<tr>
<td>검증</td>
<td>PowerShell·Pester 정적 가드 118개(overlay 규약, Flux path ownership, 이미지 태그 규약, DR 계약 drift, namespace 규약), `kubectl kustomize` 렌더 parity</td>
</tr>
</table>
## Argon 구조
Argon은 Garden.Cluster의 `apps`·`infra`·`clusters` 축을 따르며, 각 평면을 별도 Flux Kustomization이 reconcile합니다.
<table fit-page-width="true" header-row="true">
<colgroup>
<col width="160">
<col width="540">
</colgroup>
<tr>
<td>경로</td>
<td>역할</td>
</tr>
<tr>
<td>`clusters/pameus`</td>
<td>Flux bootstrap, infrastructure·apps child Kustomization, Ansible 인벤토리·플레이북, PVE 하드웨어·장애 도메인 문서, production standby Keycloak·DB recovery 정의</td>
</tr>
<tr>
<td>`clusters/kc5`</td>
<td>kc5 production bootstrap, cutover·stateful recovery·secret 계약 YAML, OpenBao·ESO 플랫폼, Harbor·Keycloak standby, 이관 전 원본을 보존한 `legacy` snapshot 경계</td>
</tr>
<tr>
<td>`secrets/`</td>
<td>External Secrets Operator 설치 평면 (가장 먼저 적용)</td>
</tr>
<tr>
<td>`infra/`</td>
<td>공통 Operator·controller 34개 컴포넌트 (네트워크·스토리지·보안·관측·아티팩트·CI·메일·노드 튜닝)</td>
</tr>
<tr>
<td>`operands/`</td>
<td>Operator가 조정하는 관리 대상 CR (Ceph 클러스터, MetalLB 풀, RabbitMQ 클러스터, Harbor, OpenBao, kc5-recovery 격리 복원 namespace)</td>
</tr>
<tr>
<td>`identity/keycloak`</td>
<td>Keycloak CR, CNPG 데이터베이스, realm import 3종, 테마, warm standby heartbeat</td>
</tr>
<tr>
<td>`apps/base` · `apps/overlays`</td>
<td>Oxygen 서비스 12개(apigw·mgmt·notifier·printer·printjob·slack·teams·zap·temp·user·web 등)와 환경 데이터 인프라 base, development·staging·production·각 standby overlay, Pester 테스트 24개</td>
</tr>
<tr>
<td>`scripts/` · `tools/`</td>
<td>PowerShell 운영 진입점 40여 개 (preflight, staging publish, Keycloak 승격·parity 동기화, DR 드릴, Kubernetes 업그레이드, 엔드포인트 전환)</td>
</tr>
<tr>
<td>`docs/`</td>
<td>아키텍처 설계서 3편, 런북 7편, 운영 SOP, 계획서 78편(진행) · 아카이브 201편</td>
</tr>
</table>
## 주요 작업
- **이중 사이트 Active / Fenced Standby 설계** — `EnvironmentAuthority`·`EnvironmentEndpointContract`·`DualClusterBaseline` 계약 YAML로 환경별 단일 writer, epoch 기반 fencing, standby replica 0·ingress·writer·scheduled job 비활성을 선언하고 Pester 가드로 정의 이탈(drift)을 차단. 환경 namespace를 사이트 역할과 분리(`oxygen-staging`·`oxygen-production` 이름 parity)
- **kc5 production 이관** — 전신 저장소의 316개 파일을 tree hash로 고정한 `legacy` snapshot 경계로 들여오고, 평문 Secret 16개를 동일 identity의 ExternalSecret으로 치환하는 것만 허용하는 실패 시 차단(fail-closed) 전환 계약(`cutover-contract.yaml`)과 rollback 태그를 두고 kc5 Flux GitRepository를 Argon으로 전환
- **Keycloak 환경 중립 failover** — `stag.mangoslab.org/auth`·`prod.mangoslab.org/auth`를 불변 public issuer로 고정하고, kc5 단일 writer → pameus warm standby를 Azure Blob 기반 CNPG 지속 복구로 유지. realm·client·redirect URI·IdP·credential fingerprint parity를 값을 노출하지 않는 검증 결과(receipt)로 검증한 뒤에만 CNAME 수동 전환을 허용하는 런북과 자동화 client bootstrap 구현
- **Harbor warm standby** — pameus Active 레지스트리의 artifact 복제와 PostgreSQL physical backup을 kc5로 복구하고, preflight·parity·fence receipt 3종이 모두 통과해야만 승격 컨트롤러를 재개하는 승격 절차 수립. publisher robot 자격 회전을 Harbor·OpenBao·GitHub secret·smoke·rollback 한 순서로 묶은 런북 작성
- **시크릿 플랫폼** — OpenBao HA Raft를 두 사이트에 구성하고 `app/{env}/{owner}/{component}`·`infra/{component}/{secret}` 경로 규약, KV v2 CAS 병합 저장, required surface 정적 검사로 Git에 평문 Secret이 남지 않도록 전환. Flux bootstrap과 ESO 인증을 Kubernetes auth로 통일
- **스토리지·노드 운영** — Rook-Ceph OSD 증설 게이트(host `local-lvm` 여유 용량 기준), PG 예산, scrub·slow-op 경합 진단, 노트북 PVE 노드 교체(pve1·pve5 → pve6·pve7)와 control plane 메모리 baseline 조정, kubelet image GC·이미지 pull 지연을 Spegel 미러로 완화
- **Kubernetes 마이너 업그레이드 자동화** — Ansible 플레이북이 한 단계 마이너 상승만 허용하도록 검증하고 Rook·Ceph 공식 지원 범위를 먼저 정렬한 뒤 1.34로 진행. etcd Azure Blob 백업 추가
- **Oxygen staging 배포 파이프라인** — 서비스 12개의 base·overlay를 정착하고 Harbor publish → Flux ImageUpdateAutomation 자동 커밋 → HPA·ResourceQuota·PDB 기반 리소스 적정화까지 한 흐름으로 연결. staging 이미지 태그 규약(재태깅 금지)과 production digest 기록 유지
- **관측·경보** — Prometheus·Loki·Tempo·OTel Collector·Seq를 Keycloak OIDC 뒤에 게시하고, `DualSiteReplicationLagExceeded`·`DualSiteBackupStale` 등 DR 경보와 월간·분기 점검 런북 운영. 에이전트용 read-only ServiceAccount와 service-proxy RBAC로 MCP 진단 경로 제공
- **운영 문서화** — 계획서(docs/planning) → 구현 → 검증 → 아카이브(docs/history) 흐름으로 2026.07 이후 운영 변경 279건을 기록. 접근 북마크, DNS 레코드 자동 생성 문서, 하드웨어 장애 도메인, 런북 7편 유지
## 구성 요소
Argon이 배포하는 워크로드입니다.
- **Oxygen** — API Gateway, User, Mgmt, Notifier, Printer, PrintJob, Temp, Web, Slack·Teams·Zapier 커넥터, WeatherForecast (staging은 pameus, production은 kc5)
- **NemonicStudy** — BFF API + hint/eraser 서비스 + Celery 워커 + Redis (kc5 legacy 경계, Firebase credential two-phase 회전)
- **Zinc nemonic AI** — GPU 의존 production 워크로드 (kc5 전용 예외, NVIDIA GPU Operator)
- **플랫폼 공용** — Keycloak, Harbor, OpenBao, BaGetter, pgAdmin, Redis Insight, Seq, Grafana, Capacitor, RabbitMQ 관리 UI
## 링크
- 저장소: [github.com/MANGOSLABCoLtd/Monolith](https://github.com/MANGOSLABCoLtd/Monolith) `src/Argon` (private)
- 전신: [github.com/MANGOSLABCoLtd/kc5](https://github.com/MANGOSLABCoLtd/kc5) (read-only archive)
- 상위 모노레포: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>
---
## 📂 세부 기여 저장소 및 기술 이력 상세 (10개 저장소 연계)
<table fit-page-width="true" header-row="true">
<colgroup>
<col width="150">
<col width="120">
<col width="130">
<col width="300">
</colgroup>
<tr>
<td>저장소</td>
<td>활동 기간</td>
<td>기여량</td>
<td>핵심 역할 및 기술적 성과</td>
</tr>
<tr>
<td>**argon**</td>
<td>2026.05 – 2026.07</td>
<td>107 Commits, 17 PRs</td>
<td>On-Premise K8s(pameus, kc5) 이중 사이트 Active/Fenced Standby GitOps 클러스터 설계·구축·운영 단독 담당 (사람 커밋 99%)</td>
</tr>
<tr>
<td>**kc5**</td>
<td>2025.05 – 2026.07</td>
<td>100+ Commits</td>
<td>Argon의 전신인 On-Premise Kubernetes 단일 클러스터 GitOps 환경 구축 및 fail-closed 이관 계약 수립</td>
</tr>
<tr>
<td>**kc6**</td>
<td>2025.06 – 2025.11</td>
<td>100+ Commits</td>
<td>온프레미스 클러스터 연동 특수 단말 클라이언트 개발 및 안정적 통신 연계</td>
</tr>
<tr>
<td>**Mangoslab.IaC**</td>
<td>2022.06 – 2025.01</td>
<td>870+ Commits, 66 PRs, 46 Issues</td>
<td>클라우드(Azure Bicep / Terraform) 리소스 코드화(IaC) 작업 및 클라우드-온프레미스 하이브리드 연계 기반 구축</td>
</tr>
<tr>
<td>**Mangoslab.Pipeline**</td>
<td>2023.05 – 2024.04</td>
<td>21 Commits, 18 PRs, 7 Issues</td>
<td>GitHub Actions CI/CD 파이프라인 템플릿, 패키지 배포 및 이미지 자동화 워크플로 구축</td>
</tr>
<tr>
<td>**Zinc.NemonicStudy**</td>
<td>2025.05 – 2026.07</td>
<td>106+ Commits, 4 PRs, 5 Issues</td>
<td>NemonicStudy AI 학습 모바일 앱 메인 개발 및 프로덕션 릴리스 주도</td>
</tr>
<tr>
<td>**Zinc.NemonicStudy.Bff.Api**</td>
<td>2026.06 – 2026.06</td>
<td>23 Commits, 4 PRs</td>
<td>NemonicStudy 앱 전용 BFF API 개발, 비동기 요약/OCR 큐 처리, K8s 배포 파이프라인 구축</td>
</tr>
<tr>
<td>**Zinc.NemonicStudy.Service.Summary**</td>
<td>2026.05 – 2026.06</td>
<td>31 Commits, 1 PR</td>
<td>Gemini 2.5 Flash 기반 AI 학습 내용 자동 요약 마이크로서비스 백엔드 개발 및 멀티 슬롯 API 키 회전 구현</td>
</tr>
<tr>
<td>**Zinc.NemonicStudy.Service.Ocr**</td>
<td>2026.06 – 2026.07</td>
<td>48 Commits</td>
<td>AI 문제 인식 및 수식 추출 OCR 파이프라인 마이크로서비스 구축 및 Argon 클러스터 Celery 워커 배포</td>
</tr>
<tr>
<td>**Zinc.NemonicAi**</td>
<td>2024.02 – 2024.05</td>
<td>7 Commits, 6 PRs</td>
<td>Nemonic AI 모바일 클라이언트 개발 및 Argon 클러스터 GPU(NVIDIA GPU Operator) 워크로드 배포</td>
</tr>
</table>
### 요약 포인트
- **\[온프레미스 K8s 이중 사이트 구성\]** pameus와 kc5 이중 사이트 간 Active / Fenced Standby 구조를 수립하여 단일 writer 보장, epoch 기반 fencing, Keycloak 사이트 전환(Failover) 절차 수립
- **\[시크릿 관리 체계 전환\]** OpenBao HA Raft + External Secrets Operator(ESO) 연동으로 Git 내 평문 Secret 16개를 ExternalSecret으로 전량 치환하고 Kubernetes Native 인증으로 통합
- **\[AI 마이크로서비스 배포 자동화\]** NemonicStudy 백엔드 군(BFF, Summary, OCR)을 컨테이너화하고 Harbor + Flux ImageUpdateAutomation 파이프라인으로 연결하여 자동 배포 파이프라인 구성
### On-Premise K8s 4대 플랫폼 평면 구성
<table fit-page-width="true" header-row="true">
<colgroup>
<col width="140">
<col width="220">
<col width="340">
</colgroup>
<tr>
<td>플랫폼 평면</td>
<td>구성 컴포넌트</td>
<td>핵심 역할 및 거버넌스 계약</td>
</tr>
<tr>
<td>**1. 시크릿 & 인증**</td>
<td>OpenBao HA Raft, External Secrets Operator, Keycloak Operator</td>
<td>Git 내 평문 Secret을 ExternalSecret으로 치환, K8s Native 서비스 계정 인증 일원화</td>
</tr>
<tr>
<td>**2. 공통 인프라**</td>
<td>MetalLB, ingress-nginx, cert-manager, Spegel 이미지 미러</td>
<td>L2/L3 네트워크 인그레스 라우팅, 노드 간 P2P 이미지 풀 가속화</td>
</tr>
<tr>
<td>**3. 스토리지 & 데이터**</td>
<td>Rook-Ceph v1.19, CloudNativePG, RabbitMQ Cluster Operator</td>
<td>Ceph 분산 블록/오브젝트 스토리지, Azure Blob WAL 아카이브 기반 DB 백업</td>
</tr>
<tr>
<td>**4. 워크로드**</td>
<td>Oxygen 12개 마이크로서비스, NemonicStudy AI, Zinc GPU 파이프라인</td>
<td>Flux ImageUpdateAutomation 기반 staging 이미지 자동 반영</td>
</tr>
</table>
- **Keycloak 사이트 전환(Failover) 설계 의도**: 두 독립 온프레미스 사이트 간 L2 연동 없이 Azure Blob 기반 CNPG WAL 복구를 유지하며, credential fingerprint parity가 검증된 상태에서만 환경 CNAME 전환을 허용하여 검증 전 전환으로 인한 데이터 불일치를 방지함.

