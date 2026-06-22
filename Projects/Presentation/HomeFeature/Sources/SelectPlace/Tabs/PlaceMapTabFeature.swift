//
//  PlaceMapTabFeature.swift
//  HomeFeature
//

import ComposableArchitecture

@Reducer
public struct PlaceMapTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var nearbyPlaceList = NearbyPlaceListSheetFeature.State()

        public init() {}
    }

    public enum Action {
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Reduce { _, action in
            switch action {
            case .nearbyPlaceList:
                return .none
            }
        }
    }
}
