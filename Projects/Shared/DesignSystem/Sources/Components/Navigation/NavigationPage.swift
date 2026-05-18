//
//  NavigationPage.swift
//  DesignSystem
//

import SwiftUI

public struct NavigationPage: View {
    public enum Background {
        case gradient
        case clear
    }

    private let background: Background
    private let leadingAction: (() -> Void)?
    private let title: String?
    private let trailingIcons: [NavigationIconItem]

    public init(
        background: Background,
        leadingAction: (() -> Void)? = nil,
        title: String? = nil,
        trailingIcons: [NavigationIconItem] = []
    ) {
        self.background = background
        self.leadingAction = leadingAction
        self.title = title
        self.trailingIcons = Array(trailingIcons.prefix(2))
    }

    public var body: some View {
        HStack(spacing: 0) {
            if let leadingAction {
                Button {
                    leadingAction()
                } label: {
                    Image.Asset.icArrowBigLeft24
                        .frame(width: Sizing.sizing200, height: Sizing.sizing200)
                }
                .frame(width: Sizing.sizing450, height: Sizing.sizing450)
            }

            if let title {
                Text(title)
                    .pretendardFont(family: .Medium, size: Typography.typographySize400)
                    .foregroundStyle(Colors.gray900)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, Spacing.spacing300)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity)
            }

            if !trailingIcons.isEmpty {
                HStack(spacing: 0) {
                    ForEach(trailingIcons) { item in
                        Button {
                            item.action()
                        } label: {
                            item.image
                                .frame(width: Sizing.sizing200, height: Sizing.sizing200)
                        }
                        .padding(Spacing.spacing225)
                    }
                }
                .padding(.trailing, Spacing.spacing300)
            }
        }
        .frame(height: Sizing.sizing450)
        .padding(.vertical, Spacing.spacing150)
        .background {
            if background == .gradient {
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea(edges: .top)
            }
        }
    }
}

#Preview("gradient - 뒤로가기 + 타이틀 + 아이콘") {
    NavigationPage(
        background: .gradient,
        leadingAction: {},
        title: "상세 페이지",
        trailingIcons: [
            NavigationIconItem(image: Image(systemName: "ellipsis")) {}
        ]
    )
}

#Preview("clear - 뒤로가기 + 타이틀") {
    NavigationPage(
        background: .clear,
        leadingAction: {},
        title: "설정"
    )
}

#Preview("clear - 타이틀만") {
    NavigationPage(background: .clear, title: "알림")
}
