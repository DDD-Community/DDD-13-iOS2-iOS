//
//  MenuSheet.swift
//  DesignSystem
//

import SwiftUI

private enum Metric {
    static let iconLength: CGFloat = Sizing.sizing150
    static let closeIconLength: CGFloat = Sizing.sizing100
    static let closeIconPadding: CGFloat = 10
    static let separatorHeight: CGFloat = 1
    static let maxItemCount = 3
}

public struct MenuSheet: View {
    // MARK: - Properties

    private let title: String
    private let items: [Item]
    private let onClose: () -> Void

    // MARK: - Init

    /// - Parameter items: 표시할 메뉴 항목 목록. 디자인 명세상 최대 3개까지만 표시됩니다.
    public init(
        title: String,
        items: [Item],
        onClose: @escaping () -> Void
    ) {
        self.title = title
        self.items = Array(items.prefix(Metric.maxItemCount))
        self.onClose = onClose
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            Header(title: title, onClose: onClose)
            ItemsContainer(items: items)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Header

private extension MenuSheet {
    struct Header: View {
        let title: String
        let onClose: () -> Void

        var body: some View {
            HStack(alignment: .center, spacing: Spacing.spacing200) {
                BangawoText(title, textStyle: .titleMediumEmphasized)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onClose) {
                    Image.Asset.icClose16
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: Metric.closeIconLength, height: Metric.closeIconLength)
                        .foregroundStyle(Colors.gray700)
                        .padding(Metric.closeIconPadding)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, Spacing.spacing300)
            .padding(.leading, Spacing.spacing200)
        }
    }
}

// MARK: - ItemsContainer

private extension MenuSheet {
    struct ItemsContainer: View {
        let items: [Item]

        var body: some View {
            VStack(spacing: 0) {
                ForEach(items.indices, id: \.self) { index in
                    MenuItemRow(item: items[index])
                    if index < items.count - 1 {
                        Separator()
                    }
                }
            }
            .padding(Spacing.spacing200)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .fill(Colors.gray200)
            )
            .padding(.vertical, Spacing.spacing200)
        }
    }
}

// MARK: - MenuItemRow

private extension MenuSheet {
    struct MenuItemRow: View {
        let item: Item

        var body: some View {
            HStack(spacing: Spacing.spacing250) {
                item.icon
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: Metric.iconLength, height: Metric.iconLength)
                    .foregroundStyle(item.tone.iconColor)

                BangawoText(item.label, textStyle: .labelMedium)
                    .foregroundStyle(item.tone.labelColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Spacing.spacing300)
            .padding(.horizontal, Spacing.spacing250)
            .contentShape(Rectangle())
            .onTapGesture { item.action() }
        }
    }
}

// MARK: - Separator

private extension MenuSheet {
    struct Separator: View {
        var body: some View {
            Rectangle()
                .fill(Colors.gray300)
                .frame(height: Metric.separatorHeight)
        }
    }
}

// MARK: - Preview

#Preview("MenuSheet - 항목 3개") {
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .menuSheet(
                    isPresented: $isPresented,
                    title: "메뉴",
                    items: [
                        .init(label: "수정하기", icon: .Asset.icStar24) {},
                        .init(label: "공유하기", icon: .Asset.icStar24) {},
                        .init(label: "삭제하기", icon: .Asset.icStar24, tone: .critical) {},
                    ]
                )
        }
    }
    return Preview()
}

#Preview("MenuSheet - 항목 1개") {
    struct Preview: View {
        @State private var isPresented = false

        var body: some View {
            Button("시트 열기") { isPresented = true }
                .menuSheet(
                    isPresented: $isPresented,
                    title: "메뉴",
                    items: [
                        .init(label: "삭제하기", icon: .Asset.icStar24, tone: .critical) {},
                    ]
                )
        }
    }
    return Preview()
}
