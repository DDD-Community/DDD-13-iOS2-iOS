//
//  Checkbox+Tokens.swift
//  DesignSystem
//

import CoreGraphics

extension Checkbox.Size {
    var padding: CGFloat {
        switch self {
        case .small: return Spacing.spacing50
        case .medium: return Spacing.spacing100
        }
    }

    var totalSize: CGFloat {
        switch self {
        case .small: return Sizing.sizing200
        case .medium: return Sizing.sizing300
        }
    }
}
