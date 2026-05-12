//
//  HomeFeature.swift
//  Presentation
//
//  회원가입 완료 후 진입할 임시 메인 화면
//

import ComposableArchitecture
import Foundation

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case onAppear
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear: return .none
            }
        }
    }
}
