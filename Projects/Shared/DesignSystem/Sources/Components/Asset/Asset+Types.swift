//
//  Asset+Types.swift
//  DesignSystem
//

import SwiftUI

extension Asset {
    public enum AssetType {
        case d3(D3)
        case image(Image)
    }

    /// `.d3` 케이스에서 사용하는 3D 일러스트 에셋.
    /// 이미지 파일을 직접 전달하지 않고 케이스로 지정한다.
    public enum D3: Sendable {
        case agreement
        case avatarPlaceholder
        case departure
        case login
        case face01
        case face02
        case face03
        case face04
        case face05
        case face06
        case face07
        case face08
        case face09
        case face10
        case groupDetail

        /// 프로필 선택 그리드에 노출되는 3D 얼굴 (노출 순서)
        public static let profileFaces: [D3] = [
            .face01, .face02, .face03, .face04, .face05,
            .face06, .face07, .face08, .face09, .face10
        ]
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

// MARK: - D3 Asset Mapping

extension Asset.D3 {
    var image: Image {
        switch self {
        case .agreement: return Image.Asset.imgAgreement3d
        case .avatarPlaceholder: return Image.Asset.imgAvatarPlaceholder
        case .departure: return Image.Asset.imgDeparture3d
        case .login: return Image.Asset.imgLogin3d
        case .face01: return Image.Asset.imgFace3d01
        case .face02: return Image.Asset.imgFace3d02
        case .face03: return Image.Asset.imgFace3d03
        case .face04: return Image.Asset.imgFace3d04
        case .face05: return Image.Asset.imgFace3d05
        case .face06: return Image.Asset.imgFace3d06
        case .face07: return Image.Asset.imgFace3d07
        case .face08: return Image.Asset.imgFace3d08
        case .face09: return Image.Asset.imgFace3d09
        case .face10: return Image.Asset.imgFace3d10
        case .groupDetail: return Image.Asset.imgGroupDetail3d
        }
    }

    @MainActor
    public var profileSnapshot: UIImage {
        image.snapshot()
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

    var selectionCheckBoxLength: CGFloat {
        switch self {
        case .s32: return 12
        case .s40: return 16
        case .s48: return 18
        case .s64: return 24
        case .s82: return 30
        case .s104: return 40
        case .s124: return 48
        case .s280: return 100
        }
    }
}
