//
//  PeriodVoteFeature.swift
//  HomeFeature
//

import ComposableArchitecture

@Reducer
public struct PeriodVoteFeature {
    @ObservableState
    public struct State: Equatable {
        var selectedDateText = ""
        var candidateDates: [String] = []
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

public enum VoteDeadlineOption: String, CaseIterable, Equatable, Identifiable {
    case oneDay = "하루 뒤 마감"
    case threeDays = "3일 뒤 마감"
    case sevenDays = "7일 뒤 마감"
    case custom = "사용자 설정"

    public var id: String { rawValue }

    var durationDays: Int? {
        switch self {
        case .oneDay:
            return 1
        case .threeDays:
            return 3
        case .sevenDays:
            return 7
        case .custom:
            return nil
        }
    }
}
