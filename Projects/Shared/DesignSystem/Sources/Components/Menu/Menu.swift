//
//  Menu.swift
//  DesignSystem
//

import SwiftUI

public struct Menu: View {
    // MARK: - Properties

    private let groupTitle: String?
    private let items: [Item]
    @Binding private var selectedIndex: Int?

    // MARK: - Init

    public init(
        groupTitle: String? = nil,
        selectedIndex: Binding<Int?> = .constant(nil),
        items: [Item]
    ) {
        self.groupTitle = groupTitle
        self._selectedIndex = selectedIndex
        self.items = Array(items.prefix(5))
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let groupTitle {
                GroupTitleLabel(title: groupTitle)
            }
            ForEach(items.indices, id: \.self) { index in
                MenuItem(item: items[index], isSelected: selectedIndex == index) {
                    selectedIndex = index
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .frame(maxWidth: .infinity, alignment: .leading)
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
        let isSelected: Bool
        let onTap: () -> Void

        var body: some View {
            Button(action: {
                item.action()
                onTap()
            }) {
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
                        if isSelected {
                            RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                                .fill(Colors.grayAlpha200)
                        }
                    }
                )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    @State var selectedIndex: Int? = 0
    @State var selectedIndex2: Int? = nil

    return ScrollView {
        VStack(spacing: 24) {
            Menu(
                groupTitle: "그룹 타이틀",
                selectedIndex: $selectedIndex,
                items: [
                    .init(label: "메뉴 항목 1", icon: .Asset.icStar24) {},
                    .init(label: "메뉴 항목 2", icon: .Asset.icStar24) {},
                    .init(label: "메뉴 항목 3", icon: .Asset.icStar24) {},
                ]
            )

            Menu(
                selectedIndex: $selectedIndex2,
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
