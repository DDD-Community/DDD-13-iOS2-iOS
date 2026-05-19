//
//  BangawoPreview.swift
//  DesignSystem
//

import SwiftUI

/// #Preview 블록에서 Pretendard 폰트를 등록하기 위한 래퍼 뷰.
/// 앱 진입점을 거치지 않는 Preview 환경에서는 폰트가 자동 등록되지 않으므로
/// init()에서 registerAllCustomFonts()를 호출해 렌더링 전에 폰트를 보장한다.
public struct BangawoPreview<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        DesignSystemFontFamily.registerAllCustomFonts()
        self.content = content()
    }

    public var body: some View {
        content
    }
}
