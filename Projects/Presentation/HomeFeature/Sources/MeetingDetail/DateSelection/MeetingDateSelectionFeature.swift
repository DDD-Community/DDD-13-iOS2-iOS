//
//  MeetingDateSelectionFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import Utill

@Reducer
public struct MeetingDateSelectionFeature {
    @ObservableState
    public struct State: Equatable {
        var selectedTab: MeetingDateSelectionTab = .date
        var dateDesignation = DateDesignationFeature.State()
        var periodVote = PeriodVoteFeature.State()

        var isNextEnabled: Bool {
            switch selectedTab {
            case .date:
                return dateDesignation.selectedDateText.isEmpty == false
            case .periodVote:
                return periodVote.selectedDateText.isEmpty == false && periodVote.deadlineText.isEmpty == false
            }
        }

        public init() {}
    }

    public enum Action {
        case tabSelected(MeetingDateSelectionTab)
        case dateDesignation(DateDesignationFeature.Action)
        case periodVote(PeriodVoteFeature.Action)
        case nextButtonTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.dateDesignation, action: \.dateDesignation) {
            DateDesignationFeature()
        }

        Scope(state: \.periodVote, action: \.periodVote) {
            PeriodVoteFeature()
        }

        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case .nextButtonTapped:
                Log.debug("날짜 선택 다음 클릭")
                return .none

            case .dateDesignation:
                return .none

            case .periodVote:
                return .none
            }
        }
    }
}

@Reducer
public struct DateDesignationFeature {
    @ObservableState
    public struct State: Equatable {
        var selectedDateText = ""

        public init() {}
    }

    public enum Action {
        case dateFieldTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .dateFieldTapped:
                Log.debug("날짜 지정 날짜 선택하기 클릭")
                return .none
            }
        }
    }
}

@Reducer
public struct PeriodVoteFeature {
    @ObservableState
    public struct State: Equatable {
        var selectedDateText = ""
        var deadlineText = ""

        public init() {}
    }

    public enum Action {
        case dateFieldTapped
        case deadlineFieldTapped
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .dateFieldTapped:
                Log.debug("기간 투표 날짜 선택하기 클릭")
                return .none

            case .deadlineFieldTapped:
                Log.debug("투표 마감 시간 선택하기 클릭")
                return .none
            }
        }
    }
}

public enum MeetingDateSelectionTab: String, CaseIterable {
    case date = "날짜 지정"
    case periodVote = "기간 투표"
}
