# Project Rules

## Code Convention

### Common
- Swift API Design Guidelines 준수
- 들여쓰기: 4 spaces
- 줄 제한: 120자
- guard early return 사용
- final class 기본
- private 우선, force unwrap 금지

### SwiftUI
- SubView는 struct로 분리 (@ViewBuilder 함수 대신 Binding 사용)
- View 네이밍에 View suffix 안 붙임
- Spacer 대신 .frame(maxWidth/maxHeight: .infinity) 사용
- 필수 속성은 init, 선택적 속성은 modifier 함수로 관리

### TCA
- @Reducer 매크로 + @ObservableState 사용
- Action은 이벤트 기반 네이밍 (incrementButtonTapped, numberFactResponse)
- Effect: 부작용 없으면 .none, 비동기 작업은 .run
- Store: StoreOf<Feature>로 선언
- 액션 간 로직 공유 지양 (헬퍼 메서드 사용)
- CPU 작업은 Effect 내에서 처리
- 테스트: TestStore 패턴 사용

## Git Rules

### Branch Strategy
- main: 배포 / develop: 통합 / feature/{issue-number}: 작업
- PR → develop 머지

### Commit Message
- 형식: `[{Header}]: {Message}`
- Header
  - FEAT: 기능 개발
  - REFACTOR: 코드 변경, 리팩토링
  - ADD: 리소스 파일 추가
  - FIX: 에러 및 버그 수정
  - HOTFIX: 긴급수정
  - DOCS: 문서 작성
  - TEST: 테스트코드 작성
  - CHORE: 기타
- Message
  - 한국어로 작성
  - 한줄, 최대 50자
  - 마침표 및 특수기호 미사용
  - 간결하고 요점적으로 작성
- Body
  - 필요시 작성
  - 어떻게보다 무엇을 왜 변경했는지 작성
- 예시: `[FEAT]: 로그인 화면 UI 구현`
