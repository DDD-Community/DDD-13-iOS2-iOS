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
                #if DEBUG
                state.mode = .auth // 테스트용
                #else
                state.mode = hasToken ? .main : .auth
                #endif
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
