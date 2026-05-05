//
//  TempLoginFeature.swift
//  Presentation
//
//  소셜 로그인 머지 전, 회원가입 플로우를 검증하기 위한 임시 진입 화면
//

import ComposableArchitecture
import Foundation

@Reducer
public struct TempLoginFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case signUpButtonTapped
        case enterMainButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case startSignUp
            case enterMain
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .signUpButtonTapped: return .send(.delegate(.startSignUp))
            case .enterMainButtonTapped: return .send(.delegate(.enterMain))
            case .delegate: return .none
            }
        }
    }
}
