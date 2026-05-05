//
//  ProfileInputFeature.swift
//  Presentation
//
//  닉네임 입력 + 프로필 이미지 선택 진입 화면
//

import ComposableArchitecture
import Foundation

@Reducer
public struct ProfileInputFeature {
    @ObservableState
    public struct State: Equatable {
        public var greetingName: String
        public var nickname: String
        public var profileImage: ProfileImage
        @Presents public var imagePicker: ProfileImagePickerFeature.State?

        public init(
            greetingName: String = "김반가워",
            nickname: String = "",
            profileImage: ProfileImage = .none
        ) {
            self.greetingName = greetingName
            self.nickname = nickname
            self.profileImage = profileImage
        }

        public var isNextEnabled: Bool {
            !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case profileImageTapped
        case clearNicknameButtonTapped
        case nextButtonTapped
        case imagePicker(PresentationAction<ProfileImagePickerFeature.Action>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case proceedToDepartureSearch(nickname: String)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .profileImageTapped:
                state.imagePicker = ProfileImagePickerFeature.State(initialImage: state.profileImage)
                return .none

            case .clearNicknameButtonTapped:
                state.nickname = ""
                return .none

            case .nextButtonTapped:
                guard state.isNextEnabled else { return .none }

                let nickname = state.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                return .send(.delegate(.proceedToDepartureSearch(nickname: nickname)))

            case let .imagePicker(.presented(.delegate(.dismissWithSave(image)))):
                state.profileImage = image
                state.imagePicker = nil
                return .none

            case .imagePicker(.presented(.delegate(.dismissWithDiscard))):
                state.imagePicker = nil
                return .none

            case .imagePicker:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$imagePicker, action: \.imagePicker) {
            ProfileImagePickerFeature()
        }
    }
}
