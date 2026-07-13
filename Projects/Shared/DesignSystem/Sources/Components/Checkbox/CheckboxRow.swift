//
//  CheckboxRow.swift
//  DesignSystem
//

import SwiftUI

public struct CheckboxRow: View {
    // MARK: - Properties

    private let title: String
    private let checkboxVariant: Checkbox.Variant
    private let checkboxState: Checkbox.State
    private let size: Size
    private let description: String?
    private let arrowDirection: ArrowDirection?
    private let titleColor: Color

    // MARK: - Init

    public init(
        _ title: String,
        checkboxVariant: Checkbox.Variant,
        checkboxState: Checkbox.State,
        size: Size,
        description: String? = nil,
        arrowDirection: ArrowDirection? = nil,
        titleColor: Color = Colors.gray800
    ) {
        self.title = title
        self.checkboxVariant = checkboxVariant
        self.checkboxState = checkboxState
        self.size = size
        self.description = description
        self.arrowDirection = arrowDirection
        self.titleColor = titleColor
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Checkbox(variant: checkboxVariant, state: checkboxState, size: size.checkboxSize)

            LabelArea(title: title, description: description, size: size, titleColor: titleColor)

            if let direction = arrowDirection {
                ArrowIcon(direction: direction)
            }
        }
        .padding(.vertical, Spacing.spacing250)
        .padding(.horizontal, Spacing.spacing200)
    }

}

// MARK: - LabelArea

private extension CheckboxRow {
    struct LabelArea: View {
        let title: String
        let description: String?
        let size: Size
        let titleColor: Color

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText(title, textStyle: size.titleFont)
                    .foregroundStyle(titleColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let description {
                    BangawoText(description, textStyle: size.descriptionFont)
                        .foregroundStyle(Colors.gray700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - ArrowIcon

private extension CheckboxRow {
    struct ArrowIcon: View {
        let direction: ArrowDirection

        var body: some View {
            arrowImage
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: Sizing.sizing200, height: Sizing.sizing200)
                .foregroundStyle(Colors.gray600)
        }

        private var arrowImage: Image {
            switch direction {
            case .right: Image.Asset.icArrowSmallRight24
            case .down: Image.Asset.icArrowSmallDown24
            case .up: Image.Asset.icArrowSmallUp24
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        CheckboxRow(
            "제목만 있는 항목",
            checkboxVariant: .circle,
            checkboxState: .enabled,
            size: .medium,
            arrowDirection: .right
        )

        Divider()

        CheckboxRow(
            "설명이 있는 항목 (medium)",
            checkboxVariant: .circle,
            checkboxState: .enabled,
            size: .medium,
            description: "부가 설명이 여기에 표시됩니다",
            arrowDirection: .right
        )

        Divider()

        CheckboxRow(
            "설명이 있는 항목 (small)",
            checkboxVariant: .circle,
            checkboxState: .enabled,
            size: .small,
            description: "부가 설명이 여기에 표시됩니다",
            arrowDirection: .down
        )

        Divider()

        CheckboxRow(
            "ghost variant",
            checkboxVariant: .ghost,
            checkboxState: .enabled,
            size: .medium,
            description: "ghost 스타일 체크박스",
            arrowDirection: .up
        )

        Divider()

        CheckboxRow(
            "disabled 상태",
            checkboxVariant: .circle,
            checkboxState: .disabled,
            size: .medium,
            description: "비활성화된 항목입니다"
        )
    }
    .padding(.horizontal, 16)
}
