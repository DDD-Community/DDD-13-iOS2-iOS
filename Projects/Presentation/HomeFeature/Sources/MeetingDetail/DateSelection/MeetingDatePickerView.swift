//
//  MeetingDatePickerView.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture
import DesignSystem

struct MeetingDatePickerView: View {
    let store: StoreOf<MeetingDatePickerFeature>
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                title: "날짜 선택",
                trailingIcons: [
                    NavigationIconItem(icon: .close24) {
                        dismiss()
                    }
                ]
            )

            ScrollView {
                VStack(spacing: 0) {
                    SelectedDateTimeSection(store: store)
                        .padding(.horizontal, Spacing.spacing400)
                        .padding(.bottom, Spacing.spacing600)
                    Divider()
                        .frame(maxWidth: .infinity)

                    CalendarSelectionSection(store: store)
                        .padding(.bottom, Spacing.spacing300)
                        .padding(.horizontal, Spacing.spacing400)

                    if store.mode == .single {
                        Divider()
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, Spacing.spacing400)

                        TimeSelectionSection(store: store)
                            .padding(.horizontal, Spacing.spacing400)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, Spacing.spacing400)
                .padding(.bottom, Metric.scrollBottomPadding)
            }
        }
        .background(.white)
        .overlay(alignment: .bottom) {
            ActionButton(
                buttonLayout: .single(
                    title: "다음",
                    isDisabled: !store.isNextEnabled,
                    action: { store.send(.nextButtonTapped) }
                )
            )
            .padding(.bottom, Spacing.spacing400)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private extension MeetingDatePickerView {
    enum Metric {
        static let scrollBottomPadding: CGFloat = 112
    }
}

// MARK: - SelectedDateTimeSection

private struct SelectedDateTimeSection: View {
    let store: StoreOf<MeetingDatePickerFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText(store.selectedDateTimeText ?? placeholderText, textStyle: .headingMedium)
                .foregroundStyle(Colors.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            if store.mode == .range {
                BangawoText("팀원들이 기간에 맞춰 날짜를 투표해요", textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var placeholderText: String {
        switch store.mode {
        case .single:
            return "날짜와 시간을 선택해 주세요"

        case .range:
            return "날짜를 선택해 주세요"
        }
    }
}

// MARK: - CalendarSelectionSection

private struct CalendarSelectionSection: View {
    let store: StoreOf<MeetingDatePickerFeature>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdays = ["월", "화", "수", "목", "금", "토", "일"]

    var body: some View {
        VStack(spacing: 0) {
            MonthHeader(store: store)
                .padding(.top, Spacing.spacing400)
                .padding(.bottom, Spacing.spacing200)

            LazyVGrid(columns: columns, spacing: Spacing.spacing300) {
                ForEach(weekdays.indices, id: \.self) { index in
                    BangawoText(weekdays[index], textStyle: .bodyMedium)
                        .foregroundStyle(Colors.gray700)
                        .frame(width: Metric.dateButtonLength, height: Metric.weekdayHeight)
                        .frame(maxWidth: .infinity, alignment: alignment(forColumn: index))
                        .padding(.vertical, Spacing.spacing250)
                }

                ForEach(calendarDates.indices, id: \.self) { index in
                    if let date = calendarDates[index] {
                        CalendarDateButton(
                            day: Calendar.current.component(.day, from: date),
                            selectionState: selectionState(for: date),
                            alignment: alignment(forColumn: index % 7)
                        ) {
                            store.send(.dateTapped(date), animation: .easeInOut(duration: 0.15))
                        }
                        .disabled(isPastDate(date))
                    } else {
                        Color.clear
                            .frame(width: Metric.dateButtonLength, height: Metric.dateButtonLength)
                            .frame(maxWidth: .infinity, alignment: alignment(forColumn: index % 7))
                    }
                }
            }
        }
    }

    private func alignment(forColumn column: Int) -> Alignment {
        switch column {
        case 0:
            return .leading

        case 6:
            return .trailing

        default:
            return .center
        }
    }

    private func isPastDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date) < calendar.startOfDay(for: Date())
    }

    private var calendarDates: [Date?] {
        let calendar = Calendar.current
        guard
            let range = calendar.range(of: .day, in: .month, for: store.displayedMonth),
            let firstDate = calendar.date(from: calendar.dateComponents([.year, .month], from: store.displayedMonth))
        else {
            return []
        }

        let leadingEmptyCount = (calendar.component(.weekday, from: firstDate) + 5) % 7
        let dates = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDate)
        }

        return Array(repeating: nil, count: leadingEmptyCount) + dates
    }

    private func selectionState(for date: Date) -> CalendarDateButton.SelectionState {
        if isPastDate(date) {
            return .disabled
        }

        let calendar = Calendar.current

        switch store.mode {
        case .single:
            if let selectedDate = store.selectedDate, calendar.isDate(date, inSameDayAs: selectedDate) {
                return .selected
            }
            return .normal

        case .range:
            let isStart = store.rangeStartDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false
            let isEnd = store.rangeEndDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false

            if isStart, store.rangeEndDate != nil {
                return .rangeStart
            }

            if isEnd {
                return .rangeEnd
            }

            if isStart {
                return .selected
            }

            if let startDate = store.rangeStartDate, let endDate = store.rangeEndDate,
               date > startDate && date < endDate {
                return .inRange
            }

            return .normal
        }
    }
}

private extension CalendarSelectionSection {
    enum Metric {
        static let weekdayHeight: CGFloat = 28
        static let dateButtonLength: CGFloat = 40
    }
}

