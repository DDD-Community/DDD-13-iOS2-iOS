//
//  Menu.swift
//  DesignSystem
//

import SwiftUI

private enum Metric {
    static let minWidth: CGFloat = 180
}

public struct Menu: View {
    // MARK: - Properties

    private let groupTitle: String?
    private let items: [Item]

    // MARK: - Init

    /// - Parameter items: 표시할 메뉴 항목 목록. 디자인 명세상 최대 5개까지만 표시됩니다.
    public init(
        groupTitle: String? = nil,
        items: [Item]
    ) {
        self.groupTitle = groupTitle
        self.items = Array(items.prefix(5))
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let groupTitle {
                GroupTitleLabel(title: groupTitle)
            }
            ForEach(items.indices, id: \.self) { index in
                MenuItem(item: items[index])
            }
        }
        .frame(minWidth: Metric.minWidth, alignment: .leading)
        .fixedSize(horizontal: true, vertical: false)
        .padding(Spacing.spacing250)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Colors.gray00)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Colors.gray100, lineWidth: BorderWidth.borderWidth100)
        )
        .shadow(
            color: BoxShadow.boxShadow300.color,
            radius: BoxShadow.boxShadow300.blur,
            x: BoxShadow.boxShadow300.offsetX,
            y: BoxShadow.boxShadow300.offsetY
        )
    }
}

// MARK: - GroupTitleLabel

private extension Menu {
    struct GroupTitleLabel: View {
        let title: String

        var body: some View {
            BangawoText(title, textStyle: .labelXSmall)
                .foregroundStyle(Colors.gray600)
                .frame(alignment: .leading)
                .padding(.top, Spacing.spacing200)
                .padding(.bottom, Spacing.spacing100)
                .padding(.horizontal, Spacing.spacing225)
        }
    }
}

// MARK: - MenuItem

private extension Menu {
    struct MenuItem: View {
        let item: Item

        @State private var isPressed = false
        @State private var size: CGSize = .zero

        var body: some View {
            HStack(spacing: Spacing.spacing200) {
                if let icon = item.icon {
                    icon
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Sizing.sizing150, height: Sizing.sizing150)
                        .foregroundStyle(item.iconColor ?? Colors.gray600)
                }
                BangawoText(item.label, textStyle: .labelMedium)
                    .foregroundStyle(Colors.gray800)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(Spacing.spacing250)
            .background(
                Group {
                    if isPressed {
                        RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                            .fill(Colors.grayAlpha200)
                    }
                }
            )
            .contentShape(Rectangle())
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        isPressed = contains(value.location)
                    }
                    .onEnded { value in
                        if contains(value.location) {
                            item.action()
                        }

                        isPressed = false
                    }
            )
        }

        private func contains(_ location: CGPoint) -> Bool {
            location.x >= 0
                && location.y >= 0
                && location.x <= size.width
                && location.y <= size.height
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Menu(
                groupTitle: "그룹 타이틀",
                items: [
                    .init(label: "메뉴 항목 1", icon: .Asset.icStar24) {},
                    .init(label: "메뉴 항목 2", icon: .Asset.icStar24) {},
                    .init(label: "메뉴 항목 3", icon: .Asset.icStar24) {},
                ]
            )

            Menu(
                items: [
                    .init(label: "타이틀 없는 메뉴 1") {},
                    .init(label: "타이틀 없는 메뉴 2") {},
                    .init(label: "타이틀 없는 메뉴 3") {},
                ]
            )
        }
        .padding(24)
    }
    .background(Colors.gray200)
}
