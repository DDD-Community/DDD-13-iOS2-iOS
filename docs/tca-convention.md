# TCA (The Composable Architecture) Convention

> PointFree 공식 문서(Performance.md, TestingTCA.md, Navigation docs) 기반 컨벤션

### Action으로 로직을 공유하지 않는다
- Action은 Feature 트리 전체를 순회하므로 비용이 크다.
- 공유 로직은 `Effect<Action>`을 반환하는 private 메서드로 추출한다.

```swift
// Preferred: private 메서드로 공유
case .buttonTapped:
  state.count += 1
  return sharedComputation(state: &state)

private func sharedComputation(state: inout State) -> Effect<Action> {
  .run { send in /* ... */ }
}

// Not Preferred: Action으로 로직 공유
case .buttonTapped:
  state.count += 1
  return .send(.sharedComputation)
```

### Action 네이밍은 "발생한 사건"으로 작성한다
- 의도된 효과가 아닌, 무슨 일이 일어났는지를 서술한다.

```swift
// Preferred: 발생한 이벤트
case loginButtonTapped
case onAppear
case recordsFetched([Diary])

// Not Preferred: 의도된 효과
case performLogin
case loadData
case setRecords([Diary])
```

### Effect.run에서 @ObservableState 전체를 캡처하지 않는다
- `@ObservableState`의 숨겨진 registrar가 메인 액터 바깥으로 나가면 런타임 이슈가 발생한다.
- 필요한 값만 추출한 뒤 캡처한다.

```swift
// Preferred: 필요한 값만 추출 후 캡처
let information = state.information
return .run { send in
  await send(.delegate(information))
}

// Not Preferred: state 전체 캡처
return .run { [state] send in
  await send(.delegate(state.information))
}
```

### Reducer에서 CPU 집약적 작업을 직접 수행하지 않는다
- Reducer는 메인 스레드에서 실행된다. 무거운 연산은 Effect로 분리한다.

```swift
// Preferred: Effect로 분리
case .process:
  return .run { send in
    let result = await heavyWork()
    await send(.processCompleted(result))
  }

// Not Preferred: Reducer 안에서 무거운 연산
case .process:
  for item in largeCollection { /* heavy work */ }
  state.result = result
  return .none
```

### 고빈도 Action은 throttle한다
- 슬라이더, 타이머, 진행률 등 초당 수십 회 발생하는 Action은 로컬 `@State`로 관리하고 최종 값만 전달한다.

```swift
// Preferred: 로컬 @State + 종료 시에만 전달
@State private var opacity: Double = 0.5
Slider(value: $opacity, in: 0...1) {
  store.send(.setOpacity(opacity))
}

// Not Preferred: 매 이벤트마다 Action
Slider(value: Binding(
  get: { store.opacity },
  set: { store.send(.setOpacity($0)) }
), in: 0...1)
```

### Store scope에 computed property를 사용하지 않는다
- scope 콜백은 시스템의 모든 Action마다 실행된다. stored property 경로만 사용한다.

```swift
// Preferred: stored property 경로
ChildView(store: store.scope(state: \.child, action: \.child))

// Not Preferred: 연산이 포함된 scope
ChildView(store: store.scope(state: { expensiveTransform($0) }, action: \.child))
```

### Dependency는 프로토콜이 아닌 struct로 정의한다
- PointFree 공식 패턴. 테스트에서 inline stub 변경이 가능하다.

```swift
// Preferred: struct 기반 Client
@DependencyClient
struct FactClient {
  var fetch: @Sendable (Int) async throws -> String
}

// Not Preferred: protocol 기반
protocol FactClientProtocol {
  func fetch(_ number: Int) async throws -> String
}
```

### Navigation 열거형에 @Reducer enum을 사용한다
- TCA 1.8+에서 수동 State/Action/body 작성을 대체한다.

```swift
// Preferred: @Reducer enum
@Reducer
enum Destination {
  case addItem(AddFeature)
  case editItem(EditFeature)
}

// Not Preferred: 수동 작성
struct Destination: Reducer {
  enum State: Equatable {
    case addItem(AddFeature.State)
    case editItem(EditFeature.State)
  }
  enum Action { ... }
  var body: some ReducerOf<Self> { ... }
}
```

### 일시적 UI 상태는 TCA State가 아닌 SwiftUI에 둔다
- hover, focus, animation 같은 Reducer 로직과 무관한 상태는 View의 `@State`로 관리한다.

```swift
// Preferred: SwiftUI 로컬 상태
struct SomeView: View {
  @State private var isHovered = false
}

// Not Preferred: TCA State에 포함
@ObservableState
struct State: Equatable {
  var isHovered = false
}
```
