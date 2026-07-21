import Foundation

import ComposableArchitecture
import CoreDependencies
import DesignSystem
import Entity

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

private enum ProfileImageConversionError: Error {
    case invalidPreset
    case pngEncodingFailed
}

@Reducer
public struct ProfileInputFeature {
    @Dependency(\.nicknameClient) private var nicknameClient
    @Dependency(\.memberProfileClient) private var memberProfileClient

    @ObservableState
    public struct State: Equatable {
        public enum Context: Equatable, Sendable {
            case registration
            case editing(MemberProfile)
        }

        public var context: Context
        public var name: String
        public var profileImage: ProfileImage
        public var nicknameValidationMessage: String?
        public var isNicknameValidating: Bool
        public var isProfileUpdating: Bool
        @Presents public var imagePicker: ProfileImagePickerFeature.State?
        @Presents public var alert: AlertState<Action.Alert>?

        public init(
            context: Context,
            name: String? = nil,
            profileImage: ProfileImage? = nil
        ) {
            self.context = context
            switch context {
            case .registration:
                self.name = name ?? ""
                self.profileImage = profileImage ?? .none

            case let .editing(memberProfile):
                self.name = name ?? memberProfile.nickname
                self.profileImage = profileImage
                    ?? memberProfile.profileImageURL.map(ProfileImage.remote)
                    ?? .none
            }
            self.nicknameValidationMessage = nil
            self.isNicknameValidating = false
            self.isProfileUpdating = false
            self.imagePicker = nil
            self.alert = nil
        }

        public init(
            name: String = "",
            profileImage: ProfileImage = .none
        ) {
            self.init(context: .registration, name: name, profileImage: profileImage)
        }

        public var navigationTitle: String {
            switch context {
            case .registration: return "프로필 설정"
            case .editing: return "프로필 수정"
            }
        }

        public var submitButtonTitle: String {
            switch context {
            case .registration: return "다음"
            case .editing: return "완료"
            }
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
            guard !name.isEmpty else { return nil }

            if let nicknameValidationMessage { return nicknameValidationMessage }
            if NameRule.containsEnglish(name) { return "한글만 입력할 수 있습니다" }
            if NameRule.containsInvalidChars(name) { return "숫자나 특수문자는 사용할 수 없습니다." }
            if name.count > NameRule.maxCount { return "이름은 한글 7자 이내로 입력해주세요" }
            if name.count < NameRule.minCount { return "이름은 2글자 이상 입력해주세요" }
            return nil
        }

