//
//  PlaceVoteParticipationFeature.swift
//  Presentation
//

import ComposableArchitecture

/// 약속 장소 투표 참여 화면.
// TODO: 장소 투표 참여 기능 구현 시 실제 State/Action 으로 교체
@Reducer
public struct PlaceVoteParticipationFeature {
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
