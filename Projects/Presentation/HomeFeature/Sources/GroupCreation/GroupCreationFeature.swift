//
//  GroupCreationFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Foundation

private enum Constant {
    static let groupNameMaxCount = 30
    static let atmosphereMaxSelection = 3
}

public enum GroupPurpose: String, CaseIterable, Equatable, Identifiable {
    case business   = "비즈니스"
    case birthday   = "생일 파티"
    case networking = "친목 및 네트워킹"
    case wedding    = "청첩장 모임"
    case dining     = "가벼운 식사"
    case family     = "가족 모임"

    public var id: String { rawValue }

    // TODO: themeTagCode는 서버 스펙 확정 전 임시 값 (확정 시 교체 필요)
    public var themeTagCode: String {
        switch self {
        case .business:   return "BUSINESS"
        case .birthday:   return "BIRTHDAY"
        case .networking: return "NETWORKING"
        case .wedding:    return "WEDDING"
        case .dining:     return "DINING"
        case .family:     return "FAMILY"
        }
    }
}

public enum PlaceAtmosphere: String, CaseIterable, Equatable, Identifiable {
    case nice        = "분위기 좋은"
    case quiet       = "조용한 공간"
    case comfortable = "편안한 좌석"
    case talkative   = "대화하기 좋은"
    case photogenic  = "사진 맛집"
    case openView    = "탁 트인 뷰"
    case spacious    = "넓은 공간"

    public var id: String { rawValue }
}

@Reducer
public struct GroupCreationFeature {
    @Dependency(\.groupClient) private var groupClient

    @ObservableState
    public struct State: Equatable {
        public var groupTitle: String = ""
        public var groupNameDraft: String = ""
        public var selectedPurpose: GroupPurpose? = nil
        public var purposeDraft: GroupPurpose = .business
        public var selectedAtmospheres: [PlaceAtmosphere] = []
        public var atmosphereDraft: [PlaceAtmosphere] = []
        public var isGroupNameSheetPresented: Bool = false
        public var isPurposeSheetPresented: Bool = false
        public var isAtmosphereSheetPresented: Bool = false
        public var isLoading: Bool = false

        public var isCreateEnabled: Bool {
            !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedPurpose != nil
            && !selectedAtmospheres.isEmpty
            && !isLoading
        }

        public var isGroupNameDraftValid: Bool {
            let trimmed = groupNameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && groupNameDraft.count <= Constant.groupNameMaxCount
        }

        public var isAtmosphereDraftValid: Bool {
            !atmosphereDraft.isEmpty
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case groupNameFieldTapped
        case groupNameConfirmed
        case groupNameSheetDismissed
        case purposeFieldTapped
        case purposeSelected(GroupPurpose)
        case purposeConfirmed
        case purposeSheetDismissed
        case atmosphereFieldTapped
        case atmosphereToggled(PlaceAtmosphere)
        case atmosphereConfirmed
        case atmosphereSheetDismissed
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

            case .groupNameFieldTapped:
                state.groupNameDraft = state.groupTitle
                state.isGroupNameSheetPresented = true
                return .none

            case .groupNameConfirmed:
                guard state.isGroupNameDraftValid else { return .none }

                state.groupTitle = state.groupNameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                state.isGroupNameSheetPresented = false
                return .none

            case .groupNameSheetDismissed:
                state.isGroupNameSheetPresented = false
                return .none

            case .purposeFieldTapped:
                state.purposeDraft = state.selectedPurpose ?? .business
                state.isPurposeSheetPresented = true
                return .none

            case let .purposeSelected(purpose):
                state.purposeDraft = purpose
                return .none

            case .purposeConfirmed:
                state.selectedPurpose = state.purposeDraft
                state.isPurposeSheetPresented = false
                return .none

            case .purposeSheetDismissed:
                state.isPurposeSheetPresented = false
                return .none

            case .atmosphereFieldTapped:
                state.atmosphereDraft = state.selectedAtmospheres
                state.isAtmosphereSheetPresented = true
                return .none

            case let .atmosphereToggled(atmosphere):
                if let index = state.atmosphereDraft.firstIndex(of: atmosphere) {
                    state.atmosphereDraft.remove(at: index)
                } else if state.atmosphereDraft.count < Constant.atmosphereMaxSelection {
                    state.atmosphereDraft.append(atmosphere)
                }
                return .none

            case .atmosphereConfirmed:
                guard state.isAtmosphereDraftValid else { return .none }

                state.selectedAtmospheres = state.atmosphereDraft
                state.isAtmosphereSheetPresented = false
                return .none

            case .atmosphereSheetDismissed:
                state.isAtmosphereSheetPresented = false
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
