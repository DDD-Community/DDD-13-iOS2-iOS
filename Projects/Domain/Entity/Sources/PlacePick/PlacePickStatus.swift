//
//  PlacePickStatus.swift
//  Entity
//

import Foundation

/// 모임의 장소 담기 현황. 모임원별 담기 완료 여부와 현재 사용자가 담은 장소 목록을 담는다.
public struct PlacePickStatus: Equatable, Sendable {
    public let members: [Member]
    public let myPicks: [PickedPlaceSummary]

    public init(members: [Member], myPicks: [PickedPlaceSummary]) {
        self.members = members
        self.myPicks = myPicks
    }

    /// 모임원과 담기 완료 여부.
    public struct Member: Equatable, Sendable, Identifiable {
        public let memberId: Int
        public let nickname: String
        public let done: Bool

        public var id: Int { memberId }

        public init(memberId: Int, nickname: String, done: Bool) {
            self.memberId = memberId
            self.nickname = nickname
            self.done = done
        }
    }

    /// 현재 사용자가 담은 장소 요약 정보.
    public struct PickedPlaceSummary: Equatable, Sendable, Identifiable {
        public let placeId: Int
        public let name: String
        public let categoryLabel: PlaceCategory
        public let address: String

        public var id: Int { placeId }

        public init(placeId: Int, name: String, categoryLabel: PlaceCategory, address: String) {
            self.placeId = placeId
            self.name = name
            self.categoryLabel = categoryLabel
            self.address = address
        }
    }
}
