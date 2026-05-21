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
        @Presents public var creationSheet: MeetingCreationSheetFeature.State?

        public var filteredMeetings: [Meeting] {
            selectedFilter == .all ? meetings : meetings.filter { $0.status == selectedFilter }
        }

        public init() {}
    }

    public enum Action {
        case onAppear
        case filterTapped(MeetingFilter)
        case fabTapped
        case createMeetingRowTapped
        case fabCreateMeetingTapped
        case fabJoinMeetingTapped
        case creationSheet(PresentationAction<MeetingCreationSheetFeature.Action>)
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

            case .createMeetingRowTapped:
                state.creationSheet = MeetingCreationSheetFeature.State()
                return .none

            case .fabCreateMeetingTapped:
                state.isFABExpanded = false
                state.creationSheet = MeetingCreationSheetFeature.State()
                return .none

            case .fabJoinMeetingTapped:
                state.isFABExpanded = false
                return .none

            case let .creationSheet(.presented(.delegate(.meetingCreated(meeting)))):
                state.meetings.append(meeting)
                state.creationSheet = nil
                return .none

            case .creationSheet(.presented(.delegate(.dismissed))):
                state.creationSheet = nil
                return .none

            case .creationSheet:
                return .none
            }
        }
        .ifLet(\.$creationSheet, action: \.creationSheet) {
            MeetingCreationSheetFeature()
        }
    }
}
