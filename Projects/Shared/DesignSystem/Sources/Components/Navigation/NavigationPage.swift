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

    /// - Parameter trailingIcons: 우측에 표시할 아이콘 목록. 디자인 명세상 최대 2개까지만 표시됩니다.
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
        ZStack {
            HStack(spacing: 0) {
                if let leadingAction {
                    LeadingArea(action: leadingAction)
                }
                Color.clear.frame(maxWidth: .infinity)
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
            if let title {
                BangawoText(title, textStyle: .titleLarge)
                    .foregroundStyle(Colors.gray900)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, Spacing.spacing300)
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

    private struct LeadingArea: View {
        let action: () -> Void

        var body: some View {
            NavigationIconButton(image: Image.Asset.icArrowBigLeft24, showsBadge: false, action: action)
                .padding(.leading, Spacing.spacing225)
                .padding(.trailing, Spacing.spacing150)
        }
    }
}

#Preview("gradient - 뒤로가기 + 타이틀 + 아이콘") {
    NavigationPage(
        background: .gradient,
        leadingAction: {},
        title: "상세 페이지",
        trailingIcons: [
            NavigationIconItem(icon: .verticalMenu24) {}
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
