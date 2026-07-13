//
//  DateVoteFeature.swift
//  Presentation
//

import ComposableArchitecture

/// 모임 날짜 투표 화면.
// TODO: 날짜 투표 기능 구현 시 실제 State/Action 으로 교체
@Reducer
public struct DateVoteFeature {
    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    public enum Action {
        case closeTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .closeTapped:
                return .none
            }
        }
    }
}
