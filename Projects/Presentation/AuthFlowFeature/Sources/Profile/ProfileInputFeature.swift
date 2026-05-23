//
//  ProfileInputFeature.swift
//  Presentation
//
//  이름 입력 + 프로필 이미지 선택 화면
//

import Foundation

import ComposableArchitecture

import DesignSystem

private enum NameRule {
    static let minCount = 2
    static let maxCount = 7
    private static let validRange: ClosedRange<Unicode.Scalar> = "\u{AC00}"..."\u{D7A3}"

    static func containsInvalidChars(_ text: String) -> Bool {
        text.unicodeScalars.contains { !validRange.contains($0) }
    }
}

@Reducer
public struct ProfileInputFeature {
    @ObservableState
    public struct State: Equatable {
        public var name: String
        public var isNameReadOnly: Bool
        public var profileImage: ProfileImage
        @Presents public var imagePicker: ProfileImagePickerFeature.State?

        public init(
            name: String = "",
            profileImage: ProfileImage = .none
        ) {
            self.name = name
            self.isNameReadOnly = !name.isEmpty
            self.profileImage = profileImage
            self.imagePicker = nil
        }

        public var nameInputState: TextInputState {
            guard !name.isEmpty else { return .default }

            if NameRule.containsInvalidChars(name) { return .error }
            if name.count < NameRule.minCount { return .error }

            return .default
        }

        public var nameHelperText: String {
            if !name.isEmpty && NameRule.containsInvalidChars(name) {
                return "숫자나 특수문자는 사용할 수 없습니다."
            }

            return "이름 그대로 작성해주세요"
        }

        public var isNextEnabled: Bool {
            let isNameValid = !name.isEmpty
                && !NameRule.containsInvalidChars(name)
                && (NameRule.minCount...NameRule.maxCount).contains(name.count)

            return isNameValid && profileImage.isPresent
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case avatarMenuAlbumTapped
        case avatarMenuProfileSetupTapped
        case nextButtonTapped
        case imagePicker(PresentationAction<ProfileImagePickerFeature.Action>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case proceedToDepartureSearch(name: String)
            case navigateBack
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.name):
                if state.name.count > NameRule.maxCount {
                    state.name = String(state.name.prefix(NameRule.maxCount))
                }
                return .none

            case .binding:
                return .none

            case .backButtonTapped:
                return .send(.delegate(.navigateBack))

            case .avatarMenuAlbumTapped:
                state.imagePicker = ProfileImagePickerFeature.State(initialImage: state.profileImage)
                return .none

            case .avatarMenuProfileSetupTapped:
                // TODO: 프로필 설정하기 플로우 미명세 - 추후 별도 명세 후 연결
                return .none

            case .nextButtonTapped:
                guard state.isNextEnabled else { return .none }

                let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
                return .send(.delegate(.proceedToDepartureSearch(name: name)))

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
