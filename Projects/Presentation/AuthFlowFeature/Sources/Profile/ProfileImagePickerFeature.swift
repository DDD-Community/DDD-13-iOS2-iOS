//
//  ProfileImagePickerFeature.swift
//  Presentation
//
//  프로필 이미지 선택 바텀시트 Feature
//

import Foundation

import ComposableArchitecture

@Reducer
public struct ProfileImagePickerFeature {
    public static let presetCount = 6

    @ObservableState
    public struct State: Equatable {
        public var initialImage: ProfileImage
        public var candidate: ProfileImage
        public var permissionAlert: PermissionAlertConfig?

        public init(initialImage: ProfileImage) {
            self.initialImage = initialImage
            self.candidate = initialImage
            self.permissionAlert = nil
        }
    }

    public enum Action {
        case cameraButtonTapped
        case galleryButtonTapped
        case presetSelected(index: Int)
        case cameraImagePicked(Data?)
        case galleryImagePicked(Data?)
        case cameraPermissionDenied
        case photoLibraryPermissionDenied
        case permissionAlertDismissed
        case openSettingsTapped
        case deleteButtonTapped
        case saveButtonTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case dismissWithDiscard
            case dismissWithSave(ProfileImage)
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cameraButtonTapped, .galleryButtonTapped:
                return .none

            case let .presetSelected(index):
                state.candidate = .preset(index)
                return .none

            case let .cameraImagePicked(data):
                if let data { state.candidate = .data(data) }
                return .none

            case let .galleryImagePicked(data):
                if let data { state.candidate = .data(data) }
                return .none

            case .cameraPermissionDenied:
                state.permissionAlert = .camera
                return .none

            case .photoLibraryPermissionDenied:
                state.permissionAlert = .photoLibrary
                return .none

            case .permissionAlertDismissed:
                state.permissionAlert = nil
                return .none

            case .openSettingsTapped:
                state.permissionAlert = nil
                SystemSettingsOpener.open()
                return .none

            case .deleteButtonTapped:
                return .send(.delegate(.dismissWithDiscard))

            case .saveButtonTapped:
                let candidate = state.candidate
                return .send(.delegate(.dismissWithSave(candidate)))

            case .delegate:
                return .none
            }
        }
    }
}
