//
//  Badge+Tokens.swift
//  DesignSystem
//

import SwiftUI

extension BadgeSize {
    var verticalPadding: CGFloat {
        switch self {
        case .small: return Spacing.spacing100
        case .medium: return Spacing.spacing150
        case .large: return Spacing.spacing200
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return Spacing.spacing150
        case .medium: return Spacing.spacing200
        case .large: return Spacing.spacing250
        }
    }

    var labelHorizontalPadding: CGFloat {
        switch self {
        case .small: return Spacing.spacing50
        case .medium: return Spacing.spacing100
        case .large: return Spacing.spacing150
        }
    }

    var iconLength: CGFloat {
        switch self {
        case .small, .medium: return Sizing.sizing100
        case .large: return Sizing.sizing150
        }
    }

    var labelTextStyle: CustomSizeFont {
        switch self {
        case .small: return .labelXSmall
        case .medium: return .labelSmall
        case .large: return .labelMedium
        }
    }
}

extension BadgeVariant {
    var backgroundColor: Color {
        switch self {
        case .solid: return Colors.gray100
        case .outline: return .clear
        }
    }

    var borderColor: Color {
        switch self {
        case .solid: return Colors.gray50
        case .outline: return Colors.gray300
        }
    }
}
