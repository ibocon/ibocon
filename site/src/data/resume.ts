import navigation from '../../../resume/resume-navigation.json';

export const resumeNavigation = navigation;

export const resumeProfile = {
  title: '김예건 이력서',
  summary: '하드웨어와 연결되는 .NET MAUI Blazor Hybrid 클라이언트부터 .NET 서비스 API, Kubernetes 배포 자동화까지 직접 개발합니다. 하나의 코드베이스로 여러 운영체제를 지원하고, 제품별 요구를 공통 서비스와 운영 구조로 정리합니다.',
  tags: ['.NET', 'C#', 'MAUI', 'ASP.NET Core', 'Kubernetes', 'GitOps'],
};

export const resumeCompetencies = [
  ['데스크톱 · Windows · macOS', '.NET Framework 4.8 앱을 .NET 9으로 현대화하고, 네모닉 커넥트를 한 코드베이스(MAUI Blazor Hybrid)로 Windows와 Mac App Store에 함께 배포합니다.'],
  ['모바일 · Android · iOS', '.NET MAUI Blazor Hybrid 앱과 SkiaSharp 렌더링, Android SDK 대응과 스토어 릴리스를 맡습니다.'],
  ['USB · BLE 하드웨어', 'WinUSB, libusb, WebUSB, BLE를 하나의 프로토콜 계층으로 추상화하고, Mac 샌드박스의 USB·Bluetooth 권한까지 다룹니다.'],
  ['.NET 서비스 · Kubernetes', 'ASP.NET Core API Gateway부터 On-Premise Kubernetes와 Flux GitOps 배포까지 이어갑니다.'],
  ['디자인 시스템 · 라이브러리', 'Penpot 디자인 토큰을 코드로 동기화하고, Material 3 기반 Blazor 컴포넌트(Garden.Razor)와 내부 NuGet 피드로 공통 라이브러리를 만들어 팀 제품에 적용합니다.'],
  ['AI 활용 개발', 'Claude, Codex, OpenCode, Gemini CLI가 공통 하네스와 정적 가드 아래에서 일하게 만들어, AI가 쓴 코드도 팀 표준을 지키게 합니다.'],
] as const;

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

export const resumeCareer = {
  employer: '망고슬래브 주식회사',
  team: 'SW개발팀',
  role: '소프트웨어 엔지니어',
  period: '2017.07 – 현재',
  tenure: '9년 차',
  items: [
    ['네모닉', 'Windows 클라이언트의 WYSIWYG 편집·인쇄와 USB 프린터 연동, 레거시 .NET 현대화 및 배포 유지보수'],
    ['파인큐브', 'iOS·Android 라벨 편집기와 프린터 연동 기능 유지보수, Android SDK 대응과 스토어 릴리스 관리'],
    ['네모닉 커넥트', '.NET 모노레포 기반 프린팅·연동 서비스, 공통 SDK·API Gateway·빌드·배포 구조 정비'],
    ['On-Prem 서버 구축', 'Kubernetes 클러스터 운영과 Flux GitOps 기반 서비스 배포 자동화 설계·관리'],
  ],
} as const;

export const resumeEducation = [
  ['2020.02', '국가평생교육진흥원 독학학위제 · 컴퓨터과학 · 공학사'],
  ['2014.01 – 2016.05', "University of Wisconsin–Milwaukee · Computer Science, GPA 3.95 / 4.0, Dean's Honor List 3학기"],
  ['2013.02', '불곡고등학교 · 졸업'],
] as const;

export const splitSkillValues = (values: string): string[] => values.split(',').map((value) => value.trim()).filter((value) => value.length > 0);

export const splitDomainName = (name: string): { number: string; title: string } => {
  const match = /^(\d{2})\.\s*(.+)$/.exec(name);
  if (match === null) {
    return { number: '', title: name };
  }

  return { number: match[1], title: match[2] };
};
