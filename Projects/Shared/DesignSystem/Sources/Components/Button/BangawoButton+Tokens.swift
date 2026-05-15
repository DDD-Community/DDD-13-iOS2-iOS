//
//  BangawoButton+Tokens.swift
//  DesignSystem
//

import SwiftUI

// MARK: - Variant Token Mapping

extension BangawoButton.Variant {
    var enabledBackground: Color {
        switch self {
        case .weak: return Colors.grayAlpha200
        case .solid: return Colors.grayAlpha800
        }
    }

    var pressedBackground: Color {
        switch self {
        case .weak: return Colors.grayAlpha100
        case .solid: return Colors.grayAlpha800
        }
    }

    var disabledBackground: Color {
        Colors.gray200
    }

    // TODO: 디자인 명세 확정 시 컬러 교체 필요
    var indicatorColor: Color {
        switch self {
        case .weak: return Colors.grayAlpha900
        case .solid: return Colors.gray00
        }
    }
}

// MARK: - Size Token Mapping

extension BangawoButton.Size {
    var font: CustomSizeFont {
        switch self {
        case .xsmall: return .labelXSmall
        case .small: return .labelSmall
        case .medium: return .labelMedium
        case .large: return .labelLarge
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .xsmall: return BorderRadius.borderRadiusFull
        case .small: return BorderRadius.borderRadius225
        case .medium: return BorderRadius.borderRadius250
        case .large: return BorderRadius.borderRadius300
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .xsmall: return Spacing.spacing150
        case .small: return Spacing.spacing200
        case .medium: return Spacing.spacing225
        case .large: return Spacing.spacing300
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .xsmall: return Spacing.spacing200
        case .small: return Spacing.spacing250
        case .medium: return Spacing.spacing300
        case .large: return Spacing.spacing400
        }
    }

    var minHeight: CGFloat {
        switch self {
        case .xsmall: return Sizing.sizing200
        case .small: return Sizing.sizing325
        case .medium: return Sizing.sizing425
        case .large: return Spacing.spacing800
        }
    }
}
