//
//  GroupCreationFeature.swift
//  HomeFeature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Foundation
import Utill
private enum Constant {
    static let groupNameMaxCount = 30
    static let atmosphereMaxSelection = 3
}

@Reducer
public struct GroupCreationFeature {
    @Dependency(\.groupClient) private var groupClient
    @Dependency(\.themeTagClient) private var themeTagClient
    @Dependency(\.placeOptionsClient) private var placeOptionsClient

    @ObservableState
    public struct State: Equatable {
        public var groupTitle: String = ""
        public var groupNameDraft: String = ""
        public var themeTags: [ThemeTag] = []
        public var selectedThemeTag: ThemeTag? = nil
        public var purposeDraft: ThemeTag? = nil
        public var vibes: [String] = []
        public var selectedAtmospheres: [String] = []
        public var atmosphereDraft: [String] = []
        public var isGroupNameSheetPresented: Bool = false
        public var isPurposeSheetPresented: Bool = false
        public var isAtmosphereSheetPresented: Bool = false
        public var isLoading: Bool = false

        public var isCreateEnabled: Bool {
            !groupTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && selectedThemeTag != nil
            && !selectedAtmospheres.isEmpty
            && !isLoading
        }

        public var isGroupNameDraftValid: Bool {
            let trimmed = groupNameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && groupNameDraft.count <= Constant.groupNameMaxCount
        }

        public var isPurposeDraftValid: Bool {
            purposeDraft != nil
        }

        public var isAtmosphereDraftValid: Bool {
            !atmosphereDraft.isEmpty
        }

        public init() {}
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case themeTagsResponse(Result<[ThemeTag], Error>)
        case vibesResponse(Result<[String], Error>)
        case groupNameFieldTapped
        case groupNameConfirmed
        case groupNameSheetDismissed
        case purposeFieldTapped
        case purposeSelected(ThemeTag)
        case purposeConfirmed
        case purposeSheetDismissed
        case atmosphereFieldTapped
        case atmosphereToggled(String)
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

            case .onAppear:
                let themeTagClient = themeTagClient
                let placeOptionsClient = placeOptionsClient
                return .merge(
                    state.themeTags.isEmpty
                        ? .run { send in
                            await send(.themeTagsResponse(Result { try await themeTagClient.fetchThemeTags() }))
                        }
                        : .none,
                    state.vibes.isEmpty
                        ? .run { send in
                            await send(.vibesResponse(Result { try await placeOptionsClient.fetchVibes() }))
                        }
                        : .none
                )

            case let .themeTagsResponse(.success(themeTags)):
                state.themeTags = themeTags
                return .none

            case .themeTagsResponse(.failure):
                return .none

            case let .vibesResponse(.success(vibes)):
                state.vibes = vibes
                return .none

            case let .vibesResponse(.failure(error)):
                Log.debug("장소 분위기 조회 실패: \(error.localizedDescription)")
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
                state.purposeDraft = state.selectedThemeTag ?? state.themeTags.first
                state.isPurposeSheetPresented = true
                return .none

            case let .purposeSelected(themeTag):
                state.purposeDraft = themeTag
                return .none

            case .purposeConfirmed:
                guard let purposeDraft = state.purposeDraft else { return .none }

                state.selectedThemeTag = purposeDraft
                state.isPurposeSheetPresented = false
                let selectedPurposes: [String] = [purposeDraft.code]
                Log.debug("선택된 모임 목적: \(selectedPurposes)")
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
                let selectedAtmospheres: [String] = state.selectedAtmospheres
                Log.debug("선택된 장소 분위기: \(selectedAtmospheres)")
                return .none

            case .atmosphereSheetDismissed:
                state.isAtmosphereSheetPresented = false
                return .none

            case .createButtonTapped:
                guard state.isCreateEnabled, let themeTag = state.selectedThemeTag else { return .none }

                state.isLoading = true
                let name = state.groupTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                let themeTagCode = themeTag.code
                let client = groupClient
                return .run { send in
                    await send(.createGroupResponse(
                        Result { try await client.createGroup(name, themeTagCode) }
                    ))
                }

            case let .createGroupResponse(.success(result)):
                state.isLoading = false
                guard let themeTag = state.selectedThemeTag else { return .none }

                let group = makeGroup(from: result, themeTag: themeTag)
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

    private func makeGroup(from result: CreateGroupResult, themeTag: ThemeTag) -> Group {
        Group(
            id: result.groupId,
            meetingId: result.meetingId,
            name: result.name,
            themeTagCode: result.themeTagCode,
            themeTagDisplay: themeTag.displayName,
            listStatus: .inProgress,
            locationStatus: .before,
            dateVoteStatus: .before,
            locationAddress: nil,
            memberCount: 1,
            members: []
        )
    }
}