// MARK: - MonthHeader

private struct MonthHeader: View {
    let store: StoreOf<MeetingDatePickerFeature>

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            Button {
                store.send(.previousMonthTapped, animation: .easeInOut(duration: 0.2))
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Colors.gray800)
                    .frame(width: Metric.buttonLength, height: Metric.buttonLength)
            }
            .buttonStyle(.plain)

            BangawoText(monthTitle, textStyle: .titleMedium)
                .foregroundStyle(Colors.gray900)

            Button {
                store.send(.nextMonthTapped, animation: .easeInOut(duration: 0.2))
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Colors.gray800)
                    .frame(width: Metric.buttonLength, height: Metric.buttonLength)
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }

    private var monthTitle: String {
        Self.monthFormatter.string(from: store.displayedMonth)
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()
}

private extension MonthHeader {
    enum Metric {
        static let buttonLength: CGFloat = 24
    }
}

// MARK: - CalendarDateButton

private struct CalendarDateButton: View {
    enum SelectionState {
        case normal
        case disabled
        case inRange
        case selected
        case rangeStart
        case rangeEnd
    }

    let day: Int
    let selectionState: SelectionState
    let alignment: Alignment
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                rangeBackground

                ZStack {
                    if selectionState.isCircleSelected {
                        Circle()
                            .fill(Colors.gray800)
                            .frame(width: Metric.length, height: Metric.length)
                    }

                    BangawoText("\(day)", textStyle: .bodyLarge)
                        .foregroundStyle(textColor)
                }
                .frame(width: Metric.length, height: Metric.length)
                .frame(maxWidth: .infinity, alignment: alignment)
            }
            .frame(height: Metric.length)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var rangeBackground: some View {
        switch selectionState {
        case .normal, .disabled, .selected:
            Color.clear

        case .inRange:
            Rectangle()
                .fill(Colors.grayAlpha200)
        // 선택 날짜의 시작과 끝의 반쪽의 배경색을 저장해줘야 범위 선택시 자연스러운 연결 가능
        case .rangeStart:
            HStack(spacing: 0) {
                Color.clear
                Rectangle()
                    .fill(Colors.grayAlpha200)
            }

        case .rangeEnd:
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Colors.grayAlpha200)
                Color.clear
            }
        }
    }

    private var textColor: Color {
        switch selectionState {
        case .normal:
            return Colors.gray900

        case .disabled:
            return Colors.gray400

        case .inRange:
            return Colors.gray900

        case .selected, .rangeStart, .rangeEnd:
            return .white
        }
    }
}

private extension CalendarDateButton.SelectionState {
    var isCircleSelected: Bool {
        switch self {
        case .selected, .rangeStart, .rangeEnd:
            return true

        case .normal, .disabled, .inRange:
            return false
        }
    }
}

private extension CalendarDateButton {
    enum Metric {
        static let length: CGFloat = 40
    }
}

// MARK: - TimeSelectionSection

private struct TimeSelectionSection: View {
    let store: StoreOf<MeetingDatePickerFeature>

    var body: some View {
        VStack(spacing: Spacing.spacing500) {
            TimePeriodSection(
                title: "오전",
                hours: Array(8...11),
                selectedHour: store.selectedHour
            ) { hour in
                store.send(.hourTapped(hour), animation: .easeInOut(duration: 0.15))
            }

            TimePeriodSection(
                title: "오후",
                hours: Array(12...23),
                selectedHour: store.selectedHour
            ) { hour in
                store.send(.hourTapped(hour), animation: .easeInOut(duration: 0.15))
            }
        }
    }
}

// MARK: - TimePeriodSection

private struct TimePeriodSection: View {
    let title: String
    let hours: [Int]
    let selectedHour: Int?
    let onHourTapped: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: Spacing.spacing200), count: 4)

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing250) {
            BangawoText(title, textStyle: .labelSmall)
                .foregroundStyle(Colors.gray900)

            LazyVGrid(columns: columns, spacing: Spacing.spacing200) {
                ForEach(hours, id: \.self) { hour in
                    TimeChipButton(
                        title: hourTitle(for: hour),
                        isSelected: selectedHour == hour
                    ) {
                        onHourTapped(hour)
                    }
                }
            }
        }
    }

    private func hourTitle(for hour: Int) -> String {
        String(format: "%02d:00", hour)
    }
}

// MARK: - TimeChipButton

private struct TimeChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            BangawoText(title, textStyle: .labelMedium)
                .foregroundStyle(isSelected ? .white : Colors.gray800)
                .frame(maxWidth: .infinity)
                .frame(height: Metric.height)
                .background(background)
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
            .fill(isSelected ? Colors.gray800 : .white)
            .overlay {
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                    .stroke(
                        isSelected ? Colors.gray800 : Colors.gray300,
                        lineWidth: BorderWidth.borderWidth100
                    )
            }
    }
}

private extension TimeChipButton {
    enum Metric {
        static let height: CGFloat = 44
    }
}

#Preview("단일 날짜 선택") {
    BangawoPreview {
        MeetingDatePickerView(store: Store(initialState: MeetingDatePickerFeature.State(meetingId: 1, mode: .single)) {
            MeetingDatePickerFeature()
        })
    }
}

#Preview("기간 선택") {
    BangawoPreview {
        MeetingDatePickerView(store: Store(initialState: MeetingDatePickerFeature.State(meetingId: 1, mode: .range)) {
            MeetingDatePickerFeature()
        })
    }
}
