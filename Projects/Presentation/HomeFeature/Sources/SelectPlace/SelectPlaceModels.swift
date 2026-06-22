//
//  SelectPlaceModels.swift
//  HomeFeature
//

import Foundation

import Entity

/// 담은 장소 탭 상단 멤버 가로 스크롤 리스트에 표시할 멤버.
///
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
public struct PickedPlace: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    public let category: NearbyPlaceCategory
    public let address: String
    /// 이 장소를 담은 모임원 수.
    public let pickedCount: Int

    public init(
        id: Int,
        name: String,
        category: NearbyPlaceCategory,
        address: String,
        pickedCount: Int
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.address = address
        self.pickedCount = pickedCount
    }
}

public extension SelectPlaceMember {
    init(member: PlacePickStatus.Member) {
        self.init(
            id: member.id,
            nickname: member.nickname,
            profileImageUrl: nil,
            hasPicked: member.done
        )
    }
}

public extension PickedPlace {
    init(summary: PlacePickStatus.PickedPlaceSummary) {
        self.init(
            id: summary.id,
            name: summary.name,
            category: NearbyPlaceCategory(categoryLabel: summary.categoryLabel),
            address: summary.address,
            pickedCount: 1
        )
    }

    init(place: RecommendedPlace) {
        self.init(
            id: place.id,
            name: place.name,
            category: NearbyPlaceCategory(categoryLabel: place.categoryLabel),
            address: place.address,
            pickedCount: 1
        )
    }
}

public extension NearbyPlaceCategory {
    init(categoryLabel: String) {
        let normalizedLabel = categoryLabel.replacingOccurrences(of: " ", with: "")
        let matchedCategory = Self.allCases.first {
            $0.title.replacingOccurrences(of: " ", with: "") == normalizedLabel
        }

        self = matchedCategory ?? .etc
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
        PickedPlace(id: 1, name: "감성카페", category: .cafe, address: "서울 중구 세종대로 110", pickedCount: 3),
        PickedPlace(id: 2, name: "남산다이닝", category: .koreaFood, address: "서울 용산구 소월로 322", pickedCount: 2),
        PickedPlace(id: 3, name: "경복궁디저트", category: .desert, address: "서울 종로구 사직로 161", pickedCount: 1),
        PickedPlace(id: 4, name: "명동포차", category: .bar, address: "서울 중구 명동길 14", pickedCount: 2),
        PickedPlace(id: 5, name: "광화문브런치", category: .cafe, address: "서울 종로구 종로 1", pickedCount: 1)
    ]
}
