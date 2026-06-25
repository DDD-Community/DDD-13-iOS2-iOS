//
//  PickedPlaceTabFeature.swift
//  HomeFeature
//

import ComposableArchitecture

import Entity

@Reducer
public struct PickedPlaceTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var members: [PickPlaceMember]
        public var pickedPlaces: [PickedPlace]
        public var selectedFilterCategory: PlaceCategory = .all
        /// 현재 사용자가 호스트인지 여부. 하단 "투표 생성" 버튼 노출 분기에 사용한다.
        public let isHost: Bool

        public init(
            members: [PickPlaceMember] = PickPlaceMember.mock,
            pickedPlaces: [PickedPlace] = PickedPlace.mock,
            isHost: Bool = false
        ) {
            self.members = members
            self.pickedPlaces = pickedPlaces
            self.isHost = isHost
        }

        public var isPickedPlaceEmpty: Bool { pickedPlaces.isEmpty }

        /// 선택된 카테고리 필터로 거른 담은 장소 리스트.
        public var filteredPickedPlaces: [PickedPlace] {
            guard selectedFilterCategory != .all else { return pickedPlaces }

            return pickedPlaces.filter { $0.category == selectedFilterCategory }
        }

        /// "전체"부터 시작해, 담은 장소에 실제 등장하는 카테고리만 개수와 함께 나열한 필터 목록.
        public var categoryFilters: [CategoryFilter] {
            let all = CategoryFilter(category: .all, count: pickedPlaces.count)
            let present = PlaceCategory.allCases
                .filter { $0 != .all }
                .compactMap { category -> CategoryFilter? in
                    let count = pickedPlaces.filter { $0.category == category }.count
                    return count > 0 ? CategoryFilter(category: category, count: count) : nil
                }
            return [all] + present
        }
    }

    /// 담은 장소 탭 카테고리 필터 칩 한 개.
    public struct CategoryFilter: Equatable, Identifiable, Sendable {
        public let category: PlaceCategory
        public let count: Int

        public var id: PlaceCategory { category }
        public var label: String { "\(category.title) \(count)" }
    }

    public enum Action {
        case categoryFilterSelected(PlaceCategory)
        case goPickPlaceTapped
        case createVoteTapped
        case delegate(Delegate)
    }

    public enum Delegate: Equatable {
        case goPickPlaceTapped
        case createVoteTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .categoryFilterSelected(category):
                state.selectedFilterCategory = category
                return .none

            case .goPickPlaceTapped:
                return .send(.delegate(.goPickPlaceTapped))

            case .createVoteTapped:
                return .send(.delegate(.createVoteTapped))

            case .delegate:
                return .none
            }
        }
    }
}
