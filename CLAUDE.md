# 반가워(Bangawo) iOS Project

## Overview
DDD 13기 iOS 2조의 "반가워(Bangawo)" iOS 앱 프로젝트. Clean Architecture + TCA(The Composable Architecture) 기반.

## Tech Stack
- **Language:** Swift 6.0 / SwiftUI (iOS 17.0+, iPhone only)
- **Build System:** Tuist 4.174.0 (mise로 버전 관리)
- **State Management:** TCA 1.18.0 + TCACoordinators 0.11.1
- **Networking:** AsyncMoya 1.1.8 (Moya + Alamofire 5.11.1)
- **DI:** WeaveDI 3.4.0+
- **Team ID:** DH9CS7PA5D
- **Bundle ID:** com.ddd-ios2.Bangawo

## Project Structure (Clean Architecture)

```
Projects/
├── App/                    # 앱 타겟 (BangawoApp.swift, ContentView.swift)
├── Presentation/           # Feature UI 레이어 (TCA Reducer + SwiftUI View)
│   └── Presentation/
├── Domain/                 # 비즈니스 로직 레이어
│   ├── Entity/             # 도메인 모델 (의존성 없음)
│   ├── UseCase/            # 유스케이스 (TCA + WeaveDI)
│   ├── DataInterface/      # Repository 프로토콜 정의
│   └── DomainInterface/    # UseCase 인터페이스 정의
├── Data/                   # 데이터 레이어
│   ├── API/                # API 정의
│   ├── Model/              # 데이터 모델 (DTO)
│   ├── Repository/         # Repository 구현체
│   └── Service/            # 데이터 서비스
├── Network/                # 네트워크 레이어
│   ├── Foundations/         # 코어 네트워킹 유틸
│   ├── Networking/          # 네트워킹 구현
│   └── ThirdPartys/        # 서드파티 통합 (AsyncMoya, WeaveDI)
└── Shared/                 # 공유 리소스
    ├── DesignSystem/        # UI 컴포넌트, 폰트(Pretendard), 컬러, 이미지
    ├── Shared/              # 공통 유틸리티
    └── Utill/               # 유틸 함수
```

## Module Dependency Flow
```
App -> Presentation -> UseCase -> Repository -> Networking -> Foundations
                    -> Shared     -> DomainInterface -> Entity
                                  -> DataInterface -> Model
```

## Build Configurations
| Config | Bundle ID | Display Name | Flags |
|--------|-----------|-------------|-------|
| Dev | com.ddd-ios2.Bangawo.dev | Bangawo(Dev) | DEV, DEBUG |
| Stage | com.ddd-ios2.Bangawo.stage | Bangawo-Stage | STAGE |
| Prod | com.ddd-ios2.Bangawo | Bangawo | PROD |

xcconfig 파일: `Config/Dev.xcconfig`, `Config/Stage.xcconfig`, `Config/Prod.xcconfig`, `Config/Shared.xcconfig`

## Tuist Plugins (Plugins/)
- **ProjectTemplatePlugin**: `makeAppModule()`, `makeModule()` 등 프로젝트/타겟 생성 헬퍼
- **DependencyPlugin**: 모듈 간 의존성 DSL (`Modules.swift`, `TargetDependency+Modules.swift`)
- **DependencyPackagePlugin**: SPM 패키지 의존성 숏컷 (`.composableArchitecture`, `.weaveDI` 등)

## Key Commands
```bash
# Tuist 프로젝트 생성/갱신
mise exec -- tuist generate

# 의존성 설치
mise exec -- tuist install

# 프로젝트 클린
mise exec -- tuist clean
```

## Code Conventions

### File Header
```swift
//
//  FileName.swift
//  ModuleName
//
//  Created by DDD-iOS2 on 날짜.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
```

### Naming
- **모듈/타입:** PascalCase (e.g., `Presentation`, `ContentView`)
- **프로퍼티/메서드:** camelCase
- **환경변수:** UPPERCASE (DEV, STAGE, PROD)
- **Bundle ID:** lowercase dot notation

### Architecture Rules
- SwiftUI + TCA 패턴 사용 (Combine 대신 async/await 선호)
- 모듈 간 의존성은 Interface 모듈을 통해 추상화 (DataInterface, DomainInterface)
- Export 패턴: 각 모듈의 public API는 `*Exported.swift` 파일로 관리
- 각 모듈의 `Sources/` 하위에 코드 작성, `Tests/Sources/` 하위에 테스트 작성

### Module Creation
새 모듈 추가 시 해당 모듈 디렉토리에 `Project.swift`를 생성하고 `makeModule()` 헬퍼 사용:
```swift
let project = Project.makeModule(
    name: "ModuleName",
    product: .staticFramework,
    dependencies: [.Domain.entity],
    hasTests: true
)
```

## Design System
- **Font:** Pretendard Variable (PretendardVariable.ttf)
- **Colors:** `ShapeStyle+.swift`에서 정의
- **Images:** `DesignSystem/Resources/ImageAssets.xcassets`
- Tuist 코드 생성: `TuistAssets+`, `TuistFonts+`, `TuistBundle+` 파일 자동 생성

## Testing
각 모듈별 `Tests/` 디렉토리에 유닛 테스트 위치. `hasTests: true` 설정된 모듈에서 자동 생성.
