//
//  StationSearchSheetFeature.swift
//  Presentation
//
//  Kakao Local 키워드 검색 바텀시트 Feature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Foundation
import Utill

@Reducer
public struct StationSearchSheetFeature: Sendable {
    public enum CancelID: Hashable, Sendable { case search }

    @ObservableState
    public struct State: Equatable {
        public var keyword: String
        public var stations: [Station]
        public var isLoading: Bool

        public init(keyword: String = "", stations: [Station] = [], isLoading: Bool = false) {
            self.keyword = keyword
            self.stations = stations
            self.isLoading = isLoading
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case keywordChanged(String)
        case stationsResponse(Result<[Station], Error>)
        case stationTapped(Station)
        case closeButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case stationSelected(Station)
            case dismissed
        }
    }

    @Dependency(\.searchStationsClient) var searchStationsClient
    @Dependency(\.continuousClock) var clock

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.keyword):
                return .send(.keywordChanged(state.keyword))

            case .binding:
                return .none

            case let .keywordChanged(keyword):
                let trimmed = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    state.stations = []
                    state.isLoading = false
                    return .cancel(id: CancelID.search)
                }

                state.isLoading = true
                return .run { [searchStationsClient, clock] send in
                    try await clock.sleep(for: .milliseconds(300))
                    await send(.stationsResponse(Result { try await searchStationsClient.searchStations(keyword: trimmed) }))
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case let .stationsResponse(.success(stations)):
                state.isLoading = false
                state.stations = stations
                return .none

            case let .stationsResponse(.failure(error)):
                state.isLoading = false
                state.stations = []
                Log.error("출발지 검색 실패: \(error)")
                return .none

            case let .stationTapped(station):
                return .send(.delegate(.stationSelected(station)))

            case .closeButtonTapped:
                return .send(.delegate(.dismissed))

            case .delegate:
                return .none
            }
        }
    }
}