        public var isNextEnabled: Bool {
            let isNameValid = !name.isEmpty
                && !NameRule.containsInvalidChars(name)
                && (NameRule.minCount...NameRule.maxCount).contains(name.count)
            let isImageValid: Bool
            switch context {
            case .registration: isImageValid = profileImage.isPresent
            case .editing: isImageValid = true
            }
            return isNameValid
                && isImageValid
                && !isNicknameValidating
                && !isProfileUpdating
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case backButtonTapped
        case avatarMenuProfileSetupTapped
        case avatarMenuAlbumImagePicked(Data?, contentType: String)
        case nextButtonTapped
        case nicknameValidateResponse(name: String, Result<Void, Error>)
        case profileUpdateResponse(Result<MemberProfile, Error>)
        case imagePicker(PresentationAction<ProfileImagePickerFeature.Action>)
        case alert(PresentationAction<Alert>)
        case delegate(Delegate)

        public enum Alert: Equatable {
            case confirm
        }

        public enum Delegate: Equatable {
            case proceedToDepartureSearch(name: String)
            case profileUpdated(MemberProfile)
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

            case let .avatarMenuAlbumImagePicked(data, contentType):
                if let data {
                    state.profileImage = .data(data, contentType: contentType)
                }
                return .none

            case .nextButtonTapped:
                guard state.isNextEnabled else { return .none }
                let name = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
                switch state.context {
                case .registration:
                    state.isNicknameValidating = true
                    return validateNicknameEffect(name: name)

                case let .editing(profile):
                    let nicknameChanged = name != profile.nickname
                    let imageChanged = state.profileImage.isChanged(from: profile.profileImageURL)
                    guard nicknameChanged || imageChanged else {
                        return .send(.delegate(.profileUpdated(profile)))
                    }
                    guard nicknameChanged else {
                        return updateProfileEffect(state: &state, name: nil)
                    }
                    state.isNicknameValidating = true
                    return validateNicknameEffect(name: name)
                }

            case let .nicknameValidateResponse(name, .success):
                state.isNicknameValidating = false
                guard state.name.trimmingCharacters(in: .whitespacesAndNewlines) == name else {
                    return .none
                }
                state.nicknameValidationMessage = nil
                switch state.context {
                case .registration:
                    return .send(.delegate(.proceedToDepartureSearch(name: name)))
                case .editing:
                    return updateProfileEffect(state: &state, name: name)
                }

            case let .nicknameValidateResponse(name, .failure):
                state.isNicknameValidating = false
                guard state.name.trimmingCharacters(in: .whitespacesAndNewlines) == name else {
                    return .none
                }
                state.nicknameValidationMessage = "사용할 수 없는 닉네임입니다"
                return .none

            case let .profileUpdateResponse(.success(profile)):
                state.isProfileUpdating = false
                return .send(.delegate(.profileUpdated(profile)))

            case .profileUpdateResponse(.failure):
                state.isNicknameValidating = false
                state.isProfileUpdating = false
                state.alert = AlertState {
                    TextState("프로필 수정에 실패했습니다.")
                } actions: {
                    ButtonState(role: .cancel, action: .confirm) {
                        TextState("확인")
                    }
                }
                return .none

            case let .imagePicker(.presented(.delegate(.dismissWithSave(image)))):
                state.profileImage = image
                state.imagePicker = nil
                return .none

            case .imagePicker(.presented(.delegate(.dismissWithDiscard))):
                state.imagePicker = nil
                return .none

            case .imagePicker, .alert, .delegate:
                return .none
            }
        }
        .ifLet(\.$imagePicker, action: \.imagePicker) {
            ProfileImagePickerFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }

    private func validateNicknameEffect(name: String) -> Effect<Action> {
        let client = nicknameClient
        return .run { send in
            await send(.nicknameValidateResponse(
                name: name,
                Result { try await client.validate(name) }
            ))
        }
    }

    private func updateProfileEffect(
        state: inout State,
        name: String?
    ) -> Effect<Action> {
        let profileImage = state.profileImage
        let initialProfileImageURL: String?
        if case let .editing(profile) = state.context {
            initialProfileImageURL = profile.profileImageURL
        } else {
            initialProfileImageURL = nil
        }
        let shouldUpdateImage = profileImage.isChanged(from: initialProfileImageURL)
        let client = memberProfileClient
        state.isProfileUpdating = true

        return .run { send in
            await send(.profileUpdateResponse(Result {
                let imageUpload = shouldUpdateImage
                    ? try await profileImage.makeUploadPayload()
                    : nil
                let update = MemberProfileUpdate(
                    nickname: name,
                    profileImage: imageUpload
                )
                if let nickname = update.nickname {
                    try await client.updateNickname(nickname)
                }
                if let image = update.profileImage {
                    try await client.updateProfileImage(image)
                }
                return try await client.fetchProfile()
            }))
        }
    }
}

private extension ProfileImage {
    func isChanged(from initialURL: String?) -> Bool {
        switch (self, initialURL) {
        case (.none, nil): return false
        case let (.remote(url), initialURL): return url != initialURL
        default: return true
        }
    }

    @MainActor
    func makeUploadPayload() async throws -> ProfileImageUpload? {
        switch self {
        case .none, .remote:
            return nil

        case let .data(data, contentType):
            return ProfileImageUpload(data: data, contentType: contentType)

        case let .preset(index):
            guard Asset.D3.profileFaces.indices.contains(index) else {
                throw ProfileImageConversionError.invalidPreset
            }

            let snapshot = Asset.D3.profileFaces[index].profileSnapshot
            guard let data = await Task.detached(priority: .userInitiated, operation: {
                snapshot.pngData()
            }).value else {
                throw ProfileImageConversionError.pngEncodingFailed
            }

            return ProfileImageUpload(data: data, contentType: "image/png")
        }
    }
}
