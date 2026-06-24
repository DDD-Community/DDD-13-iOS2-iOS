//
//  MeetingDateSelectionFeature.swift
//  HomeFeature
//

import Foundation

import ComposableArchitecture
import CoreDependencies
import Entity
import Utill

@Reducer
public struct MeetingDateSelectionFeature {
    @Dependency(\.groupClient) private var groupClient
    @Dependency(\.voteClient) private var voteClient
    @Dependency(\.calendar) private var calendar

    @ObservableState
    public struct State: Equatable {
        let meetingId: Int
        var selectedTab: MeetingDateSelectionTab = .date
        var dateDesignation = DateDesignationFeature.State()
        var periodVote = PeriodVoteFeature.State()
        var isSubmitting = false
        @Presents var destination: Destination.State?

        var isNextEnabled: Bool {
            guard !isSubmitting else { return false }

            switch selectedTab {
            case .date:
                return dateDesignation.selectedDateRequestText != nil
            case .periodVote:
                return periodVote.selectedDateText.isEmpty == false
                    && periodVote.candidateDates.isEmpty == false
                    && periodVote.selectedDeadlineOption?.durationDays != nil
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
        case destination(PresentationAction<Destination.Action>)
        case nextButtonTapped
        case hostPickMeetingDateResponse(Result<Void, Error>)
        case startDateVoteResponse(Result<Void, Error>)

        public enum Delegate: Equatable {
            case dateSelectionCompleted(meetingId: Int, dateVoteStatus: GroupDateVoteStatus)
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
                    guard let durationDays = state.periodVote.selectedDeadlineOption?.durationDays else {
                        Log.debug("사용자 설정 마감 시간은 아직 지원하지 않습니다.")
                        return .none
                    }
                    guard state.periodVote.candidateDates.isEmpty == false else { return .none }

                    let meetingId = state.meetingId
                    let candidateDates = state.periodVote.candidateDates
                    let voteClient = voteClient
                    state.isSubmitting = true

                    return .run { send in
                        do {
                            try await voteClient.startDateVote(meetingId, candidateDates, durationDays)
                            await send(.startDateVoteResponse(.success(())))
                        } catch {
                            await send(.startDateVoteResponse(.failure(error)))
                        }
                    }
                }

            case .hostPickMeetingDateResponse(.success):
                state.isSubmitting = false
                Log.debug("날짜 지정 API 성공")
                return .send(.delegate(.dateSelectionCompleted(
                    meetingId: state.meetingId,
                    dateVoteStatus: .completed
                )))

            case .hostPickMeetingDateResponse(.failure(let error)):
                state.isSubmitting = false
                Log.error("날짜 지정 API 실패: \(error.localizedDescription)")
                return .none

            case .startDateVoteResponse(.success):
                state.isSubmitting = false
                Log.debug("날짜 투표 시작 API 성공")
                return .send(.delegate(.dateSelectionCompleted(
                    meetingId: state.meetingId,
                    dateVoteStatus: .inProgress
                )))

            case .startDateVoteResponse(.failure(let error)):
                state.isSubmitting = false
                Log.error("날짜 투표 시작 API 실패: \(error.localizedDescription)")
                return .none
            // 날짜지정 탭에서 날짜 선택 버튼 클릭 했을 경우
            case .dateDesignation(.dateFieldTapped):
                state.destination = .datePicker(MeetingDatePickerFeature.State(
                    meetingId: state.meetingId,
                    mode: .single,
                    calendar: calendar
                ))
                return .none
            // 기간 투표 탭에서 날짜 선택 버튼 클릭 했을 경우
            case .periodVote(.dateFieldTapped):
                state.destination = .datePicker(MeetingDatePickerFeature.State(
                    meetingId: state.meetingId,
                    mode: .range,
                    calendar: calendar
                ))
                return .none

            case let .destination(.presented(.datePicker(.delegate(.selectionCompleted(
                mode,
                text,
                requestDate,
                candidateDates
            ))))):
                switch mode {
                case .single:
                    state.dateDesignation.selectedDateText = text
                    state.dateDesignation.selectedDateRequestText = requestDate

                case .range:
                    state.periodVote.selectedDateText = text
                    state.periodVote.candidateDates = candidateDates
                }
                state.destination = nil
                return .none

            case .dateDesignation:
                return .none

            case .periodVote:
                return .none

            case .destination:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

extension MeetingDateSelectionFeature {
    @Reducer(state: .equatable)
    public enum Destination {
        case datePicker(MeetingDatePickerFeature)
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

public enum MeetingDateSelectionTab: String, CaseIterable {
    case date = "날짜 지정"
    case periodVote = "기간 투표"
}

public enum MeetingDatePickerMode: Equatable {
    case single
    case range
}
