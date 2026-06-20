//
//  SelectPlaceModels.swift
//  HomeFeature
//

import Foundation

/// 담은 장소 탭 상단 멤버 가로 스크롤 리스트에 표시할 멤버.
///
/// TODO: 담은 장소 현황 API 연동(#77) 시 실제 멤버/담기 여부로 교체한다.
public struct SelectPlaceMember: Identifiable, Equatable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageUrl: String?
    /// 해당 멤버가 후보 장소를 하나라도 담았는지 여부.
    public let hasPicked: Bool

    public init(
        id: Int,
        nickname: String,
        profileImageUrl: String?,
        hasPicked: Bool
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.hasPicked = hasPicked
    }
}

/// 모임원이 담은 후보 장소(중복 제거된 단위).
///
/// TODO: 담은 장소 현황 API 연동(#77) 시 실제 장소 모델로 교체한다.
public struct PickedPlace: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let category: NearbyPlaceCategory
    /// 이 장소를 담은 모임원 수.
    public let pickedCount: Int

    public init(
        id: Int,
        name: String,
        category: NearbyPlaceCategory,
        pickedCount: Int
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.pickedCount = pickedCount
    }
}

// MARK: - Mock

public extension SelectPlaceMember {
    static let mock: [SelectPlaceMember] = [
        SelectPlaceMember(id: 1, nickname: "김반가", profileImageUrl: nil, hasPicked: true),
        SelectPlaceMember(id: 2, nickname: "이워고", profileImageUrl: nil, hasPicked: true),
        SelectPlaceMember(id: 3, nickname: "박장소", profileImageUrl: nil, hasPicked: false),
        SelectPlaceMember(id: 4, nickname: "최투표", profileImageUrl: nil, hasPicked: true),
        SelectPlaceMember(id: 5, nickname: "정모임", profileImageUrl: nil, hasPicked: false)
    ]
}

public extension PickedPlace {
    static let mock: [PickedPlace] = [
        PickedPlace(id: 1, name: "감성카페", category: .cafe, pickedCount: 3),
        PickedPlace(id: 2, name: "남산다이닝", category: .koreaFood, pickedCount: 2),
        PickedPlace(id: 3, name: "경복궁디저트", category: .desert, pickedCount: 1),
        PickedPlace(id: 4, name: "명동포차", category: .bar, pickedCount: 2),
        PickedPlace(id: 5, name: "광화문브런치", category: .cafe, pickedCount: 1)
    ]
}
