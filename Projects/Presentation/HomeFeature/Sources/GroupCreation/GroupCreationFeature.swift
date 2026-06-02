//
//  GroupCreationFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Foundation

public enum GroupPurpose: String, CaseIterable, Equatable, Identifiable {
    case networking   = "네트워킹"
    case study        = "스터디"
    case hobby        = "취미/여가"
    case sports       = "운동/스포츠"
    case culture      = "문화/예술"
    case social       = "친목/소셜"
    case volunteering = "봉사활동"
    case business     = "비즈니스"

    public var id: String { rawValue }

    public var themeTagCode: String {
        switch self {
        case .networking:   return "NETWORKING"
        case .study:        return "STUDY"
        case .hobby:        return "HOBBY"
        case .sports:       return "SPORTS"
        case .culture:      return "CULTURE"
        case .social:       return "SOCIAL"
        case .volunteering: return "VOLUNTEERING"
        case .business:     return "BUSINESS"
        }
    }
}

@Reducer
public struct GroupCreationFeature {
    @Dependency(\.groupClient) private var groupClient

    public enum Step: Equatable {
        case info
        case purpose
    }

    @ObservableState
    public struct State: Equatable {
        public var step: Step = .info
        public var groupTitle: String = ""
        public var selectedPurpose: GroupPurpose? = nil
        public var pendingPurpose: GroupPurpose? = nil
        public var isLoading: Bool = false

        public var isCreateEnabled: Bool {
            !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedPurpose != nil
            && !isLoading
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case purposeButtonTapped
        case purposeTapped(GroupPurpose)
        case registerButtonTapped
        case createButtonTapped
        case createGroupResponse(Result<CreateGroupResult, Error>)
        case closeButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case groupCreated
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
                state.isLoading = true
                let name = state.groupTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let themeTagCode = purpose.themeTagCode
                let client = groupClient
                return .run { send in
                    await send(.createGroupResponse(
                        Result { try await client.createGroup(name, themeTagCode) }
                    ))
                }

            case .createGroupResponse(.success):
                state.isLoading = false
                return .send(.delegate(.groupCreated))

            case .createGroupResponse(.failure):
                state.isLoading = false
                return .none

            case .closeButtonTapped:
                return .send(.delegate(.dismissed))

            case .delegate:
                return .none
            }
        }
    }
}
