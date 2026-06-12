//
//  ProfileImage.swift
//  Presentation
//
//  프로필 이미지 표현 모델. 실제 이미지 데이터 또는 3D face 프리셋 식별자
//

import Foundation
import SwiftUI

public enum ProfileImage: Equatable, Sendable {
    case none
    case data(Data)
    case preset(Int)
}

public enum ProfilePreset: String, Equatable, Sendable, CaseIterable {
    case d1
    case d2
    case d3
}

public extension ProfileImage {
    var isPresent: Bool {
        switch self {
        case .none: return false
        case .data, .preset: return true
        }
    }
}

public extension ProfilePreset {
    var assetName: String {
        switch self {
        case .d1:
            return "img_avatar_3d"
        default: //일단 기본값 고정
            return "img_avatar_3d"
        }
    }
}
