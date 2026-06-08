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

        public init(group: Group) {
            self.group = group
        }
    }

    public enum Action {
        case nearbyPlaceList(NearbyPlaceListSheetFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.nearbyPlaceList, action: \.nearbyPlaceList) {
            NearbyPlaceListSheetFeature()
        }

        Reduce { state, action in
            switch action {
            case .nearbyPlaceList:
                return .none
            }
        }
    }
}
