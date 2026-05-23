//
//  Avatar+Types.swift
//  DesignSystem
//

import SwiftUI

extension Avatar {
    public enum AvatarType {
        case d3
        case image(URL)
        case placeholder
        case localImage(Image)
    }

    public enum IconType {
        case host
        case pin
        case edit(action: () -> Void)
        case star
    }

    public enum Size: CaseIterable {
        case s24
        case s32
        case s40
        case s56
        case s104
        case s124
    }
}

// MARK: - Size Token Mapping

extension Avatar.Size {
    public var length: CGFloat {
        switch self {
        case .s24: return 24
        case .s32: return 32
        case .s40: return 40
        case .s56: return 56
        case .s104: return 104
        case .s124: return 124
        }
    }

    var backgroundPadding: CGFloat {
        switch self {
        case .s24: return 2
        case .s32, .s40: return 4
        case .s56: return 6
        case .s104, .s124: return 8
        }
    }

    var iconCircleSize: CGFloat {
        switch self {
        case .s24: return 8
        case .s32: return 12
        case .s40: return 16
        case .s56: return 20
        case .s104, .s124: return 32
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .s24: return 4.5
        case .s32: return 6.75
        case .s40: return 9
        case .s56: return 11.25
        case .s104, .s124: return 18
        }
    }

    var iconBorderWidth: CGFloat {
        switch self {
        case .s24: return 0.5
        case .s32: return 0.75
        case .s40: return 1
        case .s56: return 1.25
        case .s104, .s124: return 2
        }
    }
}

// MARK: - IconType Token Mapping

extension Avatar.IconType {
    var backgroundColor: Color {
        switch self {
        case .host: return Colors.orange500
        case .pin: return Colors.green500
        case .edit: return Colors.gray800
        case .star: return Colors.blue500
        }
    }

    var icon: Image {
        switch self {
        case .host: return Image.Asset.icCrown24
        case .pin: return Image.Asset.icPin24
        case .edit: return Image.Asset.icEdit24
        case .star: return Image.Asset.icStar24
        }
    }
}
