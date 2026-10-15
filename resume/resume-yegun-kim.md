# 📄 이력서 — 김예건

> **Single Source of Truth (SoT)**: Local Markdown Master  
> **동기화 Notion URL**: [📄 이력서 — 김예건](https://app.notion.com/p/3dd475218675811299b0e3d6b2baa43d)  
> **최종 동기화 일시**: 2026-10-14

---

> 💡 
> **.NET 풀스택 소프트웨어 엔지니어**
> 2017년부터 망고슬래브에서 Windows 데스크톱 앱, 모바일 앱, 웹 서비스, On-Premise Kubernetes 클러스터까지 제품에 필요한 영역을 개발·운영해 왔습니다. 개인 프로젝트에서는 .NET MAUI 모바일 앱과 마이크로서비스, GitOps 클러스터, Blazor 컴포넌트 라이브러리, AI 코딩 에이전트 하네스(작업 규약·검증 도구 모음)를 설계·운영하고 있습니다.

	
	
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
## 주요 기술 영역
담당해 온 업무와 개인 프로젝트를 Top-Down 아키텍처 위계 기준의 10개 단일 책임 영역으로 분류한 요약입니다.
<table fit-page-width="true" header-row="true">
<tr>
<td>직무 도메인 (Domain)</td>
<td>핵심 하위 항목</td>
<td>주요 작업 및 내용</td>
</tr>
<tr>
<td>**01. 소프트웨어 아키텍처**</td>
<td>• 01. [계층 분리 · 모듈화] Clean Architecture & VSA<br>• 02. [도메인 모델링] Rich Domain Model · Result 패턴<br>• 03. [비동기 분산 설계] CQRS · 자체 Mediator · Outbox<br>• 04. [테스트 설계] Four-Phase Test · NetArchTest · Testcontainers</td>
<td>비즈니스 불변식을 엔티티 내부에 캡슐화하고 명시적 Result 패턴·자체 Mediator·도메인 이벤트 디스패처·NetArchTest·Testcontainers로 프로젝트 전반의 설계 및 테스트 일관성 유지</td>
</tr>
<tr>
<td>**02. .NET 백엔드 엔지니어링**</td>
<td>• 01. [백엔드 · 모노레포] .NET 9 서비스 통합 & YARP API GW (Monolith)<br>• 02. [마이크로서비스 백엔드] .NET Aspire 기반 가계부 9개 서비스 (Peony)<br>• 03. [AI 파이프라인] 비동기 OCR/요약 (NemonicStudy)<br>• 04. [서비스 오케스트레이션] Aspire 호스팅 리소스 (Garden.Aspire)<br>• 05. [웹 호스트 미들웨어] ProblemDetails · ETag · Bootstrap (Garden.AspNetCore)</td>
<td>14개 분산 서비스 모노레포 통합(커밋 75% 기여), .NET Aspire 기반 마이크로서비스 오케스트레이션, YARP API GW 및 외부 채널 커넥터 구축</td>
</tr>
<tr>
<td>**03. 클라우드 및 온프레미스 인프라**</td>
<td>• 01. [클러스터 GitOps] 하이브리드 K8s(Proxmox·AKS) 구성 (Garden.Cluster)</td>
<td>Proxmox VE 베어메탈 및 Azure AKS 클러스터 프로비저닝, Rook-Ceph 스토리지·CloudNativePG·OpenBao 시크릿 제어면 운영</td>
</tr>
<tr>
<td>**04. DevOps 엔지니어링**</td>
<td>• 01. [K8s GitOps] 온프레미스 듀얼 사이트 DR (Argon)</td>
<td>Flux v2 멀티 클러스터 선언적 배포, Active/Fenced Standby 사이트 전환 계약 및 Pester 정적 가드 118개 운영</td>
</tr>
<tr>
<td>**05. 개발자 경험 (DevEx)**</td>
<td>• 01. [정적 분석기] Roslyn 커스텀 애널라이저 7종 & 코드픽스 (Garden.Analyzers)</td>
<td>네임스페이스·DI 명명·ConfigureAwait·메서드 체인 줄바꿈 규약을 컴파일 타임에 진단하는 Roslyn 애널라이저 7종 및 내부 NuGet 피드(BaGetter) 운영</td>
</tr>
<tr>
<td>**06. 하네스 엔지니어링**</td>
<td>• 01. [AI 에이전트 하네스] 4대 코딩 에이전트 공통 규약 & 정적 가드 (Garden.Harness)</td>
<td>Claude Code·Codex·OpenCode·Gemini CLI 4대 에이전트 단일 하네스(스킬 42종·스크립트 671개·Pester 255개), 계획서 워크플로 및 Fast Pre-Commit 가드 구축</td>
</tr>
<tr>
<td>**07. 웹 디자인 시스템**</td>
<td>• 01. [디자인 시스템] Penpot 토큰 동기화 & Blazor 컴포넌트 44종 (Garden.Razor)<br>• 02. [컴포넌트 갤러리] Blazor WASM 인터랙티브 갤러리 (Garden.Razor.Gallery)</td>
<td>Material 3 기반 자체 Blazor 컴포넌트 44종, 3계층 SCSS 디자인 토큰, Penpot 토큰 동기화 도구 및 Blazor WASM 갤러리 배포</td>
</tr>
<tr>
<td>**08. 모바일 애플리케이션**</td>
<td>• 01. [모바일 가계부 앱] .NET MAUI Blazor Hybrid 클라이언트 (Peony Mobile)<br>• 02. [모바일 라벨러 앱] FINECUBE Android · iOS 앱 (Lithium)<br>• 03. [모바일 플랫폼 추상화] .NET MAUI 인증 · 네비게이션 · 인셋 계층 (Garden.Maui)</td>
<td>.NET MAUI Blazor Hybrid 기반 앱·웹 단일 UI 코드베이스 구축, SkiaSharp 터치 캔버스 편집기 모듈화, Android targetSdk 34 상향</td>
</tr>
<tr>
<td>**09. Windows 데스크톱 애플리케이션**</td>
<td>• 01. [데스크톱 클라이언트] WYSIWYG 인쇄 엔진 & .NET 9 현대화 (nemonic)</td>
<td>8년 수명주기 레거시(.NET Framework 4.8)의 .NET 9 전환, WinForms/WPF MVVM 리팩토링 및 다국어 MSI/EXE 설치 패키지 배포</td>
</tr>
<tr>
<td>**10. 시스템 프로그래밍**</td>
<td>• 01. [USB · BLE 드라이버] WinUSB · WebUSB · 5계층 BLE 통합 SDK (Mango & Garden)<br>• 02. [BLE 프로토콜 추상화] GAP · GATT · L2CAP 5계층 라이브러리 (Garden.Bluetooth)<br>• 03. [USB 드라이버 추상화] WinUSB · libusb · WebUSB 단일 인터페이스 (Garden.Usb)</td>
<td>WinUSB/P-Invoke·IOKit/libusb·WebUSB 및 5계층 BLE 추상화 SDK 설계, BLE 상태 폴링 경합 해소, Win32 GDI 프린터 DC 핸들 누수 해결</td>
</tr>
</table>
---
## 📂 10대 직무 도메인별 상세 포트폴리오 (Domain Hub)
<span color="gray">각 도메인 폴더를 클릭하시면 해당 기술 영역의 상세 작업 내역을 확인하실 수 있습니다.</span>
<page url="https://app.notion.com/p/3fa475218675817b914ac9fa6ff9a9f4">01. 소프트웨어 아키텍처 (Clean Architecture, DDD, CQRS, TDD)</page>
<page url="https://app.notion.com/p/3f9475218675816e9d0bf75ee6a51ba6">02. .NET 백엔드 엔지니어링 (C#, YARP, PostgreSQL)</page>
<page url="https://app.notion.com/p/3fa475218675819995bfeab3391da08b">03. 클라우드 및 온프레미스 인프라 (Kubernetes, Proxmox, Rook-Ceph)</page>
<page url="https://app.notion.com/p/3f9475218675819baf65f8976281b85d">04. DevOps 엔지니어링 (Flux GitOps, CI/CD, Container)</page>
<page url="https://app.notion.com/p/3f947521867581e69559d6fbaa56760f">05. 개발자 경험 (DevEx, Roslyn Analyzer, NuGet)</page>
<page url="https://app.notion.com/p/3fa475218675818fbd9cea22db77bce4">06. 하네스 엔지니어링 (AI Agent Harness, MCP, Static Guards)</page>
<page url="https://app.notion.com/p/3fa47521867581be8577cd764904163d">07. 웹 디자인 시스템 (Penpot, Blazor, Material 3)</page>
<page url="https://app.notion.com/p/3f947521867581bbbc88ec8bf5a9dff9">08. 모바일 애플리케이션 (.NET MAUI, Xamarin.Forms, Android, iOS)</page>
<page url="https://app.notion.com/p/3f94752186758126a28cd2ecf057ead7">09. Windows 데스크톱 애플리케이션 (.NET 9, WinForms, WPF)</page>
<page url="https://app.notion.com/p/3fa47521867581968228f136738abaca">10. 시스템 프로그래밍 (Win32, GDI+, USB, BLE 디바이스 연동)</page>
	

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

