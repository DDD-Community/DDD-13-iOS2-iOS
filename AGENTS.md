# Bangawo

- **스택**: Swift 6, SwiftUI, TCA 1.25, Tuist 4
- **아키텍처**: TCA + Clean Architecture 멀티모듈
- **배포 타겟**: iOS 26.0, iPhone 전용

## Commands

| 명령어 | 설명 |
| --- | --- |
| `./tuisttool generate` | Xcode 프로젝트 생성 |
| `./tuisttool build` | clean → install → generate 순차 실행 |
| `./tuisttool install` | 의존성 설치 |
| `./tuisttool clean` | 프로젝트 정리 |
| `xcodebuild -workspace Bangawo.xcworkspace -scheme Bangawo build` | 빌드 |
| `xcodebuild -workspace Bangawo.xcworkspace -scheme Bangawo test` | 테스트 |

> 파일 생성/삭제, `Project.swift` 수정, 의존성 추가/제거 시 반드시 `./tuisttool generate` 실행.
> Tuist는 glob으로 소스를 수집하므로, generate 없이는 Xcode에 반영되지 않는다.

## Project Structure

```
Projects/
├── App/                  # 앱 타겟 (진입점, DI 조립)
├── Presentation/         # 화면 + ViewModel (TCA Feature)
├── Domain/
│   ├── Entity/           # 도메인 엔티티 + Protocol
│   ├── UseCase/          # 비즈니스 로직 구현
│   ├── DomainInterface/  # Domain 계층 인터페이스
│   └── DataInterface/    # Data 계층 인터페이스
├── Data/
│   ├── Model/            # DTO, API Response → Entity 변환
│   ├── Repository/       # Repository 구현체
│   ├── API/              # REST API Endpoint
│   └── Service/          # 데이터 처리 서비스
├── Network/
│   ├── Networking/       # HTTP 클라이언트 설정
│   ├── Foundations/      # 네트워크 기반 유틸리티
│   └── ThirdPartys/     # AsyncMoya, WeaveDI 등
└── Shared/
    ├── DesignSystem/     # 공통 UI 컴포넌트, 폰트, 색상
    ├── Shared/           # 공통 공유 모듈
    └── Utill/            # 날짜, 문자열, 로깅 유틸리티
```

의존성 방향: `Presentation → Domain ← Data`, `Network`는 `Data`에서만 참조.

## Code Style

### Common
- Swift API Design Guidelines 준수
- 들여쓰기 4 spaces, 줄 제한 120자
- guard early return 사용
- final class 기본, private 우선
- Never force unwrap

### SwiftUI
- SubView는 struct로 분리 (@ViewBuilder 함수 대신 Binding 사용)
- View 네이밍에 View suffix 안 붙임
- Spacer 대신 `.frame(maxWidth/maxHeight: .infinity)` 사용
- 필수 속성은 init, 선택적 속성은 modifier 함수로 관리

### TCA
- `@Reducer` 매크로 + `@ObservableState` 사용
- Action은 이벤트 기반 네이밍 (`incrementButtonTapped`, `numberFactResponse`)
- Effect: 부작용 없으면 `.none`, 비동기 작업은 `.run`
- Store: `StoreOf<Feature>`로 선언
- 액션 간 로직 공유 지양 (헬퍼 메서드 사용)
- CPU 작업은 Effect 내에서 처리
- 테스트: TestStore 패턴 사용

## Git Rules

### Branch
- `main`: 배포 / `develop`: 통합 / `feature/#{issue-number}`: 작업
- PR → develop 머지

### Commit
- 형식: `[{Header}]: {Message}`
- Header: FEAT / REFACTOR / ADD / FIX / HOTFIX / DOCS / TEST / CHORE
- Message: 한국어, 한 줄, 최대 50자, 마침표 및 특수기호 미사용
- Body: 필요시 작성, 무엇을 왜 변경했는지 기술
- 예시: `[FEAT]: 로그인 화면 UI 구현`
