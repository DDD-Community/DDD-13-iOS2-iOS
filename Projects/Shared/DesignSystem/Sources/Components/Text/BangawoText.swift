//
//  BangawoText.swift
//  DesignSystem
//

import SwiftUI

public struct BangawoText: View {
    private let content: String
    private let textStyle: CustomSizeFont

    public init(_ content: String, textStyle: CustomSizeFont) {
        self.content = content
        self.textStyle = textStyle
    }

    public var body: some View {
        Text(attributedString)
    }

    private var attributedString: AttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = textStyle.lineHeight
        paragraphStyle.maximumLineHeight = textStyle.lineHeight

        var attributed = AttributedString(content)
        attributed.paragraphStyle = paragraphStyle
        attributed.font = .custom("PretendardVariable-\(textStyle.fontFamily)", size: textStyle.size)
        attributed.kern = textStyle.letterSpacing * textStyle.size
        return attributed
    }
}
