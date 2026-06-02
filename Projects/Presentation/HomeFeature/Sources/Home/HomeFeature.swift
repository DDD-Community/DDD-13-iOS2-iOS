//
//  HomeFeature.swift
//  Presentation
//

import Foundation

import ComposableArchitecture
import Entity

@Reducer
public struct HomeFeature {
    @Reducer(state: .equatable)
    public enum Path {
        case detail(MeetingDetailFeature)
    }

    @ObservableState
    public struct State: Equatable {
        public var meetings: [Meeting] = []
        public var selectedFilter: MeetingFilter = .all
        @Presents public var creationSheet: MeetingCreationSheetFeature.State?
        public var path: StackState<Path.State> = StackState<Path.State>()

        public var filteredMeetings: [Meeting] {
            selectedFilter == .all ? meetings : meetings.filter { $0.status == selectedFilter }
        }

        public init() {}
    }

    public enum Action {
        case onAppear
        case filterTapped(MeetingFilter)
        case createMeetingRowTapped
        case fabCreateMeetingTapped
        case fabJoinMeetingTapped
        case meetingCardTapped(Meeting)
        case creationSheet(PresentationAction<MeetingCreationSheetFeature.Action>)
        case path(StackActionOf<Path>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear: return .none

            case .filterTapped(let filter):
                state.selectedFilter = filter
                return .none

            case .createMeetingRowTapped:
                state.creationSheet = MeetingCreationSheetFeature.State()
                return .none

            case .fabCreateMeetingTapped:
                state.creationSheet = MeetingCreationSheetFeature.State()
                return .none

            case .fabJoinMeetingTapped:
                return .none

            case .meetingCardTapped(let meeting):
                state.path.append(.detail(MeetingDetailFeature.State(meeting: meeting)))
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

            case .path:
                return .none
            }
        }
        .ifLet(\.$creationSheet, action: \.creationSheet) {
            MeetingCreationSheetFeature()
        }
        .forEach(\.path, action: \.path)
    }
}
