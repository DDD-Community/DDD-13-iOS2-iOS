//
//  TopHero+Types.swift
//  DesignSystem
//

import CoreGraphics

extension TopHero {
    public enum AssetSize {
        case large
        case small
    }
}

// MARK: - AssetSize Token Mapping

extension TopHero.AssetSize {
    var length: CGFloat {
        switch self {
        case .large: return 82 // sizing750 (token pending generation)
        case .small: return Sizing.sizing700
        }
    }

    var bottomPadding: CGFloat {
        switch self {
        case .large: return Spacing.spacing200
        case .small: return Spacing.spacing100
        }
    }
}
