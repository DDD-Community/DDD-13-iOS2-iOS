//
//  DepartureSearchFeature.swift
//  Presentation
//
//  출발지 검색 화면 Feature. 검색 트리거 + 검색 바텀시트
//

import ComposableArchitecture
import Entity
import Foundation
import Utill

@Reducer
public struct DepartureSearchFeature {
    @ObservableState
    public struct State: Equatable {
        public var selectedStation: Station?

        public init(selectedStation: Station? = nil) {
            self.selectedStation = selectedStation
        }

        public var isNextEnabled: Bool {
            selectedStation != nil
        }
    }

    public enum Action {
        case backButtonTapped
        case searchTriggerTapped
        case stationSelected(Station)
        case nextButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case registerRequested(station: Station)
            case dismiss
            case stationSearchRequested
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.dismiss))

            case .searchTriggerTapped:
                return .send(.delegate(.stationSearchRequested))

            case let .stationSelected(station):
                state.selectedStation = station
                return .none

            case .nextButtonTapped:
                guard let station = state.selectedStation else { return .none }
                
                return .send(.delegate(.registerRequested(station: station)))

            case .delegate:
                return .none
            }
        }
    }
}
