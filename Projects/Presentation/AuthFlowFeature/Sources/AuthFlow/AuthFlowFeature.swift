//
//  AuthFlowFeature.swift
//  Presentation
//
//  Login → Terms → ProfileInput → DepartureSearch의 회원가입 네비게이션 스택
//  인증 완료 시 부모(RootFeature)에 delegate를 발행해 메인 플로우로 위임한다
//

import Foundation

import ComposableArchitecture

import Entity
import StationSearchFeature

@Reducer
public struct AuthFlowFeature {
    @Reducer(state: .equatable)
    public enum Path {
        case terms(TermsAgreementFeature)
        case profile(ProfileInputFeature)
        case departure(DepartureSearchFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public var login: LoginFeature.State
        public var path: StackState<Path.State>
        @Presents public var stationSearch: StationSearchSheetFeature.State?
        public var suggestedProfileName: String?

        public init(
            login: LoginFeature.State = LoginFeature.State(),
            path: StackState<Path.State> = StackState<Path.State>(),
            suggestedProfileName: String? = nil
        ) {
            self.login = login
            self.path = path
            self.stationSearch = nil
            self.suggestedProfileName = suggestedProfileName
        }
    }

    public enum Action {
        case login(LoginFeature.Action)
        case path(StackActionOf<Path>)
        case stationSearch(PresentationAction<StationSearchSheetFeature.Action>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case authDidComplete
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }

        Reduce { state, action in
            switch action {
            case let .login(.delegate(.needsSignUp(_, suggestedName))):
                state.suggestedProfileName = suggestedName
                state.path.append(.terms(TermsAgreementFeature.State()))
                return .none

            case .login(.delegate(.didLoginSuccess)):
                return .send(.delegate(.authDidComplete))

            case .login:
                return .none

            case .path(.element(id: _, action: .terms(.delegate(.completeAgreement)))):
                state.path.append(.profile(ProfileInputFeature.State(name: state.suggestedProfileName ?? "")))
                return .none

            case let .path(.element(id: _, action: .profile(.delegate(.proceedToDepartureSearch(name))))):
                state.path.append(.departure(DepartureSearchFeature.State(name: name)))
                return .none

            case .path(.element(id: _, action: .departure(.delegate(.proceedToHome)))):
                return .send(.delegate(.authDidComplete))

            case .path(.element(id: _, action: .departure(.delegate(.dismiss)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .departure(.delegate(.stationSearchRequested)))):
                state.stationSearch = StationSearchSheetFeature.State()
                return .none

            case .path(.element(id: _, action: .terms(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .profile(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case let .stationSearch(.presented(.delegate(.stationSelected(station)))):
                state.stationSearch = nil
                let departureID = state.path.ids.first { id in
                    if case .departure = state.path[id: id] { return true }
                    return false
                }
                guard let id = departureID else { return .none }
                return .run { send in
                    await send(.path(.element(id: id, action: .departure(.stationSelected(station)))))
                }

            case .stationSearch(.presented(.delegate(.dismissed))):
                state.stationSearch = nil
                return .none

            case .stationSearch:
                return .none

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$stationSearch, action: \.stationSearch) {
            StationSearchSheetFeature()
        }
    }
}
