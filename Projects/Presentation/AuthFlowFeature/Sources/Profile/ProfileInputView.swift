//
//  ProfileInputView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture

public struct ProfileInputView: View {
    @Bindable private var store: StoreOf<ProfileInputFeature>

    public init(store: StoreOf<ProfileInputFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("반가워요 \(store.greetingName)님")
                .font(.title2.bold())
                .padding(.top, 16)

            ProfileImageThumbnail(image: store.profileImage) {
                store.send(.profileImageTapped)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            NicknameField(
                nickname: $store.nickname,
                onClear: { store.send(.clearNicknameButtonTapped) }
            )

            Color.clear.frame(maxHeight: .infinity)

            PrimaryFilledButton(
                title: "다음",
                isEnabled: store.isNextEnabled
            ) {
                store.send(.nextButtonTapped)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .sheet(
            item: $store.scope(state: \.imagePicker, action: \.imagePicker)
        ) { pickerStore in
            ProfileImagePickerSheet(store: pickerStore)
                .presentationDetents([.medium])
        }
    }
}

struct ProfileImageThumbnail: View {
    private let image: ProfileImage
    private let action: () -> Void

    init(image: ProfileImage, action: @escaping () -> Void) {
        self.image = image
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomTrailing) {
                ProfileImageDisplay(image: image, size: 120)
                CameraOverlayBadge()
            }
        }
        .buttonStyle(.plain)
    }
}

struct CameraOverlayBadge: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .frame(width: 36, height: 36)
            .overlay(
                Image(systemName: "camera.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.black)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct NicknameField: View {
    @Binding private var nickname: String
    private let onClear: () -> Void

    init(nickname: Binding<String>, onClear: @escaping () -> Void) {
        self._nickname = nickname
        self.onClear = onClear
    }

    var body: some View {
        HStack(spacing: 8) {
            TextField("닉네임을 입력해주세요", text: $nickname)
                .textFieldStyle(.plain)
                .submitLabel(.done)

            if !nickname.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(.systemGray3))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 14)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
    }
}
