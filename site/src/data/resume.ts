import navigation from '../../../resume/resume-navigation.json';

export const resumeNavigation = navigation;

export const resumeProfile = {
  title: '김예건 이력서',
  summary: '하드웨어와 연결되는 .NET MAUI Blazor Hybrid 클라이언트부터 .NET 서비스 API, Kubernetes 배포 자동화까지 직접 개발합니다. 하나의 코드베이스로 여러 운영체제를 지원하고, 제품별 요구를 공통 서비스와 운영 구조로 정리합니다.',
  tags: ['.NET', 'C#', 'MAUI', 'ASP.NET Core', 'Kubernetes', 'GitOps'],
};

export const resumeCompetencies = [
  '제품 엔지니어링 — Windows·모바일·웹 서비스를 제품 단위로 설계·개발·운영합니다.',
  '플랫폼·인프라 — On-Premise Kubernetes와 GitOps 기반의 배포·운영 체계를 구축합니다.',
  '개발 생산성 — 디자인 시스템과 AI 코딩 에이전트 하네스로 팀의 개발 흐름을 개선합니다.',
];

export const resumeDomains = [
  ['소프트웨어 아키텍처', '계층 분리, 도메인 모델, 이벤트 기반 분산 설계와 다층 테스트 아키텍처'],
  ['.NET 백엔드 엔지니어링', '.NET 9, Aspire, YARP, PostgreSQL, RabbitMQ 기반 서비스와 API Gateway'],
  ['클라우드 및 온프레미스 인프라', 'Proxmox VE, Azure AKS, Rook-Ceph, CloudNativePG, OpenBao 운영'],
  ['DevOps 엔지니어링', 'Flux v2 멀티 클러스터 GitOps와 재해복구 자동화'],
  ['개발자 경험', 'Roslyn 애널라이저와 내부 NuGet 피드 운영'],
  ['하네스 엔지니어링', 'Claude, Codex, OpenCode, Gemini CLI 공통 하네스와 정적 가드'],
  ['웹 디자인 시스템', 'Penpot 토큰 동기화와 Material 3 기반 Blazor 컴포넌트'],
  ['모바일 애플리케이션', '.NET MAUI Blazor Hybrid, SkiaSharp, Android SDK 대응'],
  ['Windows 데스크톱 애플리케이션', '.NET Framework 4.8에서 .NET 9으로의 현대화와 WPF·WinForms 유지보수'],
  ['시스템 프로그래밍', 'WinUSB, libusb, WebUSB와 BLE 프로토콜 계층 추상화'],
] as const;

export const resumeSkillGroups = [
  ['언어', 'C#, Python, PowerShell'],
  ['백엔드', 'ASP.NET Core, .NET 9, .NET Aspire, EF Core, YARP, SignalR'],
  ['데이터 · 메시징', 'PostgreSQL, Redis, RabbitMQ, Elasticsearch'],
  ['클라이언트 · 디자인 시스템', '.NET MAUI Blazor Hybrid, Blazor, Garden.Razor, Penpot, WPF, WinForms, Xamarin.Forms'],
  ['테스트', 'xUnit, NSubstitute, bUnit, Testcontainers, Pester, Playwright'],
  ['인프라 · GitOps', 'Kubernetes, Flux, Kustomize, Docker, Proxmox VE, Azure AKS, OpenTofu, Ansible'],
  ['클러스터 플랫폼', 'Rook-Ceph, CloudNativePG, Keycloak, OpenBao, External Secrets, Harbor, MetalLB, ingress-nginx'],
  ['관측성', 'OpenTelemetry, Prometheus, Loki, Tempo, Seq, Sentry, Serilog'],
  ['DevEx · 하네스 엔지니어링', 'Garden.Harness, Roslyn 애널라이저, GitHub Actions'],
] as const;
