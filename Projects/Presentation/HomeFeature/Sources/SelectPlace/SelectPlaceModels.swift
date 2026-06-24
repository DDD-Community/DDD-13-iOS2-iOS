//
//  SelectPlaceModels.swift
//  HomeFeature
//

import Foundation
import SwiftUI

import DesignSystem
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
    /// 아이콘/필터에 사용하는 카테고리. 서버 라벨이 매칭되지 않으면 `nil`.
    public let category: NearbyPlaceCategory?
    /// 화면에 노출할 원본 카테고리 라벨(서버에서 받은 값 그대로).
    public let categoryLabel: String
    public let address: String
    /// 이 장소를 담은 모임원 수.
    public let pickedCount: Int

    public init(
        id: Int,
        name: String,
        category: NearbyPlaceCategory?,
        categoryLabel: String,
        address: String,
        pickedCount: Int
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.categoryLabel = categoryLabel
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
            categoryLabel: summary.categoryLabel,
            address: summary.address,
            pickedCount: 1
        )
    }

    init(place: RecommendedPlace) {
        self.init(
            id: place.id,
            name: place.name,
            category: NearbyPlaceCategory(categoryLabel: place.categoryLabel),
            categoryLabel: place.categoryLabel,
            address: place.address,
            pickedCount: 1
        )
    }
}

public extension NearbyPlaceCategory {
    init?(categoryLabel: String) {
        let normalizedLabel = categoryLabel.replacingOccurrences(of: " ", with: "")
        let matchedCategory = Self.allCases.first {
            $0.title.replacingOccurrences(of: " ", with: "") == normalizedLabel
        }

        guard let matchedCategory else { return nil }

        self = matchedCategory
    }

    /// 지도 핀 등 `assetName` 기반 API에 넘기는 카테고리별 에셋명.
    var pinAssetName: String {
        switch self {
        case .cafe: return "ic_map_pin_cafe"
        case .desert: return "ic_map_pin_dessert"
        case .buffet: return "ic_map_pin_buffet"
        case .bar: return "ic_map_pin_pub"
        case .koreaFood, .japaneseFood, .snackBar, .asianFood: return "ic_map_pin_restaurant"
        case .all, .etc: return "ic_map_pin_restaurant"
        }
    }

    var pinIcon: Image {
        Image(assetName: pinAssetName)
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
        PickedPlace(id: 1, name: "감성카페", category: .cafe, categoryLabel: "카페", address: "서울 중구 세종대로 110", pickedCount: 3),
        PickedPlace(id: 2, name: "남산다이닝", category: .koreaFood, categoryLabel: "한식", address: "서울 용산구 소월로 322", pickedCount: 2),
        PickedPlace(id: 3, name: "경복궁디저트", category: .desert, categoryLabel: "디저트", address: "서울 종로구 사직로 161", pickedCount: 1),
        PickedPlace(id: 4, name: "명동포차", category: .bar, categoryLabel: "주점", address: "서울 중구 명동길 14", pickedCount: 2),
        PickedPlace(id: 5, name: "광화문브런치", category: .cafe, categoryLabel: "카페", address: "서울 종로구 종로 1", pickedCount: 1)
    ]
}
