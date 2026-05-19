//
//  ProfileInputView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct ProfileInputView: View {
    @Bindable private var store: StoreOf<ProfileInputFeature>
    @State private var isShowingMenu = false

    public init(store: StoreOf<ProfileInputFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { store.send(.backButtonTapped) },
                title: "프로필 설정"
            )

            VStack(spacing: 0) {
                ProfileImageContainer(
                    profileImage: store.profileImage,
                    isShowingMenu: $isShowingMenu,
                    onMenuAlbumTapped: { store.send(.avatarMenuAlbumTapped) },
                    onMenuProfileSetupTapped: { store.send(.avatarMenuProfileSetupTapped) }
                )

                TextInput(
                    title: "이름",
                    isRequired: true,
                    placeholder: "이름을 입력해주세요",
                    helperText: "이름 그대로 작성해주세요",
                    maxCount: 10,
                    state: store.isNameReadOnly ? .readOnly : .default,
                    text: $store.name
                )
                .padding(.top, Spacing.spacing350)
                .padding(.horizontal, Spacing.spacing400)

                Color.clear.frame(maxHeight: .infinity)
            }

            BangawoButton(
                "다음",
                variant: .solid,
                size: .large,
                widthType: .maxWidth,
                isDisabled: !store.isNextEnabled
            ) {
                store.send(.nextButtonTapped)
            }
            .padding(.horizontal, Spacing.spacing450)
            .padding(.bottom, Spacing.spacing400)
        }
        .navigationBarBackButtonHidden(true)
        .sheet(
            item: $store.scope(state: \.imagePicker, action: \.imagePicker)
        ) { pickerStore in
            ProfileImagePickerSheet(store: pickerStore)
                .presentationDetents([.medium])
        }
        .onTapGesture {
            if isShowingMenu { isShowingMenu = false }
        }
    }
}

// MARK: - ProfileImageContainer

private struct ProfileImageContainer: View {
    let profileImage: ProfileImage
    @Binding var isShowingMenu: Bool
    let onMenuAlbumTapped: () -> Void
    let onMenuProfileSetupTapped: () -> Void

    var body: some View {
        Avatar(
            avatarType: avatarType(for: profileImage),
            size: .s124,
            iconType: .edit { isShowingMenu.toggle() }
        )
        .overlay(alignment: .topTrailing) {
            if isShowingMenu {
                DesignSystem.Menu(items: [
                    .init(
                        label: "프로필 설정하기",
                        icon: .Asset.icStar24,
                        iconColor: Colors.gray600
                    ) {
                        onMenuProfileSetupTapped()
                        isShowingMenu = false
                    },
                    .init(
                        label: "앨범에서 선택하기",
                        icon: .Asset.icAlbum24,
                        iconColor: Colors.gray500
                    ) {
                        onMenuAlbumTapped()
                        isShowingMenu = false
                    }
                ])
                .frame(width: 200)
                .offset(y: 132)
            }
        }
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing300)
    }

    private func avatarType(for profileImage: ProfileImage) -> Avatar.AvatarType {
        switch profileImage {
        case .none:
            return .placeholder
        case .data(let data):
            guard let uiImage = UIImage(data: data) else { return .placeholder }
            return .localImage(Image(uiImage: uiImage))
        case .preset:
            return .d3
        }
    }
}

#Preview {
    BangawoPreview {
        ProfileInputView(
            store: Store(initialState: ProfileInputFeature.State()) {
                ProfileInputFeature()
            }
        )
    }
}
