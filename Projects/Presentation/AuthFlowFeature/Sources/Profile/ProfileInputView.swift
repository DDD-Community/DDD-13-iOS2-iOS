//
//  ProfileInputView.swift
//  Presentation
//

import PhotosUI
import SwiftUI

import ComposableArchitecture

import DesignSystem

public struct ProfileInputView: View {
    @Bindable private var store: StoreOf<ProfileInputFeature>
    @State private var isShowingMenu = false
    @State private var isPhotosPickerPresented = false
    @State private var photoItem: PhotosPickerItem?

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
                    isShowingMenu: $isShowingMenu
                )

                TextInput(
                    title: "이름",
                    isRequired: true,
                    placeholder: "이름을 입력해 주세요.",
                    helperText: store.nameHelperText,
                    maxCount: 7,
                    state: store.isNameReadOnly ? .readOnly : store.nameInputState,
                    text: $store.name
                )
                .padding(.top, Spacing.spacing350)
                .padding(.horizontal, Spacing.spacing400)

                Color.clear.frame(maxHeight: .infinity)
            }
            .overlay {
                if isShowingMenu {
                    GeometryReader { geo in
                        DesignSystem.Menu(items: [
                            .init(
                                label: "프로필 설정하기",
                                icon: .Asset.icStar24,
                                iconColor: Colors.gray600
                            ) {
                                store.send(.avatarMenuProfileSetupTapped)
                                isShowingMenu = false
                            },
                            .init(
                                label: "앨범에서 선택하기",
                                icon: .Asset.icAlbum24,
                                iconColor: Colors.gray600
                            ) {
                                isPhotosPickerPresented = true
                                isShowingMenu = false
                            }
                        ])
                        .frame(width: Metric.menuWidth)
                        .offset(
                            // 아바타 오른쪽 끝 기준 정렬: (전체 너비 + 아바타 크기) / 2 - 메뉴 너비
                            x: (geo.size.width + Metric.avatarSize) / 2 - Metric.menuWidth,
                            y: Spacing.spacing400 + Metric.avatarSize + Spacing.spacing200
                        )
                    }
                }
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
        .bottomSheet(
            isPresented: Binding(
                get: { store.imagePicker != nil },
                set: { if !$0 { store.send(.imagePicker(.dismiss)) } }
            ),
            header: .init(
                title: "프로필 설정",
                onClose: { store.send(.imagePicker(.dismiss)) }
            ),
            contentVerticalPadding: Spacing.spacing400,
            primaryButton: .init(title: "변경하기") {
                store.send(.imagePicker(.presented(.saveButtonTapped)))
            },
            secondaryButton: .init(title: "삭제하기") {
                store.send(.imagePicker(.presented(.deleteButtonTapped)))
            }
        ) {
            if let pickerStore = $store.scope(state: \.imagePicker, action: \.imagePicker).wrappedValue {
                ProfileImagePickerSheet(store: pickerStore)
            }
        }
        .photosPicker(
            isPresented: $isPhotosPickerPresented,
            selection: $photoItem,
            matching: .images
        )
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }

            Task {
                let data = try? await newItem.loadTransferable(type: Data.self)
                await MainActor.run {
                    store.send(.avatarMenuAlbumImagePicked(data))
                    photoItem = nil
                }
            }
        }
        .onTapGesture {
            if isShowingMenu { isShowingMenu = false }
        }
    }
}

// MARK: - Metric

private enum Metric {
    static let menuWidth: CGFloat = 200
    static let avatarSize: CGFloat = 124
}

// MARK: - ProfileImageContainer

private struct ProfileImageContainer: View {
    let profileImage: ProfileImage
    @Binding var isShowingMenu: Bool

    var body: some View {
        Avatar(
            avatarType: avatarType(for: profileImage),
            size: .s124,
            iconType: .edit { isShowingMenu.toggle() }
        )
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
