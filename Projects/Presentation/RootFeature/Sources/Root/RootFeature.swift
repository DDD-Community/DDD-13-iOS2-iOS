//
//  RootFeature.swift
//  RootFeature
//
//  로그인 토큰 존재 여부에 따라 Auth 플로우와 Home 메인 플로우를 분기하는 진입점
//

import Foundation

import ComposableArchitecture

import AuthFlowFeature
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
        public var auth: AuthFlowFeature.State = AuthFlowFeature.State()
        public var home: HomeFeature.State = HomeFeature.State()

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
                state.mode = hasToken ? .main : .auth
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
