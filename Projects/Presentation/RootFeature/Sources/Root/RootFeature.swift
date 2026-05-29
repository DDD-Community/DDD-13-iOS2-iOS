//
//  RootFeature.swift
//  RootFeature
//
//  로그인 토큰 존재 여부에 따라 Auth 플로우와 Home 메인 플로우를 분기하는 진입점
//

import AuthFlowFeature
import ComposableArchitecture
import Foundation
import HomeFeature
import Utill

@Reducer
public struct RootFeature {
    public enum Mode: Equatable {
        case auth
        case main
    }

    @ObservableState
    public struct State: Equatable {
        public var mode: Mode = .auth
        public var auth: AuthFlowFeature.State = .init()
        public var home: HomeFeature.State = .init()

        public init() {}
    }

    public enum Action {
        case onAppear
        case auth(AuthFlowFeature.Action)
        case home(HomeFeature.Action)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.auth, action: \.auth) {
            AuthFlowFeature()
        }

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                let hasToken = KeyChainManager.itemExists(key: KeyChainKey.accessToken)
                let registrationCompleted = UserDefaults.standard.object(forKey: UserDefaultsKey.registrationCompleted) as? Bool
                
                if !hasToken {
                // AccessToken이 없는 경우 -> 초기 진입한 회원
                    state.mode = .auth
                    state.auth = AuthFlowFeature.State(entryPoint: .login)
                } else if registrationCompleted == true {
                    state.mode = .main // 토큰이 있고, registrationCompleted도 true인 경우 -> 이미 SNS인증 후 회원가입까지 완료
                } else {
                    state.mode = .auth
                    state.auth = AuthFlowFeature.State(entryPoint: .terms) // 토큰은 있지만, 회원가입까지 완료하지 못한 회원 -> 약관 동의부터 다시 진행
                }
                
                return .none

            case .auth(.delegate(.authDidComplete)):
                state.mode = .main
                return .none

            case .auth:
                return .none

            case .home:
                return .none
            }
        }
    }
}
