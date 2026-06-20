//
//  MyPlaceTabFeature.swift
//  Presentation
//

import ComposableArchitecture

@Reducer
public struct MyPlaceTabFeature {
    @ObservableState
    public struct State: Equatable {
        public var nearbyPlaceList: NearbyPlaceListSheetFeature.State = .init()

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

        // TODO: 지도 핀/장소 데이터 연동 시 로직 확장 지점
        Reduce { _, action in
            switch action {
            case .nearbyPlaceList:
                return .none
            }
        }
    }
}
