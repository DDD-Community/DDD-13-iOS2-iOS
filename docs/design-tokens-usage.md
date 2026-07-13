# Design Tokens 사용 가이드

디자인 토큰은 [design-tokens](https://github.com/zizizoi0709-p/design-tokens) 레포에서 Style Dictionary를 통해 자동 생성되며,
`Projects/Shared/DesignSystem/Sources/` 아래 Swift 파일로 반영됩니다.

> 디자이너가 토큰을 수정하면 PR이 자동 생성되어 모든 토큰이 일괄 반영됩니다.

---

## Color

**파일**: `Sources/Color/Generated/Colors+Generated.swift`  
**타입**: `SwiftUI.Color`

xcassets 기반으로 라이트/다크 모드를 자동 지원합니다.

```swift
Text("안녕")
    .foregroundStyle(Colors.blue500)

Rectangle()
    .fill(Colors.gray100)

// 배경
someView
    .background(Colors.gray50)
```

---

## Spacing

**파일**: `Sources/Tokens/Generated/Spacing+Generated.swift`  
**타입**: `CGFloat`

| 토큰 | 값 |
|---|---|
| `spacing50` | 2pt |
| `spacing100` | 4pt |
| `spacing200` | 8pt |
| `spacing300` | 16pt |
| `spacing400` | 24pt |

```swift
VStack(spacing: Spacing.spacing200) { ... }       // 8pt

Text("안녕")
    .padding(.horizontal, Spacing.spacing300)      // 16pt
    .padding(.vertical, Spacing.spacing200)        // 8pt
```

---

## Sizing

**파일**: `Sources/Tokens/Generated/Sizing+Generated.swift`  
**타입**: `CGFloat`

아이콘, 컴포넌트의 고정 크기에 사용합니다.

```swift
Image(systemName: "star")
    .frame(width: Sizing.sizing200, height: Sizing.sizing200)   // 24pt

someView
    .frame(height: Sizing.sizing450)   // 44pt (탭바 높이 등)
```

---

## BorderRadius

**파일**: `Sources/Tokens/Generated/BorderRadius+Generated.swift`  
**타입**: `CGFloat`

```swift
RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)    // 8pt
    .fill(Colors.gray50)

// Pill 형태
Text("태그")
    .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadiusFull))   // 999pt
```

---

## BorderWidth

**파일**: `Sources/Tokens/Generated/BorderWidth+Generated.swift`  
**타입**: `CGFloat`

```swift
RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
    .stroke(Colors.gray300, lineWidth: BorderWidth.borderWidth100)   // 1pt

// 강조 테두리
someView
    .overlay(
        RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
            .stroke(Colors.blue500, lineWidth: BorderWidth.borderWidth200)   // 2pt
    )
```

---

## Opacity

**파일**: `Sources/Tokens/Generated/Opacity+Generated.swift`  
**타입**: `CGFloat`

```swift
// 비활성화 상태
Text("비활성화")
    .opacity(Opacity.opacity400)    // 0.32

// 딤 처리
Color.black
    .opacity(Opacity.opacity700)    // 0.64
```

---

## Typography

**파일**: `Sources/Tokens/Generated/Typography+Generated.swift`  
**타입**: `String` (fontFamily), `UIFont.Weight` (weight), `CGFloat` (size, lineHeight, letterSpacing)

`UIFont`를 조합해 사용합니다. `lineSpacing`은 lineHeight와 fontSize의 차이로 계산합니다.

```swift
// Font 확장 예시
extension Font {
    static func pretendard(size: CGFloat, weight: UIFont.Weight) -> Font {
        .custom(Typography.typographyFontFamily, size: size)
    }
}

// 사용
Text("제목")
    .font(.pretendard(size: Typography.typographySize400, weight: Typography.typographyWeight700))
    .lineSpacing(Typography.typographyLineHeight400 - Typography.typographySize400)

// kerning (letterSpacing은 em 단위이므로 fontSize를 곱함)
Text("본문")
    .font(.pretendard(size: Typography.typographySize300, weight: Typography.typographyWeight400))
    .kerning(Typography.typographyLetterSpacing100 * Typography.typographySize300)
```

---

## BoxShadow

**파일**: `Sources/Tokens/Generated/BoxShadow+Generated.swift`  
**타입**: `DesignTokenShadow`

SwiftUI의 `shadow` modifier에 분해해서 사용합니다.

```swift
// View extension 추가 권장
extension View {
    func tokenShadow(_ shadow: DesignTokenShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.blur / 2,
            x: shadow.offsetX,
            y: shadow.offsetY
        )
    }
}

// 사용
CardView()
    .tokenShadow(BoxShadow.boxShadow200)
```

---

## 토큰 값 전체 목록

각 토큰의 실제 수치는 생성 파일에서 직접 확인하거나,
[design-tokens 레포](https://github.com/zizizoi0709-p/design-tokens)의 `tokens.json`을 참고하세요.
