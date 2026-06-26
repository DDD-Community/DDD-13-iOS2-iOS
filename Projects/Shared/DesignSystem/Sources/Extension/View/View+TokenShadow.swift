//
//  View+TokenShadow.swift
//  DesignSystem
//

import SwiftUI

public extension View {
    /// 디자인 토큰 `DesignTokenShadow`를 SwiftUI `shadow` modifier로 분해해 적용한다.
    /// SwiftUI `shadow`의 radius는 blur의 절반에 해당한다.
    func tokenShadow(_ shadow: DesignTokenShadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.blur / 2,
            x: shadow.offsetX,
            y: shadow.offsetY
        )
    }
}
