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

public extension ProfileImage {
    var isPresent: Bool {
        switch self {
        case .none: return false
        case .data, .preset: return true
        }
    }
}
