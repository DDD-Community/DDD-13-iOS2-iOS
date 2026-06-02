//
//  Badge.swift
//  DesignSystem
//

import SwiftUI

/// 상태나 카테고리를 표시하는 작은 라벨 컴포넌트.
///
/// 좌/우 아이콘과 라벨을 수평 정렬하며, `solid` / `outline` 두 가지 스타일과
/// `small` / `medium` / `large` 세 가지 사이즈를 지원합니다.
public struct Badge: View {
    // MARK: - Properties

    private let label: String
    private let leadingIcon: Image?
    private let trailingIcon: Image?
    private let showLeadingIcon: Bool
    private let showTrailingIcon: Bool
    private let variant: BadgeVariant
    private let size: BadgeSize

    // MARK: - Init

    /// - Parameters:
    ///   - label: 뱃지에 표시할 텍스트.
    ///   - leadingIcon: 라벨 왼쪽에 표시할 아이콘. `showLeadingIcon`이 `true`일 때만 노출됩니다.
    ///   - trailingIcon: 라벨 오른쪽에 표시할 아이콘. `showTrailingIcon`이 `true`일 때만 노출됩니다.
    ///   - showLeadingIcon: 왼쪽 아이콘 노출 여부.
    ///   - showTrailingIcon: 오른쪽 아이콘 노출 여부.
    ///   - variant: 배경/테두리 스타일(`solid` / `outline`).
    ///   - size: 뱃지 사이즈(`small` / `medium` / `large`).
    public init(
        _ label: String,
        leadingIcon: Image? = nil,
        trailingIcon: Image? = nil,
        showLeadingIcon: Bool = false,
        showTrailingIcon: Bool = false,
        variant: BadgeVariant,
        size: BadgeSize
    ) {
        self.label = label
        self.leadingIcon = leadingIcon
        self.trailingIcon = trailingIcon
        self.showLeadingIcon = showLeadingIcon
        self.showTrailingIcon = showTrailingIcon
        self.variant = variant
        self.size = size
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 0) {
            if showLeadingIcon, let leadingIcon {
                IconView(image: leadingIcon, length: size.iconLength)
            }

            BangawoText(label, textStyle: size.labelTextStyle)
                .foregroundStyle(Colors.gray800)
                .padding(.horizontal, size.labelHorizontalPadding)

            if showTrailingIcon, let trailingIcon {
                IconView(image: trailingIcon, length: size.iconLength)
            }
        }
        .padding(.vertical, size.verticalPadding)
        .padding(.horizontal, size.horizontalPadding)
        .background(variant.backgroundColor)
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .strokeBorder(variant.borderColor, lineWidth: BorderWidth.borderWidth100)
        }
    }
}

// MARK: - IconView

private extension Badge {
    struct IconView: View {
        let image: Image
        let length: CGFloat

        var body: some View {
            image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: length, height: length)
                .foregroundStyle(Colors.gray500)
        }
    }
}

// MARK: - Preview

#Preview("Variants") {
    VStack(alignment: .leading, spacing: 16) {
        Badge("Solid", variant: .solid, size: .medium)
        Badge("Outline", variant: .outline, size: .medium)
    }
    .padding(24)
}

#Preview("Sizes") {
    VStack(alignment: .leading, spacing: 16) {
        Badge("Small", variant: .solid, size: .small)
        Badge("Medium", variant: .solid, size: .medium)
        Badge("Large", variant: .solid, size: .large)
    }
    .padding(24)
}

#Preview("Icons") {
    VStack(alignment: .leading, spacing: 16) {
        Badge(
            "Leading",
            leadingIcon: Image.Asset.icHeart16,
            showLeadingIcon: true,
            variant: .solid,
            size: .medium
        )
        Badge(
            "Trailing",
            trailingIcon: Image.Asset.icClose16,
            showTrailingIcon: true,
            variant: .outline,
            size: .medium
        )
        Badge(
            "Both",
            leadingIcon: Image.Asset.icHeart16,
            trailingIcon: Image.Asset.icClose16,
            showLeadingIcon: true,
            showTrailingIcon: true,
            variant: .solid,
            size: .large
        )
    }
    .padding(24)
}
