//
//  MeetingDetailFeature.swift
//  Presentation
//

import ComposableArchitecture

@Reducer
public struct MeetingDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let meeting: Meeting

        public init(meeting: Meeting) {
            self.meeting = meeting
        }
    }

    public enum Action {}

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}
