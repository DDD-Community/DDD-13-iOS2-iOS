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
    private var description: String?
    private var arrowDirection: ArrowDirection?

    // MARK: - Init

    public init(
        _ title: String,
        checkboxVariant: Checkbox.Variant = .circle,
        checkboxState: Checkbox.State = .enabled,
        size: Size = .medium
    ) {
        self.title = title
        self.checkboxVariant = checkboxVariant
        self.checkboxState = checkboxState
        self.size = size
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Checkbox(variant: checkboxVariant, state: checkboxState, size: size.checkboxSize)

            LabelArea(title: title, description: description, size: size)

            if let direction = arrowDirection {
                ArrowIcon(direction: direction)
            }
        }
        .padding(.vertical, Spacing.spacing250)
        .padding(.horizontal, Spacing.spacing200)
    }

    // MARK: - Modifiers

    public func description(_ text: String) -> Self {
        var copy = self
        copy.description = text
        return copy
    }

    public func arrow(_ direction: ArrowDirection) -> Self {
        var copy = self
        copy.arrowDirection = direction
        return copy
    }
}

// MARK: - LabelArea

private extension CheckboxRow {
    struct LabelArea: View {
        let title: String
        let description: String?
        let size: Size

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText(title, textStyle: size.titleFont)
                    .foregroundStyle(Colors.gray800)
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
            case .right: Image.Asset.icArrowRight24
            case .down: Image.Asset.icArrowDown24
            case .up: Image.Asset.icArrowUp24
            }
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        CheckboxRow("제목만 있는 항목", size: .medium)
            .arrow(.right)

        Divider()

        CheckboxRow("설명이 있는 항목 (medium)", size: .medium)
            .description("부가 설명이 여기에 표시됩니다")
            .arrow(.right)

        Divider()

        CheckboxRow("설명이 있는 항목 (small)", size: .small)
            .description("부가 설명이 여기에 표시됩니다")
            .arrow(.down)

        Divider()

        CheckboxRow("ghost variant", checkboxVariant: .ghost, size: .medium)
            .description("ghost 스타일 체크박스")
            .arrow(.up)

        Divider()

        CheckboxRow("disabled 상태", checkboxState: .disabled, size: .medium)
            .description("비활성화된 항목입니다")
    }
    .padding(.horizontal, 16)
}
