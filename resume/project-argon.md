# ☸️ 04.01. On-Premise Kubernetes 클러스터 구축 및 GitOps 운영

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [☸️ 04.01. On-Premise Kubernetes 클러스터 구축 및 GitOps 운영](https://app.notion.com/p/3dd4752186758104a1e1d8e1f9174433)

---

<table fit-page-width="true" header-column="true">
<colgroup>
<col width="140">
<col width="560">
</colgroup>
<tr>
<td>관련 프로젝트</td>
<td>`Argon` (`Monolith/src/Argon` · On-Premise Kubernetes · GitOps)</td>
</tr>
<tr>
<td>기간</td>
<td>2026.06 – 현재</td>
</tr>
<tr>
<td>소속 · 역할</td>
<td>On-Premise Kubernetes 플랫폼 설계·구축·운영 및 GitOps 배포 체계 담당</td>
</tr>
<tr>
<td>핵심 키워드</td>
<td>`Kubernetes` `Flux` `Kustomize` `Proxmox VE` `Ansible` `Rook-Ceph` `CloudNativePG` `OpenBao` `External Secrets` `Harbor` `Pester`</td>
</tr>
</table>

## 개요

Argon은 Monolith 모노레포의 `src/Argon`에 있는 GitOps 하위 시스템입니다. On-Premise Kubernetes 환경에서 서비스와 플랫폼 구성 요소를 선언적으로 관리하고, Flux가 저장소의 정의된 경로를 reconcile하도록 구성했습니다.

## 플랫폼 구성

<table fit-page-width="true" header-row="true">
<colgroup>
<col width="160">
<col width="540">
</colgroup>
<tr>
<td>영역</td>
<td>구성 및 책임</td>
</tr>
<tr>
<td>노드 · 네트워크</td>
<td>Proxmox VE 기반 노드 프로비저닝, Kubernetes 업그레이드, MetalLB, ingress-nginx, cert-manager, metrics-server 및 이미지 미러 운영</td>
</tr>
<tr>
<td>스토리지 · 데이터</td>
<td>Rook-Ceph 블록·오브젝트 스토리지, CloudNativePG, RabbitMQ, Redis 및 Elasticsearch 운영</td>
</tr>
<tr>
<td>시크릿 · 인증</td>
<td>OpenBao와 External Secrets Operator를 연동하고 Kubernetes ServiceAccount 인증과 시크릿 경로 규약을 표준화</td>
</tr>
<tr>
<td>배포 · 관측</td>
<td>Flux와 Kustomize 기반 선언적 배포, Harbor 이미지 관리, Prometheus·Loki·Tempo·OpenTelemetry·Seq 관측성 구성</td>
</tr>
</table>

## 주요 작업

- **On-Premise Kubernetes 구축·운영** — Proxmox VE 기반 노드 구성, Ansible 프로비저닝, Kubernetes 마이너 업그레이드 절차와 운영 기준을 정립했습니다.
- **스토리지·데이터 플랫폼 운영** — Rook-Ceph 용량·상태 점검과 CloudNativePG 기반 데이터 서비스 운영을 구성했습니다.
- **시크릿 관리 표준화** — OpenBao와 External Secrets Operator를 연결하고 Kubernetes 인증 기반 시크릿 주입 방식을 표준화했습니다.
- **GitOps 배포 체계** — Flux와 Kustomize로 플랫폼·애플리케이션 구성을 관리하고 이미지 변경의 선언적 반영 흐름을 구성했습니다.
- **관측성 기반 운영** — Prometheus, Loki, Tempo, OpenTelemetry, Seq를 통해 메트릭·로그·트레이스를 수집하고 운영 진단 기반을 마련했습니다.

## 구성 요소

- **플랫폼 공용** — Keycloak, Harbor, OpenBao, BaGetter, RabbitMQ, Grafana, Seq
- **서비스 워크로드** — API와 백엔드 서비스, 데이터 서비스, CI/CD 실행 환경

## 링크

- 저장소: [github.com/MANGOSLABCoLtd/Monolith](https://github.com/MANGOSLABCoLtd/Monolith) `src/Argon` (private)
- 상위 모노레포: <mention-page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5"/>
