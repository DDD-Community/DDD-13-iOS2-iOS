# Code Convention Rules

## Swift

### Import 규칙
- Apple 프레임워크 → 외부 라이브러리 → 내부 모듈 순으로 그룹을 구분하고, 빈 줄로 분리한다.
- 각 그룹 내에서는 알파벳 오름차순으로 정렬한다.

```swift
// Preferred
import Foundation
import SwiftUI

import Alamofire
import ComposableArchitecture

import DesignSystem
import Entity

// Not Preferred
import ComposableArchitecture
import DesignSystem
import Foundation
import SwiftUI
```

### Guard 규칙
- Optional Binding에 shorthand syntax를 사용한다: `guard let value else { return }`
- `guard ~ else`가 한줄이면 한줄로 작성한다.
- condition이 여러 개이고 한줄에 안 들어가면 줄내림한다.
- guard 뒤에는 반드시 빈 줄을 추가한다.

```swift
// Preferred
guard let number else { return }

guard
    let name,
    let number,
    isFavorited
else { return }

// Not Preferred
guard let number = number else { return }
```

### final 규칙
- 상속이 필요 없는 class에는 `final`을 붙인다.

### 접근자 규칙
- 내부에서만 쓰이는 변수/함수는 `private`으로 명시한다.
- `fileprivate`는 꼭 필요한 경우가 아니면 `private`을 사용한다.

### 함수 정의 줄내림 규칙
- 함수 파라미터가 길 경우 각 파라미터를 줄내림하고, 닫는 괄호는 별도 줄에 배치한다.

```swift
// Preferred
func changeChannel(
    name: String,
    number: Int,
    isFavorited: Bool
) {
    ...
}

// Not Preferred
func changeChannel(
    name: String,
    number: Int,
    isFavorited: Bool) {
    ...
}
```

### Switch/Enum 줄내림 규칙
- 모든 case가 한줄 return이면 붙여서 작성한다.
- case 내 로직이 있으면 줄내림 후, 다음 case 전에 빈 줄을 추가한다.

```swift
// 한줄 return
switch channelNumber {
case .main: return 0
case .sub: return 1
}

// 로직 포함
switch checkChannel {
case .main:
    guard channel.number != 0 else { return }
    channel.changeChannel(number: 0)

case .sub:
    channel.changeChannel(number: 1)
}
```

### 연산자 줄내림 규칙
- `+`, `||`, `&&` 등의 줄내림은 연산자를 다음 줄 앞에 배치한다.

```swift
// Preferred
let isSuccess = !channel.isEmpty
    && isFavorited
    && channel.number > 0

// Not Preferred
let isSuccess = !channel.isEmpty &&
    isFavorited &&
    channel.number > 0
```

### 삼항연산자 규칙
- `if ~ else`로 묶인 단순 return/대입은 삼항연산자로 줄인다.
- 줄내림 시 `?`를 기준으로 내린다.
- 단순 분기(함수 호출 등)에는 삼항연산자를 사용하지 않는다.
- 중첩 삼항연산자는 변수로 분리한다.

```swift
// Preferred
return number == 0 ? .main : .sub

return number == 0
    ? .main : .sub

// Not Preferred
return number == 0 ?
    .main : .sub
```

### Array 선언 규칙
- 빈 Array/Dictionary는 리터럴로 선언한다.

```swift
// Preferred
var managers: [Manager] = []
var counts: [String: Int] = [:]

// Not Preferred
var managers = [Manager]()
var counts = [String: Int]()
```

### 메모리 관리 규칙
- 클로저에서 `[weak self]` + `guard let self else { return }` 패턴을 사용한다.

```swift
self.closePopup { [weak self] _ in
    guard let self else { return }
    self.popAllController()
}
```

### 상수 선언 규칙
- 상수 그룹은 `struct` 대신 `private enum`으로 선언한다.
- 용도별로 분리: `Metric`, `Font`, `Section`, `Row`, `Constant`

```swift
private enum Metric {
    static let avatarLength: CGFloat = 3
}

private enum Constant {
    static let maxLines = 2
}
```

## SwiftUI

### SubView 선언 규칙
- `@ViewBuilder` 함수 대신 `struct`로 SubView를 선언한다.
- 부모 뷰의 `@State`를 변경해야 할 경우 `@Binding`을 사용한다.

```swift
// Preferred
struct SubView: View {
    @Binding private var isFavorited: Bool

    init(isFavorited: Binding<Bool>) {
        self._isFavorited = isFavorited
    }

    var body: some View { ... }
}

// Not Preferred
@ViewBuilder
func subView(title: String) -> some View { ... }
```

### SwiftUI 이름 규칙
- SwiftUI View 네이밍에 `View` suffix를 붙이지 않는다.
- 단, 명확히 View임을 나타내야 하는 경우는 예외.

```swift
// Preferred
struct ChannelButton: View { ... }

// Not Preferred
struct ChannelButtonView: View { ... }
```

### Spacer() 사용 규칙
- 단순 뷰 크기 확장에는 `Spacer()` 대신 `.frame()`을 사용한다.
- 수직 확장: `maxHeight: .infinity`, 수평 확장: `maxWidth: .infinity`

```swift
// Preferred
HStack { ... }
    .frame(maxWidth: .infinity, alignment: .leading)

// Not Preferred
HStack {
    ...
    Spacer()
}
```
