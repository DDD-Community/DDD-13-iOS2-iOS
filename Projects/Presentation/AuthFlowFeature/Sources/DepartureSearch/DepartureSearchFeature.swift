//
//  DepartureSearchFeature.swift
//  Presentation
//
//  출발지 검색 화면 Feature. 검색 트리거 + 검색 바텀시트
//

import Foundation

import ComposableArchitecture

import Entity

@Reducer
public struct DepartureSearchFeature {
    @Dependency(\.registerMemberClient) private var registerMemberClient
    
    @ObservableState
    public struct State: Equatable {
        public var name: String
        public var selectedStation: Station?

        public init(name: String = "", selectedStation: Station? = nil) {
            self.name = name
            self.selectedStation = selectedStation
        }

        public var isNextEnabled: Bool { selectedStation != nil }
    }

    public enum Action {
        case backButtonTapped
        case searchTriggerTapped
        case stationSelected(Station)
        case nextButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case proceedToHome
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
                guard state.isNextEnabled else { return .none }

                return .send(.delegate(.proceedToHome))

            case .delegate:
                return .none
            }
        }
    }
}
