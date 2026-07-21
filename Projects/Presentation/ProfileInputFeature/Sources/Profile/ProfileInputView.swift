import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

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
                title: store.navigationTitle
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
                    maxCount: Metric.maxNameCount,
                    state: store.nameInputState,
                    text: $store.name
                )
                .padding(.top, Spacing.spacing350)
                .padding(.horizontal, Spacing.spacing400)

                Color.clear.frame(maxHeight: .infinity)
            }
            .overlay {
                ProfileMenu(
                    isShowingMenu: $isShowingMenu,
                    isPhotosPickerPresented: $isPhotosPickerPresented,
                    store: store
                )
            }

            BangawoButton(
                store.submitButtonTitle,
                variant: .solid,
                size: .large,
                widthType: .maxWidth,
                isLoading: store.isProfileUpdating,
                isDisabled: !store.isNextEnabled
            ) {
                store.send(.nextButtonTapped)
            }
            .padding(.horizontal, Spacing.spacing450)
            .padding(.bottom, Spacing.spacing400)
        }
        .bottomSheet(
            isPresented: imagePickerBinding,
            header: .init(
                title: "프로필 설정",
                onClose: { store.send(.imagePicker(.dismiss)) }
            ),
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
                let contentType = newItem.supportedContentTypes.first?.preferredMIMEType ?? "image/jpeg"
                await MainActor.run {
                    store.send(.avatarMenuAlbumImagePicked(data, contentType: contentType))
                    photoItem = nil
                }
            }
        }
        .onTapGesture {
            if isShowingMenu { isShowingMenu = false }
        }
        .dismissKeyboardOnTap()
        .toolbar(.hidden, for: .navigationBar)
        .alert($store.scope(state: \.alert, action: \.alert))
    }

    private var imagePickerBinding: Binding<Bool> {
        Binding(
            get: { store.imagePicker != nil },
            set: {
                if !$0, store.imagePicker != nil {
                    store.send(.imagePicker(.dismiss))
                }
            }
        )
    }
}

private enum Metric {
    static let maxNameCount = 7
    static let menuWidth: CGFloat = 200
    static let avatarSize: CGFloat = 124
}

private struct ProfileMenu: View {
    @Binding var isShowingMenu: Bool
    @Binding var isPhotosPickerPresented: Bool
    let store: StoreOf<ProfileInputFeature>

    var body: some View {
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
                    x: (geo.size.width + Metric.avatarSize) / 2 - Metric.menuWidth,
                    y: Spacing.spacing400 + Metric.avatarSize + Spacing.spacing200
                )
            }
        }
    }
}

private struct ProfileImageContainer: View {
    let profileImage: ProfileImage
    @Binding var isShowingMenu: Bool

    var body: some View {
        Avatar(
            avatarType: avatarType,
            size: .s124,
            iconType: .edit { isShowingMenu.toggle() }
        )
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing300)
    }

    private var avatarType: Avatar.AvatarType {
        switch profileImage {
        case .none:
            return .placeholder
        case let .data(data, _):
            guard let uiImage = UIImage(data: data) else { return .placeholder }
            return .localImage(Image(uiImage: uiImage))
        case let .preset(index):
            let face = Asset.D3.profileFaces.indices.contains(index)
                ? Asset.D3.profileFaces[index]
                : .avatarPlaceholder
            return .d3(face)
        case let .remote(urlString):
            guard let url = URL(string: urlString) else { return .placeholder }
            return .image(url)
        }
    }
}
