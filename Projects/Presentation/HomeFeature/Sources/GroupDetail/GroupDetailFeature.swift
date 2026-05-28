//
//  GroupDetailFeature.swift
//  Presentation
//

import ComposableArchitecture
import Entity

@Reducer
public struct GroupDetailFeature {
    @ObservableState
    public struct State: Equatable {
        public let group: Group

        public init(group: Group) {
            self.group = group
        }
    }

    public enum Action {}

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, _ in .none }
    }
}
