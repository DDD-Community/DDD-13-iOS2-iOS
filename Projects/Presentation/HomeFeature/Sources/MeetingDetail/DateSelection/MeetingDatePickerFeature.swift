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
                let calendar = Calendar.current
                let normalizedDate = calendar.startOfDay(for: date)
                guard normalizedDate >= calendar.startOfDay(for: Date()) else { return .none }

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
