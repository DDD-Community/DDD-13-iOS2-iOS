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
                Log.debug("날짜 선택 다음 클릭")
                guard state.selectedTab == .date else { return .none }
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

@Reducer
public struct MeetingDatePickerFeature {
    @ObservableState
    public struct State: Equatable {
        let meetingId: Int
        let mode: MeetingDatePickerMode
        var displayedMonth: Date
        var selectedDate: Date?
        var rangeStartDate: Date?
        var rangeEndDate: Date?
        var selectedHour: Int?

        var isNextEnabled: Bool {
            switch mode {
            case .single:
                return selectedDate != nil && selectedHour != nil

            case .range:
                return rangeStartDate != nil && rangeEndDate != nil
            }
        }

        var selectionText: String? {
            switch mode {
            case .single:
                guard let selectedDate, let timeText else { return nil }
                return "\(Self.dateText(for: selectedDate)) \(timeText)"

            case .range:
                guard let rangeStartDate, let rangeEndDate else { return nil }
                return "\(Self.dateText(for: rangeStartDate)) - \(Self.dateText(for: rangeEndDate))"
            }
        }

        var selectedDateTimeText: String? {
            switch mode {
            case .single:
                guard let selectedDate, let timeText else { return nil }
                return "\(Self.dateText(for: selectedDate)) \(timeText)"

            case .range:
                guard let rangeStartDate else { return nil }

                if let rangeEndDate {
                    return "\(Self.dateText(for: rangeStartDate)) - \(Self.dateText(for: rangeEndDate))"
                }

                return Self.dateText(for: rangeStartDate)
            }
        }

        private var timeText: String? {
            guard let selectedHour else { return nil }

            let periodText = selectedHour < 12 ? "오전" : "오후"
            let displayHour = selectedHour > 12 ? selectedHour - 12 : selectedHour
            return "\(periodText) \(String(format: "%02d:00", displayHour))"
        }

        var selectedDateRequestText: String? {
            guard let selectedDate else { return nil }
            return Self.requestDateText(for: selectedDate)
        }

        public init(
            meetingId: Int,
            mode: MeetingDatePickerMode,
            displayedMonth: Date = Date(),
            selectedDate: Date? = nil,
            rangeStartDate: Date? = nil,
            rangeEndDate: Date? = nil,
            selectedHour: Int? = nil
        ) {
            let defaultDate = Calendar.current.startOfDay(for: Date())

            self.meetingId = meetingId
            self.mode = mode
            self.displayedMonth = Calendar.current.startOfMonth(for: displayedMonth)
            self.selectedDate = selectedDate ?? (mode == .single ? defaultDate : nil)
            self.rangeStartDate = rangeStartDate ?? (mode == .range ? defaultDate : nil)
            self.rangeEndDate = rangeEndDate
            self.selectedHour = selectedHour ?? (mode == .single ? 8 : nil)
        }

        private static func dateText(for date: Date) -> String {
            let calendar = Calendar.current
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let weekday = KoreanWeekday.symbol(for: calendar.component(.weekday, from: date))
            return "\(month)월 \(day)일 (\(weekday))"
        }

        private static func requestDateText(for date: Date) -> String {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
        }
    }

    public enum Action {
        case previousMonthTapped
        case nextMonthTapped
        case dateTapped(Date)
        case hourTapped(Int)
        case nextButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case selectionCompleted(MeetingDatePickerMode, text: String, requestDate: String?)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .previousMonthTapped:
                state.displayedMonth = Calendar.current.date(byAdding: .month, value: -1, to: state.displayedMonth)
                    ?? state.displayedMonth
                return .none

            case .nextMonthTapped:
                state.displayedMonth = Calendar.current.date(byAdding: .month, value: 1, to: state.displayedMonth)
                    ?? state.displayedMonth
                return .none

            case let .dateTapped(date):
                let normalizedDate = Calendar.current.startOfDay(for: date)
                switch state.mode {
                case .single:
                    state.selectedDate = normalizedDate

                case .range:
                    updateRangeSelection(state: &state, date: normalizedDate)
                }
                return .none

            case let .hourTapped(hour):
                state.selectedHour = hour
                return .none

            case .nextButtonTapped:
                guard let selectionText = state.selectionText else { return .none }
                Log.debug("날짜 선택 다음 클릭")
                return .send(.delegate(.selectionCompleted(
                    state.mode,
                    text: selectionText,
                    requestDate: state.selectedDateRequestText
                )))

            case .delegate:
                return .none
            }
        }
    }

    private func updateRangeSelection(state: inout State, date: Date) {
        guard let startDate = state.rangeStartDate else {
            state.rangeStartDate = date
            state.rangeEndDate = nil
            return
        }

        if state.rangeEndDate != nil || date < startDate {
            state.rangeStartDate = date
            state.rangeEndDate = nil
            return
        }

        if date == startDate {
            state.rangeStartDate = date
            state.rangeEndDate = nil
            return
        }

        state.rangeEndDate = date
    }
}

private enum KoreanWeekday {
    private static let symbols = ["일", "월", "화", "수", "목", "금", "토"]

    static func symbol(for weekday: Int) -> String {
        guard symbols.indices.contains(weekday - 1) else { return "" }
        return symbols[weekday - 1]
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? startOfDay(for: date)
    }
}
