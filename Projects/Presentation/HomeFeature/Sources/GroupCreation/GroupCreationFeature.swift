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

    @ObservableState
    public struct State: Equatable {
        public var groupTitle: String = ""
        public var selectedPurpose: GroupPurpose? = nil
        public var selectedAtmosphere: String? = nil
        public var isGroupNameSheetPresented: Bool = false
        public var isPurposeSheetPresented: Bool = false
        public var isAtmosphereSheetPresented: Bool = false
        public var isLoading: Bool = false

        public var isCreateEnabled: Bool {
            !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedPurpose != nil
            && selectedAtmosphere != nil
            && !isLoading
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case groupNameFieldTapped
        case purposeFieldTapped
        case atmosphereFieldTapped
        case createButtonTapped
        case createGroupResponse(Result<CreateGroupResult, Error>)
        case closeButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case groupCreated(Group)
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

            // TODO: 모임명 입력 BottomSheet UI 구현 (현재는 present 동작만 와이어링)
            case .groupNameFieldTapped:
                state.isGroupNameSheetPresented = true
                return .none

            // TODO: 모임 목적 선택 BottomSheet UI 구현 (현재는 present 동작만 와이어링)
            case .purposeFieldTapped:
                state.isPurposeSheetPresented = true
                return .none

            // TODO: 장소 분위기 선택 BottomSheet UI 구현 (현재는 present 동작만 와이어링)
            case .atmosphereFieldTapped:
                state.isAtmosphereSheetPresented = true
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

            case let .createGroupResponse(.success(result)):
                state.isLoading = false
                let group = makeGroup(from: result, purpose: state.selectedPurpose)
                return .send(.delegate(.groupCreated(group)))

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

    private func makeGroup(from result: CreateGroupResult, purpose: GroupPurpose?) -> Group {
        Group(
            id: result.groupId,
            meetingId: result.meetingId,
            name: result.name,
            themeTagCode: result.themeTagCode,
            themeTagDisplay: purpose?.rawValue ?? "",
            listStatus: .inProgress,
            locationStatus: .before,
            dateVoteStatus: .before,
            locationAddress: nil,
            memberCount: 1,
            members: []
        )
    }
}
