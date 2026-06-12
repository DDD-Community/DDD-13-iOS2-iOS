//
//  ProfileInputFeature.swift
//  Presentation
//
//  이름 입력 + 프로필 이미지 선택 화면
//

import Foundation
import Utill

import ComposableArchitecture
import CoreDependencies

import DesignSystem

private enum NameRule {
    static let minCount = 2
    static let maxCount = 7
    private static let validRange: ClosedRange<Unicode.Scalar> = "\u{AC00}"..."\u{D7A3}"
    private static let uppercaseEnglishRange: ClosedRange<Unicode.Scalar> = "A"..."Z"
    private static let lowercaseEnglishRange: ClosedRange<Unicode.Scalar> = "a"..."z"

    static func containsInvalidChars(_ text: String) -> Bool {
        text.unicodeScalars.contains { !validRange.contains($0) }
    }

    static func containsEnglish(_ text: String) -> Bool {
        text.unicodeScalars.contains {
            uppercaseEnglishRange.contains($0) || lowercaseEnglishRange.contains($0)
        }
    }
}

@Reducer
public struct ProfileInputFeature {
    @Dependency(\.nicknameClient) private var nicknameClient

    @ObservableState
    public struct State: Equatable {
        public var name: String
        public var profileImage: ProfileImage
        public var nicknameValidationMessage: String?
        public var isNicknameValidating: Bool
        @Presents public var imagePicker: ProfileImagePickerFeature.State?

        public init(
            name: String = "",
            profileImage: ProfileImage = .none
        ) {
            self.name = name
            self.profileImage = profileImage
            self.nicknameValidationMessage = nil
            self.isNicknameValidating = false
            self.imagePicker = nil
        }

        public var nameInputState: TextInputState {
            guard !name.isEmpty else { return .default }

            if nicknameValidationMessage != nil { return .error }
            if NameRule.containsInvalidChars(name) { return .error }
            if name.count > NameRule.maxCount { return .error }
            if name.count < NameRule.minCount { return .error }

            return .default
        }

        public var nameHelperText: String? {
            guard !name.isEmpty else { return "이름 그대로 작성해주세요" }

            if let nicknameValidationMessage {
                return nicknameValidationMessage
            }
            if NameRule.containsEnglish(name) {
                return "한글만 입력할 수 있습니다"
            }
            if NameRule.containsInvalidChars(name) {
                return "숫자나 특수문자는 사용할 수 없습니다."
            }
            if name.count > NameRule.maxCount {
                return "이름은 한글 7자 이내로 입력해주세요"
            }
            if name.count < NameRule.minCount {
                return "이름은 2글자 이상 입력해주세요"
            }

            return nil
        }

        public var isNextEnabled: Bool {
            let isNameValid = !name.isEmpty
                && !NameRule.containsInvalidChars(name)
                && (NameRule.minCount...NameRule.maxCount).contains(name.count)

            return isNameValid && profileImage.isPresent && !isNicknameValidating
        }

        public var isNameInvalid: Bool {
            !name.isEmpty && nameInputState == .error
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case avatarMenuProfileSetupTapped
        case avatarMenuAlbumImagePicked(Data?)
        case nextButtonTapped
        case nicknameValidateResponse(name: String, Result<Void, Error>)
        case imagePicker(PresentationAction<ProfileImagePickerFeature.Action>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case proceedToDepartureSearch(name: String, profileImage: ProfileImage) // profileImage추가 전달
            case navigateBack
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .binding(\.name):
                state.nicknameValidationMessage = nil
                return .none

            case .binding:
                return .none

            case .backButtonTapped:
                return .send(.delegate(.navigateBack))

            case .avatarMenuProfileSetupTapped:
                state.imagePicker = ProfileImagePickerFeature.State(initialImage: state.profileImage)
                return .none

            case let .avatarMenuAlbumImagePicked(data):
                if let data { state.profileImage = .data(data) }
                return .none

            case .nextButtonTapped:
                guard state.isNextEnabled else { return .none }
                let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
                Log.debug("입력된 이름:\(name)")
                state.isNicknameValidating = true
                return .run { [nicknameClient] send in
                    do {
                        try await nicknameClient.validate(name)
                        await send(.nicknameValidateResponse(name: name, .success(())))
                    } catch {
                        await send(.nicknameValidateResponse(name: name, .failure(error)))
                    }
                }

            case let .nicknameValidateResponse(name, .success):
                state.isNicknameValidating = false
                guard state.name.trimmingCharacters(in: .whitespacesAndNewlines) == name else {
                    return .none
                }
                state.nicknameValidationMessage = nil
                return .send(.delegate(.proceedToDepartureSearch(name: name, profileImage: state.profileImage)))

            case let .nicknameValidateResponse(name, .failure):
                state.isNicknameValidating = false
                guard state.name.trimmingCharacters(in: .whitespacesAndNewlines) == name else {
                    return .none
                }
                state.nicknameValidationMessage = "사용할 수 없는 닉네임입니다"
                return .none

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
