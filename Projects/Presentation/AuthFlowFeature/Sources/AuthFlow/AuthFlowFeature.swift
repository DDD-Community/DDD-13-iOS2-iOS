//
//  AuthFlowFeature.swift
//  Presentation
//
//  Login → Terms → ProfileInput → DepartureSearch의 회원가입 네비게이션 스택
//  인증 완료 시 부모(RootFeature)에 delegate를 발행해 메인 플로우로 위임한다
//

import ComposableArchitecture
import Foundation

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

        public init(
            login: LoginFeature.State = LoginFeature.State(),
            path: StackState<Path.State> = StackState<Path.State>()
        ) {
            self.login = login
            self.path = path
        }
    }

    public enum Action {
        case login(LoginFeature.Action)
        case path(StackActionOf<Path>)
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
            case .login(.delegate(.needsSignUp)):
                state.path.append(.terms(TermsAgreementFeature.State()))
                return .none

            case .login(.delegate(.didLoginSuccess)):
                return .send(.delegate(.authDidComplete))

            case .login:
                return .none

            case let .path(.element(id: _, action: .terms(.delegate(.completeAgreement)))):
                state.path.append(.profile(ProfileInputFeature.State()))
                return .none

            case let .path(.element(id: _, action: .profile(.delegate(.proceedToDepartureSearch(name))))):
                state.path.append(.departure(DepartureSearchFeature.State(nickname: name)))
                return .none

            case .path(.element(id: _, action: .departure(.delegate(.proceedToHome)))):
                return .send(.delegate(.authDidComplete))

            case .path(.element(id: _, action: .departure(.delegate(.dismiss)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .terms(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .profile(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}
