//
//  Asset+Types.swift
//  DesignSystem
//

import SwiftUI

extension Asset {
    public enum AssetType {
        case d3(Image)
        case image(Image)
    }

    public enum Size {
        case s32
        case s40
        case s48
        case s64
        case s82
        case s104
        case s124
        case s280
    }
}

// MARK: - Size Token Mapping

extension Asset.Size {
    var length: CGFloat {
        switch self {
        case .s32: return 32
        case .s40: return 40
        case .s48: return 48
        case .s64: return 64
        case .s82: return 82
        case .s104: return 104
        case .s124: return 124
        case .s280: return 280
        }
    }
}
