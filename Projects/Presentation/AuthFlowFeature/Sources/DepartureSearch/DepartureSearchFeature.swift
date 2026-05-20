//
//  DepartureSearchFeature.swift
//  Presentation
//
//  출발지 검색 화면 Feature. 검색 트리거 + 검색 바텀시트
//

import ComposableArchitecture
import Entity
import Foundation

@Reducer
public struct DepartureSearchFeature {
    @ObservableState
    public struct State: Equatable {
        public var name: String
        public var selectedStation: Station?
        @Presents public var searchSheet: StationSearchSheetFeature.State?

        public init(name: String = "", selectedStation: Station? = nil) {
            self.name = name
            self.selectedStation = selectedStation
        }

        public var isNextEnabled: Bool { selectedStation != nil }
    }

    public enum Action {
        case backButtonTapped
        case searchTriggerTapped
        case searchSheet(PresentationAction<StationSearchSheetFeature.Action>)
        case nextButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case proceedToHome
            case dismiss
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .backButtonTapped:
                return .send(.delegate(.dismiss))

            case .searchTriggerTapped:
                state.searchSheet = StationSearchSheetFeature.State()
                return .none

            case let .searchSheet(.presented(.delegate(.stationSelected(station)))):
                state.selectedStation = station
                state.searchSheet = nil
                return .none

            case .searchSheet(.presented(.delegate(.dismissed))):
                state.searchSheet = nil
                return .none

            case .searchSheet:
                return .none

            case .nextButtonTapped:
                guard state.isNextEnabled else { return .none }

                return .send(.delegate(.proceedToHome))

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$searchSheet, action: \.searchSheet) {
            StationSearchSheetFeature()
        }
    }
}
