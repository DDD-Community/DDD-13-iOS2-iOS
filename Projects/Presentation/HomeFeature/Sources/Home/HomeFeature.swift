//
//  HomeFeature.swift
//  Presentation
//

import ComposableArchitecture
import Foundation

public struct Meeting: Identifiable, Equatable {
    public let id: UUID
    public let title: String
    public let hashtag: String
    public let status: MeetingFilter
    public let participantCount: Int

    public init(id: UUID, title: String, hashtag: String, status: MeetingFilter, participantCount: Int) {
        self.id = id
        self.title = title
        self.hashtag = hashtag
        self.status = status
        self.participantCount = participantCount
    }
}

public enum MeetingFilter: String, CaseIterable, Equatable {
    case all = "전체"
    case inProgress = "진행중"
    case confirmed = "확정"
    case ended = "종료"
}

@Reducer
public struct HomeFeature {
    @ObservableState
    public struct State: Equatable {
        public var meetings: [Meeting] = []
        public var selectedFilter: MeetingFilter = .all
        public var isFABExpanded: Bool = false

        public var filteredMeetings: [Meeting] {
            selectedFilter == .all ? meetings : meetings.filter { $0.status == selectedFilter }
        }

        public init() {}
    }

    public enum Action {
        case onAppear
        case filterTapped(MeetingFilter)
        case fabTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear: return .none

            case .filterTapped(let filter):
                state.selectedFilter = filter
                return .none

            case .fabTapped:
                state.isFABExpanded.toggle()
                return .none
            }
        }
    }
}
