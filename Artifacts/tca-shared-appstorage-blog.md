# SwiftUI `@AppStorage`에서 TCA `@Shared(.appStorage)`로 옮긴 이유

로그인 세션 만료 처리를 구현하면서 처음에는 `RootView`에서 SwiftUI의 `@AppStorage`를 사용했다.

```swift
@AppStorage(UserDefaultsKey.isLogin)
private var isLogin: Bool = false
```

그리고 값이 `false`로 바뀌면 TCA 액션을 보냈다.

```swift
.onChange(of: isLogin) { _, newValue in
    if !newValue {
        store.send(.sessionExpired)
    }
}
```

이 방식은 잘 동작한다. `Interceptor`에서 리프레시 토큰 만료를 감지하고:

```swift
UserDefaults.standard.set(false, forKey: UserDefaultsKey.isLogin)
```

를 호출하면, `RootView`의 `@AppStorage`가 변경을 감지하고 `sessionExpired` 액션을 보낸다.

전체 흐름은 다음과 같다.

```text
refresh token 만료
→ UserDefaults isLogin = false
→ RootView @AppStorage 변경 감지
→ store.send(.sessionExpired)
→ RootFeature가 로그인 화면으로 전환
```

하지만 이 구조에는 아쉬운 점이 있었다.

`isLogin`은 단순한 View 상태라기보다는 앱의 인증 상태에 가깝다. 그런데 이 값을 `RootView`가 직접 들고 있으면, `RootFeature.State`만 봤을 때 현재 인증 상태를 알기 어렵다.

TCA에서는 앱의 중요한 상태를 View가 직접 들기보다 Feature State에 표현하는 쪽이 더 자연스럽다.

그래서 `@AppStorage` 대신 TCA의 `@Shared(.appStorage)`를 사용했다.

```swift
@ObservableState
public struct State: Equatable {
    @Shared(.appStorage(UserDefaultsKey.isLogin))
    public var isLogin: Bool = false

    public var mode: Mode = .auth
    public var auth: AuthFlowFeature.State = .init()
    public var home: HomeFeature.State = .init()
}
```

`@Shared(.appStorage)`는 UserDefaults에 저장되는 값을 TCA State처럼 다룰 수 있게 해준다.

SwiftUI의 `@AppStorage`가 View와 UserDefaults를 연결한다면:

```swift
@AppStorage("isLogin")
private var isLogin = false
```

TCA의 `@Shared(.appStorage)`는 Feature State와 UserDefaults를 연결한다.

```swift
@Shared(.appStorage("isLogin"))
var isLogin = false
```

즉 차이는 이렇다.

```text
@AppStorage
→ View가 UserDefaults 값을 직접 관찰

@Shared(.appStorage)
→ Feature State가 UserDefaults 값을 보유
→ View는 store.isLogin을 관찰
```

## `@Shared(.inMemory)`와 `@Shared(.appStorage)`의 차이

`@Shared`는 값을 어디에 저장할지에 따라 persistence strategy를 선택한다.

대표적으로 많이 쓰는 방식이 `.inMemory`와 `.appStorage`다.

```swift
@Shared(.inMemory("draftFilter"))
var draftFilter = Filter()

@Shared(.appStorage(UserDefaultsKey.isLogin))
var isLogin = false
```

둘의 차이는 저장 위치와 생명주기다.

| 구분 | `@Shared(.inMemory)` | `@Shared(.appStorage)` |
| --- | --- | --- |
| 저장 위치 | 메모리 | UserDefaults |
| 앱 재실행 후 유지 | 유지되지 않음 | 유지됨 |
| 대표 용도 | 실행 중 임시 공유 상태, 테스트용 상태 | 로그인 여부, 온보딩 완료 여부, 설정값 |
| 여러 Feature 간 공유 | 가능 | 가능 |
| 영속성 | 없음 | 있음 |

`.inMemory`는 앱이 실행되는 동안에만 값을 공유한다. 앱을 종료하면 값은 사라진다.

반면 `.appStorage`는 UserDefaults에 값을 저장한다. 앱을 종료했다가 다시 실행해도 값이 유지된다.

따라서 `isLogin`처럼 앱 재실행 후에도 판단에 필요한 값은 `.appStorage`가 더 적합하다.

```swift
@Shared(.appStorage(UserDefaultsKey.isLogin))
public var isLogin: Bool = false
```

반대로 화면 간에 잠깐 공유하면 되는 필터, 편집 중인 임시 값, 테스트에서만 쓰는 상태라면 `.inMemory`가 더 가볍다.

```swift
@Shared(.inMemory("selectedTab"))
var selectedTab = Tab.home
```

정리하면:

```text
.inMemory
→ 앱 실행 중에만 공유
→ 앱 종료 시 사라짐

.appStorage
→ UserDefaults에 저장
→ 앱 재실행 후에도 유지
```

## 변경 후 Root 플로우

변경 후 `RootView`는 더 이상 `@AppStorage`를 직접 갖지 않는다. 대신 store의 상태를 관찰한다.

```swift
.onChange(of: store.isLogin) { _, newValue in
    if !newValue, store.mode == .main {
        store.send(.sessionExpired)
    }
}
```

세션 만료 처리는 여전히 Reducer에서 한다.

```swift
case .sessionExpired:
    state.mode = .auth
    state.auth = AuthFlowFeature.State(entryPoint: .login)
    state.home = HomeFeature.State()
    return .none
```

여기서 중요한 점이 있다.

`@Shared(.appStorage)`를 쓴다고 해서 reducer 로직이 자동으로 실행되는 것은 아니다.

UserDefaults 값이 바뀌면 `state.isLogin` 값은 관찰 가능해지지만, `state.mode = .auth` 같은 상태 전환은 반드시 Action을 통해 Reducer에서 처리해야 한다.

그래서 여전히 `.onChange`에서 액션을 보낸다.

```text
UserDefaults isLogin 변경
→ @Shared(.appStorage)로 store.isLogin 변경
→ RootView가 store.isLogin 변경 감지
→ sessionExpired 액션 전송
→ RootFeature가 화면 전환
```

## 최종 인증 만료 흐름

최종 플로우는 다음과 같다.

```text
1. 일반 API 요청
2. accessToken 만료로 401 응답
3. Interceptor가 refresh token으로 accessToken 갱신 시도
4. refresh token도 만료되어 갱신 실패
5. accessToken / refreshToken 삭제
6. UserDefaults isLogin = false
7. RootFeature.State.isLogin 변경
8. RootView가 store.isLogin 변경 감지
9. sessionExpired 액션 전송
10. RootFeature가 auth/login 상태로 전환
```

정리하면, `@AppStorage` 방식도 충분히 동작한다. 하지만 로그인 여부처럼 앱 전역 상태에 가까운 값은 `@Shared(.appStorage)`로 Feature State에 포함시키는 편이 TCA 구조와 더 잘 맞았다.

선택 기준은 이렇게 정리할 수 있다.

```text
간단한 View 전용 설정값
→ @AppStorage

TCA Feature들이 공유하거나 테스트에서 다루고 싶은 앱 상태
→ @Shared(.appStorage)

앱 실행 중에만 유지하면 되는 공유 상태
→ @Shared(.inMemory)
```

이번 변경으로 인증 상태가 View가 아닌 RootFeature의 State에 드러나게 되었고, 화면 전환 로직은 기존처럼 Reducer에서 처리할 수 있게 되었다.
