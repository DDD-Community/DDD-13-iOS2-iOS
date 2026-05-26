//
//  MeetingCreationSheetFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import Entity
import Foundation

public enum MeetingPurpose: String, CaseIterable, Equatable, Identifiable {
    case networking   = "네트워킹"
    case study        = "스터디"
    case hobby        = "취미/여가"
    case sports       = "운동/스포츠"
    case culture      = "문화/예술"
    case social       = "친목/소셜"
    case volunteering = "봉사활동"
    case business     = "비즈니스"

    public var id: String { rawValue }
}

@Reducer
public struct MeetingCreationSheetFeature {
    public enum Step: Equatable {
        case info
        case purpose
    }

    @ObservableState
    public struct State: Equatable {
        public var step: Step = .info
        public var meetingTitle: String = ""
        public var selectedPurpose: MeetingPurpose? = nil
        public var pendingPurpose: MeetingPurpose? = nil

        public var isCreateEnabled: Bool {
            !meetingTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedPurpose != nil
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case purposeButtonTapped
        case purposeTapped(MeetingPurpose)
        case registerButtonTapped
        case createButtonTapped
        case closeButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case meetingCreated(Meeting)
            case dismissed
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .purposeButtonTapped:
                state.pendingPurpose = state.selectedPurpose
                state.step = .purpose
                return .none

            case .purposeTapped(let purpose):
                state.pendingPurpose = purpose
                return .none

            case .registerButtonTapped:
                state.selectedPurpose = state.pendingPurpose
                state.step = .info
                return .none

            case .createButtonTapped:
                guard state.isCreateEnabled, let purpose = state.selectedPurpose else { return .none }

                let meeting = Meeting(
                    id: UUID(),
                    title: state.meetingTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                    hashtag: "#\(purpose.rawValue)",
                    status: .inProgress,
                    participantCount: 1
                )
                return .send(.delegate(.meetingCreated(meeting)))

            case .closeButtonTapped:
                return .send(.delegate(.dismissed))

            case .delegate:
                return .none
            }
        }
    }
}
