//
//  Tab.swift
//  DesignSystem
//

import SwiftUI

public struct Tab: View {
    private let labels: [String]
    @Binding private var selectedIndex: Int
    private let variant: TabVariant
    private let size: TabSize
    @Namespace private var namespace

    public init(
        labels: [String],
        selectedIndex: Binding<Int>,
        variant: TabVariant,
        size: TabSize
    ) {
        self.labels = labels
        self._selectedIndex = selectedIndex
        self.variant = variant
        self.size = size
    }

    public var body: some View {
        switch variant {
        case .fixed:
            ZStack(alignment: .bottom) {
                bottomLine
                HStack(spacing: 0) {
                    ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                        TabItem(
                            label: label,
                            isSelected: selectedIndex == index,
                            variant: variant,
                            size: size,
                            itemCount: labels.count,
                            namespace: namespace
                        )
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3, bounce: 0.1)) {
                                selectedIndex = index
                            }
                        }
                    }
                }
            }

        case .scrollable:
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                            TabItem(
                                label: label,
                                isSelected: selectedIndex == index,
                                variant: variant,
                                size: size,
                                itemCount: labels.count,
                                namespace: namespace
                            )
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.3, bounce: 0.1)) {
                                    selectedIndex = index
                                }
                            }
                        }
                    }
                    .padding(.leading, Spacing.spacing250)
                }
                bottomLine
            }
        }
    }

    private var bottomLine: some View {
        Rectangle()
            .fill(Colors.gray300)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

// MARK: - TabItem

private extension Tab {
    struct TabItem: View {
        let label: String
        let isSelected: Bool
        let variant: TabVariant
        let size: TabSize
        let itemCount: Int
        let namespace: Namespace.ID

        var body: some View {
            ZStack(alignment: .bottom) {
                BangawoText(label, textStyle: labelTextStyle)
                    .foregroundStyle(Colors.gray900)
                    .padding(.horizontal, labelHorizontalPadding)
                    .padding(.vertical, labelVerticalPadding)

                if isSelected {
                    indicator
                }
            }
            .frame(width: itemWidth)
        }

        private var itemWidth: CGFloat? {
            switch variant {
            case .fixed: return UIScreen.screenWidth / CGFloat(itemCount)
            case .scrollable: return nil
            }
        }

        private var labelTextStyle: CustomSizeFont {
            size == .small ? .titleSmall : .headingSmall
        }

        private var labelHorizontalPadding: CGFloat {
            size == .small ? Spacing.spacing200 : Spacing.spacing250
        }

        private var labelVerticalPadding: CGFloat {
            size == .small ? Spacing.spacing250 : Spacing.spacing300
        }

        @ViewBuilder
        private var indicator: some View {
            switch variant {
            case .fixed:
                Capsule()
                    .fill(Colors.gray900)
                    .frame(maxWidth: .infinity)
                    .frame(height: 2)
                    .matchedGeometryEffect(id: "tabIndicator", in: namespace)

            case .scrollable:
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: .infinity,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: .infinity
                ))
                .fill(Colors.gray900)
                .frame(height: 2)
                .padding(.horizontal, Spacing.spacing225)
                .matchedGeometryEffect(id: "tabIndicator", in: namespace)
            }
        }
    }
}

// MARK: - Preview

#Preview("Fixed / Small") {
    @Previewable @State var selectedIndex = 0

    Tab(
        labels: ["탭1", "탭2", "탭3"],
        selectedIndex: $selectedIndex,
        variant: .fixed,
        size: .small
    )
}

#Preview("Fixed / Large") {
    @Previewable @State var selectedIndex = 1

    Tab(
        labels: ["탭1", "탭2", "탭3"],
        selectedIndex: $selectedIndex,
        variant: .fixed,
        size: .large
    )
}

#Preview("Scrollable / Small") {
    @Previewable @State var selectedIndex = 0

    Tab(
        labels: ["전체", "모임", "스터디", "운동", "독서", "여행"],
        selectedIndex: $selectedIndex,
        variant: .scrollable,
        size: .small
    )
}

#Preview("Scrollable / Large") {
    @Previewable @State var selectedIndex = 2

    Tab(
        labels: ["전체", "모임", "스터디", "운동", "독서", "여행"],
        selectedIndex: $selectedIndex,
        variant: .scrollable,
        size: .large
    )
}
