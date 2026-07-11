//
//  PickPlaceModels.swift
//  HomeFeature
//

import Foundation

import Entity

/// 담은 장소 탭 상단 멤버 가로 스크롤 리스트에 표시할 멤버.
///
public struct PickPlaceMember: Identifiable, Equatable, Sendable {
    public let id: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let isMe: Bool
    /// 해당 멤버가 후보 장소를 하나라도 담았는지 여부.
    public let hasPicked: Bool

    public init(
        id: Int,
        nickname: String,
        profileImageUrl: String?,
        isMe: Bool = false,
        hasPicked: Bool
    ) {
        self.id = id
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.isMe = isMe
        self.hasPicked = hasPicked
    }
}

/// 모임원이 담은 후보 장소(중복 제거된 단위).
///
public struct PickedPlace: Identifiable, Equatable, Sendable {
    public let id: Int
    public let name: String
    /// 아이콘/필터/표시에 사용하는 카테고리. 매칭되지 않는 서버 라벨은 `unknown`으로 보존된다.
    public let category: PlaceCategory
    public let address: String
    /// 이 장소를 담은 모임원 수.
    public let pickedCount: Int

    public init(
        id: Int,
        name: String,
        category: PlaceCategory,
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

public extension PickPlaceMember {
    init(member: PlacePickStatus.Member) {
        self.init(
            id: member.id,
            nickname: member.nickname,
            profileImageUrl: member.profileImageUrl,
            isMe: member.isMe,
            hasPicked: member.done
        )
    }
}

public extension PickedPlace {
    init(summary: PlacePickStatus.PickedPlaceSummary) {
        self.init(
            id: summary.id,
            name: summary.name,
            category: summary.categoryLabel,
            address: summary.address,
            pickedCount: 1
        )
    }

    init(place: RecommendedPlace) {
        self.init(
            id: place.id,
            name: place.name,
            category: place.categoryLabel,
            address: place.address,
            pickedCount: 1
        )
    }
}

// MARK: - Mock

public extension PickPlaceMember {
    static let mock: [PickPlaceMember] = [
        PickPlaceMember(id: 1, nickname: "김반가", profileImageUrl: nil, isMe: true, hasPicked: true),
        PickPlaceMember(id: 2, nickname: "이워고", profileImageUrl: nil, hasPicked: true),
        PickPlaceMember(id: 3, nickname: "박장소", profileImageUrl: nil, hasPicked: false),
        PickPlaceMember(id: 4, nickname: "최투표", profileImageUrl: nil, hasPicked: true),
        PickPlaceMember(id: 5, nickname: "정모임", profileImageUrl: nil, hasPicked: false)
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

public extension StationRecommendation {
    /// 장소보기 탭 프리뷰용 더미 역/추천 장소 그룹. rank 1 역에 "중간" 배지가 노출된다.
    static let mock: [StationRecommendation] = [
        StationRecommendation(
            station: MidpointStation(
                stationId: 1,
                rank: 1,
                stationName: "신사",
                lines: "3호선",
                distanceKm: 0.4,
                latitude: 37.5163,
                longitude: 127.0204
            ),
            places: [
                RecommendedPlace(
                    rank: 1,
                    placeId: 101,
                    name: "감성카페",
                    categoryLabel: .cafe,
                    address: "서울 강남구 도산대로 1",
                    roadAddress: "서울 강남구 도산대로 1",
                    score: 4.5,
                    nearestStationId: 1,
                    latitude: 37.5163,
                    longitude: 127.0204,
                    vibe: ["아늑한"],
                    occasion: ["데이트"],
                    reservable: true,
                    hasParking: false,
                    rating: 4.5,
                    businessHours: "11:00 - 22:00",
                    holiday: "연중무휴",
                    naverUrl: ""
                ),
                RecommendedPlace(
                    rank: 2,
                    placeId: 102,
                    name: "신사다이닝",
                    categoryLabel: .koreaFood,
                    address: "서울 강남구 강남대로 2",
                    roadAddress: "서울 강남구 강남대로 2",
                    score: 4.2,
                    nearestStationId: 1,
                    latitude: 37.5165,
                    longitude: 127.0206,
                    vibe: ["활기찬"],
                    occasion: ["모임"],
                    reservable: true,
                    hasParking: true,
                    rating: 4.2,
                    businessHours: "11:00 - 22:00",
                    holiday: "연중무휴",
                    naverUrl: ""
                )
            ]
        ),
        StationRecommendation(
            station: MidpointStation(
                stationId: 2,
                rank: 2,
                stationName: "강남",
                lines: "2호선·신분당선",
                distanceKm: 0.7,
                latitude: 37.4979,
                longitude: 127.0276
            ),
            places: [
                RecommendedPlace(
                    rank: 1,
                    placeId: 201,
                    name: "강남브런치",
                    categoryLabel: .cafe,
                    address: "서울 강남구 테헤란로 1",
                    roadAddress: "서울 강남구 테헤란로 1",
                    score: 4.3,
                    nearestStationId: 2,
                    latitude: 37.4979,
                    longitude: 127.0276,
                    vibe: ["감각적인"],
                    occasion: ["브런치"],
                    reservable: false,
                    hasParking: true,
                    rating: 4.3,
                    businessHours: "10:00 - 21:00",
                    holiday: "월요일 휴무",
                    naverUrl: ""
                )
            ]
        ),
        StationRecommendation(
            station: MidpointStation(
                stationId: 3,
                rank: 3,
                stationName: "선릉",
                lines: "2호선·수인분당선",
                distanceKm: 1.1,
                latitude: 37.5045,
                longitude: 127.0492
            ),
            places: [
                RecommendedPlace(
                    rank: 1,
                    placeId: 301,
                    name: "선릉포차",
                    categoryLabel: .bar,
                    address: "서울 강남구 선릉로 1",
                    roadAddress: "서울 강남구 선릉로 1",
                    score: 4.0,
                    nearestStationId: 3,
                    latitude: 37.5045,
                    longitude: 127.0492,
                    vibe: ["편안한"],
                    occasion: ["회식"],
                    reservable: false,
                    hasParking: false,
                    rating: 4.0,
                    businessHours: "17:00 - 02:00",
                    holiday: "일요일 휴무",
                    naverUrl: ""
                )
            ]
        )
    ]
}
