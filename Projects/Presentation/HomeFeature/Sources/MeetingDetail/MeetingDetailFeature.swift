//
//  MeetingDetailFeature.swift
//  Presentation
//

import ComposableArchitecture
import Entity

@Reducer
public struct MeetingDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let meeting: Meeting
        public var nearbyPlaceList: NearbyPlaceListSheetFeature.State = .init()

        public init(meeting: Meeting) {
            self.meeting = meeting
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
