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

## Git Workflow
- main: 배포 / develop: 통합 / feature/{issue-number}: 작업
- PR → develop 머지, 리뷰어 1명 필수, Assignee는 PR 작성자
