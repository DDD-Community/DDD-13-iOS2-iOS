//
//  NavigationMain.swift
//  DesignSystem
//

import SwiftUI

public struct NavigationMain: View {
    public enum Background {
        case gradient
        case clear
    }

    private let background: Background
    private let title: String?
    private let trailingIcons: [NavigationIconItem]

    /// - Parameter trailingIcons: 우측에 표시할 아이콘 목록. 디자인 명세상 최대 3개까지만 표시됩니다.
    public init(
        background: Background,
        title: String? = nil,
        trailingIcons: [NavigationIconItem] = []
    ) {
        self.background = background
        self.title = title
        self.trailingIcons = Array(trailingIcons.prefix(3))
    }

    public var body: some View {
        HStack(spacing: 0) {
            if let title {
                BangawoText(title, textStyle: .headingSmall)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, Spacing.spacing450)
            } else {
                Color.clear
                    .frame(maxWidth: .infinity)
            }

            if !trailingIcons.isEmpty {
                HStack(spacing: 0) {
                    ForEach(trailingIcons) { item in
                        NavigationIconButton(
                            image: item.icon.image,
                            showsBadge: item.showsBadge,
                            action: item.action
                        )
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

#Preview("gradient - 타이틀 + 아이콘") {
    NavigationMain(
        background: .gradient,
        title: "반가워",
        trailingIcons: [
            NavigationIconItem(icon: .user24) {},
            NavigationIconItem(icon: .verticalMenu24) {}
        ]
    )
}

#Preview("clear - 타이틀만") {
    NavigationMain(background: .clear, title: "홈")
}

#Preview("clear - 아이콘 없음") {
    NavigationMain(background: .clear)
}
