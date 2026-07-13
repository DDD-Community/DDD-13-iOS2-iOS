//
//  MeetingDatePickerFeature.swift
//  HomeFeature
//

import Foundation

import ComposableArchitecture
import Utill

@Reducer
public struct MeetingDatePickerFeature {
    @ObservableState
    public struct State: Equatable {
        let meetingId: Int
        let mode: MeetingDatePickerMode
        let calendar: Calendar
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
                return "\(Self.dateText(for: selectedDate, calendar: calendar)) \(timeText)"

            case .range:
                guard let rangeStartDate, let rangeEndDate else { return nil }
                return "\(Self.dateText(for: rangeStartDate, calendar: calendar)) - \(Self.dateText(for: rangeEndDate, calendar: calendar))"
            }
        }

        var selectedDateTimeText: String? {
            switch mode {
            case .single:
                guard let selectedDate, let timeText else { return nil }
                return "\(Self.dateText(for: selectedDate, calendar: calendar)) \(timeText)"

            case .range:
                guard let rangeStartDate else { return nil }

                if let rangeEndDate {
                    return "\(Self.dateText(for: rangeStartDate, calendar: calendar)) - \(Self.dateText(for: rangeEndDate, calendar: calendar))"
                }

                return Self.dateText(for: rangeStartDate, calendar: calendar)
            }
        }

        private var timeText: String? {
            guard let selectedHour else { return nil }

            let periodText = selectedHour < 12 ? "오전" : "오후"
            let displayHour = selectedHour > 12 ? selectedHour - 12 : selectedHour
            return "\(periodText) \(String(format: "%02d:00", displayHour))"
        }

        var selectedDateRequestText: String? {
            guard let selectedDate, let selectedHour else { return nil }
            return Self.requestDateTimeText(for: selectedDate, hour: selectedHour, calendar: calendar)
        }

        var selectedCandidateDateTexts: [String] {
            switch mode {
            case .single:
                return []

            case .range:
                guard let rangeStartDate, let rangeEndDate else { return [] }
                return Self.dates(from: rangeStartDate, through: rangeEndDate, calendar: calendar)
                    .map { Self.requestDateTimeText(for: $0, calendar: calendar) }
            }
        }

        public init(
            meetingId: Int,
            mode: MeetingDatePickerMode,
            displayedMonth: Date = Date(),
            selectedDate: Date? = nil,
            rangeStartDate: Date? = nil,
            rangeEndDate: Date? = nil,
            selectedHour: Int? = nil,
            calendar: Calendar,
            now: Date = Date()
        ) {
            let defaultDate = calendar.startOfDay(for: now)

            self.meetingId = meetingId
            self.mode = mode
            self.calendar = calendar
            self.displayedMonth = calendar.startOfMonth(for: displayedMonth)
            self.selectedDate = selectedDate ?? (mode == .single ? defaultDate : nil)
            self.rangeStartDate = rangeStartDate ?? (mode == .range ? defaultDate : nil)
            self.rangeEndDate = rangeEndDate
            self.selectedHour = selectedHour ?? (mode == .single ? 8 : nil)
        }

        private static func dateText(for date: Date, calendar: Calendar) -> String {
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let weekday = KoreanWeekday.symbol(for: calendar.component(.weekday, from: date))
            return "\(month)월 \(day)일 (\(weekday))"
        }

        private static func requestDateText(for date: Date, calendar: Calendar) -> String {
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            return "\(year)-\(String(format: "%02d", month))-\(String(format: "%02d", day))"
        }

        private static func requestDateTimeText(for date: Date, calendar: Calendar) -> String {
            "\(requestDateText(for: date, calendar: calendar))T00:00:00.000Z"
        }

        private static func requestDateTimeText(for date: Date, hour: Int, calendar: Calendar) -> String {
            // 날짜 지정 API도 후보 날짜와 같은 datetime 문자열을 기대하므로 선택된 시간을 함께 보낸다.
            "\(requestDateText(for: date, calendar: calendar))T\(String(format: "%02d", hour)):00:00.000Z"
        }

        private static func dates(from startDate: Date, through endDate: Date, calendar: Calendar) -> [Date] {
            var dates: [Date] = []
            var currentDate = calendar.startOfDay(for: startDate)
            let endDate = calendar.startOfDay(for: endDate)

            while currentDate <= endDate {
                dates.append(currentDate)
                guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
                currentDate = nextDate
            }

            return dates
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
            case selectionCompleted(
                MeetingDatePickerMode,
                text: String,
                requestDate: String?,
                candidateDates: [String]
            )
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .previousMonthTapped:
                state.displayedMonth = state.calendar.date(byAdding: .month, value: -1, to: state.displayedMonth)
                    ?? state.displayedMonth
                return .none

            case .nextMonthTapped:
                state.displayedMonth = state.calendar.date(byAdding: .month, value: 1, to: state.displayedMonth)
                    ?? state.displayedMonth
                return .none

            case let .dateTapped(date):
                let normalizedDate = state.calendar.startOfDay(for: date)
                guard normalizedDate >= state.calendar.startOfDay(for: Date()) else { return .none }

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

            case .nextButtonTapped: // 달력에서 날짜 선택 후 다음 버튼 클릭 시
                guard let selectionText = state.selectionText else { return .none }
                return .send(.delegate(.selectionCompleted(
                    state.mode,
                    text: selectionText,
                    requestDate: state.selectedDateRequestText,
                    candidateDates: state.selectedCandidateDateTexts
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
