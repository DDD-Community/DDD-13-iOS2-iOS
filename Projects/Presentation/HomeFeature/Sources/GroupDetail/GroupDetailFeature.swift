//
//  GroupDetailFeature.swift
//  Presentation
//

import ComposableArchitecture
import Entity

@Reducer
public struct GroupDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let group: Group
        public var nearbyPlaceList: NearbyPlaceListSheetFeature.State = .init()
        public var selectedPlaceDetail: SelectedPlaceDetailSheetFeature.State = .mock

        public init(group: Group) {
            self.group = group
        }
    }

    public enum Action {
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
        case selectedPlaceDetail(SelectedPlaceDetailSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Scope(state: \.selectedPlaceDetail, action: \.selectedPlaceDetail) {
            SelectedPlaceDetailSheetFeature()
        }

        Reduce { _, action in
            switch action {
            case .nearbyPlaceList:
                return .none
            case .selectedPlaceDetail:
                return .none
            }
        }
    }
}
