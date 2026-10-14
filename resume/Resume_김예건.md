# 📄 이력서 — 김예건

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [📄 이력서 — 김예건](https://app.notion.com/p/3dd475218675811299b0e3d6b2baa43d)  
> **최종 동기화 일시**: 2026-10-13

---

> ⚡ **엔지니어링 가치 제안 (Value Proposition)**
> **"디바이스·데스크톱·모바일·웹 클라이언트부터 마이크로서비스 백엔드와 온프레미스 GitOps 인프라까지 전 계층을 코드로 선언하고 자동화하는 .NET 풀스택 엔지니어"**
> 9년간 망고슬래브에서 네모닉 1세대 하드웨어 연동 제품부터 분산 클라우드/마이크로서비스 백엔드, On-Premise K8s 이중화 클러스터, 전사 모노레포 통합 및 AI 코딩 에이전트 하네스까지 제품 전 생애주기를 직접 설계하고 운영했습니다. 연간 10,000+ Contributions을 유지하며 변경에 유연하고 테스트 가능한 시스템을 구축합니다.

	
		
> 💡 
> **.NET 풀스택 소프트웨어 엔지니어**
> 2017년부터 망고슬래브에서 Windows 데스크톱 앱, 모바일 앱, 웹 서비스, On-Premise Kubernetes 인프라까지 제품 전 계층을 다뤄 왔습니다. 개인 프로젝트에서는 .NET MAUI 모바일 앱과 마이크로서비스, GitOps 클러스터, AI 코딩 에이전트 하네스(작업 규약·검증 도구 모음)를 단독으로 설계·운영하고 있습니다.

	
	
		📞 010-7503-5266
		✉️ [wlfka102@gmail.com](mailto:wlfka102@gmail.com)
		🐙 [github.com/ibocon](https://github.com/ibocon)
		✍️ [ibocon.tistory.com](https://ibocon.tistory.com/)
	

---
## 경력

	
		**2017.07 – 현재**
		<span color="gray">9년 차</span>
	
	
		### 망고슬래브 주식회사
		<span color="gray">SW개발팀 · 소프트웨어 엔지니어</span>
		스마트 메모 프린터 **nemonic**의 Windows 클라이언트에서 출발해, FINECUBE 라벨 프린터 모바일 앱, 회사 서비스 전반을 담는 .NET 모노레포(Monolith), On-Premise Kubernetes 클러스터(Argon) 구축·운영까지 담당 범위를 넓혀 왔습니다.
	

---
## 🏛️ 엔지니어링 3대 핵심 축 (Core Engineering Pillars)
도메인 사전 지식 없이도 전체 시스템 구조를 한눈에 파악할 수 있도록, 9년간 설계·구축한 41개 저장소와 시스템을 3대 비즈니스 기둥(Pillar)으로 집약하여 소개합니다.
<table header-row="true">
<tr>
<td>기둥 (Pillar)</td>
<td>포괄 프로젝트</td>
<td>해결 과제 및 비즈니스·기술 임팩트</td>
</tr>
<tr>
<td>**Pillar 1. 스마트 프린터 디바이스 & 하드웨어 연동 플랫폼**</td>
<td>Monolith · nemonic Desktop · Lithium</td>
<td>3대 OS(Windows/iOS/Android) 통합 BLE/USB 프린팅 파이프라인 구축 및 레거시 400개 테이블 모노레포 통합</td>
</tr>
<tr>
<td>**Pillar 2. 모듈러 아키텍처 & 공용 생태계**</td>
<td>Peony (가계부 서비스) · Garden.\\* 10개 라이브러리</td>
<td>Vertical Slice Architecture(VSA) 적용 및 전사 재사용 컴포넌트 생태계 구축 (도메인 결합도 60% 감소)</td>
</tr>
<tr>
<td>**Pillar 3. 온프레미스 인프라 & GitOps**</td>
<td>Argon K8s (pameus · kc5) · Garden.Cluster</td>
<td>MetalLB, Ceph, Flux GitOps 기반 온프레미스 이중화 클러스터 및 암호화 시크릿/관측성 제어면 무중단 운영</td>
</tr>
</table>
---
## 프로젝트 (3대 기둥별 핵심 프로덕트)
<span color="gray">각 프로젝트의 상세 내용은 하위 페이지 및 세부 기술서에서 확인하실 수 있습니다.</span>

	
		**2025.08 – 현재**
		<span color="gray">망고슬래브</span>
		<span color="gray">커밋 비중 약 75%</span>
	
	
		### \\[Pillar 1\\] Monolith
		<span color="gray">회사 통합 .NET 모노레포 (스마트 프린터 서비스 플랫폼)</span>
		nemonic 서비스·앱·펌웨어·클러스터 정의를 한 저장소로 통합한 모노레포입니다.
		- 하위 시스템 5개를 하나의 빌드·코딩 규약·계획 문서 체계로 통합
		- AI 코딩 에이전트 하네스를 도입해 AI 보조 개발을 팀 표준으로 정착
		`.NET Aspire` `RabbitMQ` `YARP` `EF Core` `Keycloak` `MAUI` `Blazor`
		<page url="https://app.notion.com/p/3dd4752186758105801dea0310df86f5">Monolith — 회사 통합 .NET 모노레포</page>
	

	
		**2025.05 – 현재**
		<span color="gray">망고슬래브</span>
		<span color="gray">kc5 커밋 비중 약 48%</span>
	
	
		### \\[Pillar 3\\] Argon
		<span color="gray">On-Premise Kubernetes 이중 사이트 GitOps (클라우드 인프라)</span>
		회사 서비스를 운영하는 On-Premise Kubernetes 클러스터 두 곳(pameus·kc5)을 Flux GitOps로 구성·운영합니다. kc5 단일 클러스터 저장소로 시작해 Monolith의 Argon 하위 시스템으로 이관했습니다.
		- 네트워크·인증·데이터·GPU 인프라 계층 구성, NemonicStudy·Braillience·Oxygen 워크로드 배포
		- 이미지 digest 기반 릴리스 기록, 헬스체크와 Google Chat 장애·복구 알림 체계 구축
		`Flux` `Keycloak` `CloudNativePG` `Rook-Ceph` `Harbor` `NVIDIA GPU Operator`
		<page url="https://app.notion.com/p/3dd4752186758104a1e1d8e1f9174433">Argon — On-Premise Kubernetes 이중 사이트 GitOps</page>
	

	
		**2017.07 – 현재**
		<span color="gray">망고슬래브</span>
	
	
		### \\[Pillar 1\\] nemonic Desktop
		<span color="gray">Windows 애플리케이션 (디바이스 인쇄 플랫폼)</span>
		스마트 메모 프린터 nemonic의 Windows 클라이언트와 메모 동기화 서버를 개발·유지보수합니다.
		- USB 통신 DLL 연동, 프린터 모델 지원 확장
		- MSI/EXE 배포와 코드 서명, 장기 운영을 위한 절차·아키텍처 문서화
		`.NET Framework 4.8` `WPF` `MVVM` `Visual Studio Installer Projects` `Jenkins`
		<page url="https://app.notion.com/p/3dd4752186758193b90bc453e00b9b25">nemonic Desktop — Windows 애플리케이션</page>
	

	
		**2022.01 – 2025.07**
		<span color="gray">망고슬래브</span>
	
	
		### \\[Pillar 1\\] Lithium
		<span color="gray">FINECUBE 모바일 앱 (하드웨어 연동 앱)</span>
		라벨 프린터 FINECUBE의 Android·iOS 앱을 유지보수하고 릴리스했습니다.
		- 프린터 연결 예외 처리
		- Android targetSdk 33→34 상향과 Google Play 배포
		`Xamarin.Forms` `MvvmCross` `SkiaSharp` `EF Core` `SQLite`
		<page url="https://app.notion.com/p/3dd475218675813aa4cdfa7fca9e534a">Lithium — FINECUBE 모바일 앱</page>
	

	
		**2021.06 – 현재**
		<span color="gray">개인 프로젝트 · 1인 개발</span>
	
	
		### \\[Pillar 2\\] Peony & Garden 생태계
		<span color="gray">가계부 모바일 서비스 및 전사 10개 공용 도메인 패키지군</span>
		가계부 서비스 본체(Peony)와 전사 재사용 컴포넌트 생태계(Garden.\\* 10개 패키지 및 AI 에이전트 하네스)를 단독으로 설계·구현·운영합니다.
		- Vertical Slice Architecture 및 Result 패턴 기반의 모듈러 백엔드와 Blazor MAUI 앱
		- 10개 독립 도메인 패키지(Usb, Bluetooth, Maui, Aspire, Razor, Analyzers 등)로 분리해 전사 재사용
		`.NET MAUI` `.NET Aspire` `PostgreSQL` `RabbitMQ` `Kubernetes` `Flux` `OpenBao` `OpenTelemetry`
		<page url="https://app.notion.com/p/3dd475218675812db4c9cdc9aa23003f">개인 프로젝트 — 가계부 모바일 서비스</page>
	

---
## 기술 스택

	
		**언어**
		`C#`
		**백엔드**
		`ASP.NET Core` `.NET Aspire` `EF Core` `YARP` `SignalR`
		**데이터 · 메시징**
		`PostgreSQL` `Redis` `RabbitMQ`
		**클라이언트**
		`.NET MAUI` `Blazor` `WPF` `Xamarin.Forms`
		**테스트**
		`xUnit` `NSubstitute` `bunit` `Testcontainers` `Playwright`
	
	
		**인프라**
		`Kubernetes` `Flux` `Kustomize` `Docker` `Proxmox` `Azure AKS` `OpenTofu`
		**클러스터 플랫폼**
		`Keycloak` `cert-manager` `ingress-nginx` `MetalLB` `CloudNativePG` `Rook-Ceph` `Harbor` `OpenBao`
		**관측**
		`OpenTelemetry` `Prometheus` `Loki` `Tempo` `Seq` `Sentry` `Serilog`
		**개발 도구**
		`Roslyn 애널라이저` `GitHub Actions` `Jenkins`
	

---
## 학력

	
		**2020.02**
	
	
		**국가평생교육진흥원 독학학위제** · 컴퓨터과학 · 공학사
	

	
		**2014.01 – 2016.05**
	
	
		**University of Wisconsin–Milwaukee** · Computer Science
		<span color="gray">2016년 1학기까지 재학 후 귀국 · GPA 3.95 / 4.0 · Dean's Honor List 3학기</span>
	

	
		**2013.02**
	
	
		**불곡고등학교** · 졸업
	

---
## 🐙 GitHub 기여 저장소 총괄 대시보드 (41개 저장소)
망고슬래브(MANGOSLABCoLtd) 9년간의 제품 수명주기 전반에 걸쳐 직접 기여한 **41개 Git 저장소**의 도메인별 연계 현황입니다. 각 저장소별 세부 기여 내역은 위 5대 상세 프로젝트 페이지에 반영되어 있습니다.
<table header-row="true">
<tr>
<td>도메인 / 분류</td>
<td>포괄 저장소 (총 41개)</td>
<td>매칭 Notion 상세 페이지</td>
</tr>
<tr>
<td>**통합 모노레포 & 백엔드**</td>
<td>Monolith, Oxygen.Hub, Teams, Slack, Zapier, Web, Amplitude, SettingsApp, Mango SDK (Nemonic, Drawing, Usb, Bluetooth), Radium, Nemonic.Sdk.Image.Flutter (14개)</td>
<td>[🧱 Monolith](https://app.notion.com/p/3dd4752186758105801dea0310df86f5)</td>
</tr>
<tr>
<td>**K8s 클러스터 & GitOps**</td>
<td>argon, kc5, kc6, Mangoslab.IaC, Pipeline, NemonicStudy (App, BFF, Summary, OCR), NemonicAi (10개)</td>
<td>[☸️ Argon](https://app.notion.com/p/3dd4752186758104a1e1d8e1f9174433)</td>
</tr>
<tr>
<td>**데스크톱 & 디바이스**</td>
<td>NemonicBasicWindows, Label, AMPV, 1세대 모바일(Android/iOS/Plugin), MemoView, Firmware, TestUtility, Centerm FW Test (11개)</td>
<td>[🖨️ nemonic Desktop](https://app.notion.com/p/3dd4752186758193b90bc453e00b9b25)</td>
</tr>
<tr>
<td>**라벨 & 하드웨어 앱**</td>
<td>Lithium (FINECUBE), Sulfur (Aesty), Mangoslab.Drawing (3개)</td>
<td>[🏷️ Lithium](https://app.notion.com/p/3dd475218675813aa4cdfa7fca9e534a)</td>
</tr>
<tr>
<td>**공용 기반 & 거버넌스**</td>
<td>History (문서 거버넌스), Mangoslab.Infrastructure (프레임워크 원류), Peony, Garden.Cluster (4개)</td>
<td>[🌸 개인 프로젝트](https://app.notion.com/p/3dd475218675812db4c9cdc9aa23003f)</td>
</tr>
</table>

