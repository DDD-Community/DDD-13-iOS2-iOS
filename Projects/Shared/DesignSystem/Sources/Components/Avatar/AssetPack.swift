//
//  AssetPack.swift
//  DesignSystem
//

import SwiftUI

/// 여러 아바타를 겹쳐 쌓아 보여주는 스택 컴포넌트.
///
/// `Entity` 의존을 피하기 위해 멤버 모델이 아닌 `Avatar.AvatarType` 배열을 직접 받는다.
/// 호출부에서 멤버/참여자 등을 `AvatarType`으로 변환해 전달한다.
public struct AssetPack: View {
    public enum Metric {
        public static let maxVisible: Int = 4
        static let overlap: CGFloat = 6
    }

    private let avatarTypes: [Avatar.AvatarType]

    public init(avatarTypes: [Avatar.AvatarType]) {
        self.avatarTypes = avatarTypes
    }

    public var body: some View {
        HStack(spacing: -Metric.overlap) {
            ForEach(Array(avatarTypes.prefix(Metric.maxVisible).enumerated()), id: \.offset) { index, avatarType in
                Avatar(avatarType: avatarType, size: .s24)
                    .zIndex(Double(index))
            }
        }
    }
}
