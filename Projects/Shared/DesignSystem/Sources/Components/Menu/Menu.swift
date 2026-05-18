//
//  Menu.swift
//  DesignSystem
//

import SwiftUI

public struct Menu: View {
    // MARK: - Properties

    private let groupTitle: String?
    private let items: [Item]

    // MARK: - Init

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
                ItemRow(item: items[index])
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
            Text(title)
                .pretendardCustomFont(textStyle: .labelXSmall)
                .foregroundStyle(Colors.gray600)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.spacing200)
                .padding(.bottom, Spacing.spacing100)
                .padding(.horizontal, Spacing.spacing225)
        }
    }
}

// MARK: - ItemRow

private extension Menu {
    struct ItemRow: View {
        let item: Item

        var body: some View {
            Button(action: item.action) {
                HStack(spacing: Spacing.spacing200) {
                    if let icon = item.leadingIcon {
                        icon
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: Sizing.sizing150, height: Sizing.sizing150)
                            .foregroundStyle(Colors.gray600)
                    }
                    Text(item.label)
                        .pretendardCustomFont(textStyle: .labelMedium)
                        .foregroundStyle(Colors.gray800)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(Spacing.spacing250)
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            Menu(
                groupTitle: "그룹 타이틀",
                items: [
                    .init(leadingIcon: Image.Asset.icStar24, label: "메뉴 항목 1") {},
                    .init(leadingIcon: Image.Asset.icStar24, label: "메뉴 항목 2") {},
                    .init(label: "아이콘 없는 항목") {},
                ]
            )

            Menu(items: [
                .init(label: "타이틀 없는 메뉴 1") {},
                .init(label: "타이틀 없는 메뉴 2") {},
                .init(leadingIcon: Image.Asset.icStar24, label: "타이틀 없는 메뉴 3") {},
                .init(leadingIcon: Image.Asset.icStar24, label: "타이틀 없는 메뉴 4") {},
                .init(leadingIcon: Image.Asset.icStar24, label: "타이틀 없는 메뉴 5") {},
            ])
        }
        .padding(24)
    }
    .background(Colors.gray200)
}
