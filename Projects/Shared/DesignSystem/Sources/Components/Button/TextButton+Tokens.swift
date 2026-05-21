//
//  TextButton+Tokens.swift
//  DesignSystem
//

import CoreGraphics

// MARK: - Size Token Mapping

extension TextButton.Size {
    var font: CustomSizeFont {
        switch self {
        case .large: return .labelLarge
        case .medium: return .labelMedium
        case .small: return .labelSmall
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .large, .medium: return 24
        case .small: return 22
        }
    }
}
