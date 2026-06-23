//
//  MeetingDateSelectionFeature.swift
//  HomeFeature
//

import Foundation

import ComposableArchitecture
import CoreDependencies
import Utill

@Reducer
public struct MeetingDateSelectionFeature {
    @Dependency(\.groupClient) private var groupClient

    @ObservableState
    public struct State: Equatable {
        let meetingId: Int
        var selectedTab: MeetingDateSelectionTab = .date
        var dateDesignation = DateDesignationFeature.State()
        var periodVote = PeriodVoteFeature.State()
        var isSubmitting = false

        var isNextEnabled: Bool {
            guard !isSubmitting else { return false }

            switch selectedTab {
            case .date:
                return dateDesignation.selectedDateRequestText != nil
            case .periodVote:
                return periodVote.selectedDateText.isEmpty == false && periodVote.deadlineText.isEmpty == false
            }
        }

        public init(meetingId: Int) {
            self.meetingId = meetingId
        }
    }

    public enum Action {
        case tabSelected(MeetingDateSelectionTab)
        case dateDesignation(DateDesignationFeature.Action)
        case periodVote(PeriodVoteFeature.Action)
        case delegate(Delegate)
        case nextButtonTapped
        case hostPickMeetingDateResponse(Result<Void, Error>)

        public enum Delegate: Equatable {
            case datePickerRequested(MeetingDatePickerMode, meetingId: Int)
            case dateSelectionCompleted(meetingId: Int)
        }
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
                switch state.selectedTab {
                case .date:
                    guard let selectedDateRequestText = state.dateDesignation.selectedDateRequestText else { return .none }

                    let meetingId = state.meetingId
                    let groupClient = groupClient
                    state.isSubmitting = true

                    return .run { send in
                        do {
                            try await groupClient.hostPickMeetingDate(meetingId, selectedDateRequestText)
                            await send(.hostPickMeetingDateResponse(.success(())))
                        } catch {
                            await send(.hostPickMeetingDateResponse(.failure(error)))
                        }
                    }

                case .periodVote:
                    Log.debug("기간 투표 날짜: \(state.periodVote.selectedDateText)")
                    Log.debug("기간 투표 마감 시간: \(state.periodVote.deadlineText)")
                    return .none
                }

            case .hostPickMeetingDateResponse(.success):
                state.isSubmitting = false
                Log.debug("날짜 지정 API 성공")
                return .send(.delegate(.dateSelectionCompleted(meetingId: state.meetingId)))

            case let .hostPickMeetingDateResponse(.failure(error)):
                state.isSubmitting = false
                Log.error("날짜 지정 API 실패: \(error.localizedDescription)")
                return .none

            case .dateDesignation(.dateFieldTapped):
                return .send(.delegate(.datePickerRequested(.single, meetingId: state.meetingId)))

            case .periodVote(.dateFieldTapped):
                return .send(.delegate(.datePickerRequested(.range, meetingId: state.meetingId)))

            case .dateDesignation:
                return .none

            case .periodVote:
                return .none

            case .delegate:
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
        var selectedDateRequestText: String?

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

public enum VoteDeadlineOption: String, CaseIterable, Equatable, Identifiable {
    case oneDay = "하루 뒤 마감"
    case threeDays = "3일 뒤 마감"
    case sevenDays = "7일 뒤 마감"
    case custom = "사용자 설정"

    public var id: String { rawValue }
}

@Reducer
public struct PeriodVoteFeature {
    @ObservableState
    public struct State: Equatable {
        var selectedDateText = ""
        var deadlineText = ""
        var selectedDeadlineOption: VoteDeadlineOption?
        var deadlineDraft: VoteDeadlineOption?
        var isDeadlineSheetPresented = false

        var isDeadlineDraftValid: Bool {
            deadlineDraft != nil
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case dateFieldTapped
        case deadlineFieldTapped
        case deadlineSheetDismissed
        case deadlineOptionSelected(VoteDeadlineOption)
        case deadlineConfirmed
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .dateFieldTapped:
                return .none

            case .deadlineFieldTapped:
                state.deadlineDraft = state.selectedDeadlineOption
                state.isDeadlineSheetPresented = true
                return .none

            case .deadlineSheetDismissed:
                state.deadlineDraft = state.selectedDeadlineOption
                state.isDeadlineSheetPresented = false
                return .none

            case let .deadlineOptionSelected(option):
                state.deadlineDraft = option
                return .none

            case .deadlineConfirmed:
                guard let deadlineDraft = state.deadlineDraft else { return .none }
                state.selectedDeadlineOption = deadlineDraft
                state.deadlineText = deadlineDraft.rawValue
                state.isDeadlineSheetPresented = false
                return .none
            }
        }
    }
}

public enum MeetingDateSelectionTab: String, CaseIterable {
    case date = "날짜 지정"
    case periodVote = "기간 투표"
}

public enum MeetingDatePickerMode: Equatable {
    case single
    case range
}

