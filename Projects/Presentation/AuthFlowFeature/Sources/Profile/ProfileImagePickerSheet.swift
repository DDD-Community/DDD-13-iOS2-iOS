//
//  ProfileImagePickerSheet.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import PhotosUI
import AVFoundation
import Photos

struct ProfileImagePickerSheet: View {
    @Bindable var store: StoreOf<ProfileImagePickerFeature>

    @State private var isCameraPresented = false
    @State private var isPhotosPickerPresented = false
    @State private var photoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 24) {
            DragHandle()

            ProfileImageDisplay(image: store.candidate, size: 120)

            ProfileTileGrid(
                onCameraTapped: requestCameraPermission,
                onGalleryTapped: requestPhotoLibraryPermission,
                onPresetTapped: { index in store.send(.presetSelected(index: index)) }
            )

            HStack(spacing: 12) {
                PrimaryOutlinedButton(title: "프로필 삭제") {
                    store.send(.deleteButtonTapped)
                }
                PrimaryFilledButton(title: "저장하기") {
                    store.send(.saveButtonTapped)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .fullScreenCover(isPresented: $isCameraPresented) {
            CameraCapturePicker { data in
                store.send(.cameraImagePicked(data))
            }
            .ignoresSafeArea()
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
                    store.send(.galleryImagePicked(data))
                    photoItem = nil
                }
            }
        }
        .alert(
            store.permissionAlert?.title ?? "",
            isPresented: Binding(
                get: { store.permissionAlert != nil },
                set: { isPresented in
                    if !isPresented { store.send(.permissionAlertDismissed) }
                }
            ),
            presenting: store.permissionAlert
        ) { _ in
            Button("설정으로 이동") { store.send(.openSettingsTapped) }
            Button("닫기", role: .cancel) { store.send(.permissionAlertDismissed) }
        } message: { config in
            Text(config.message)
        }
    }

    private func requestCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            isCameraPresented = true

        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    if granted {
                        isCameraPresented = true
                    } else {
                        store.send(.cameraPermissionDenied)
                    }
                }
            }

        case .denied, .restricted:
            store.send(.cameraPermissionDenied)

        @unknown default:
            store.send(.cameraPermissionDenied)
        }
    }

    private func requestPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            isPhotosPickerPresented = true

        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                Task { @MainActor in
                    switch newStatus {
                    case .authorized, .limited:
                        isPhotosPickerPresented = true

                    default:
                        store.send(.photoLibraryPermissionDenied)
                    }
                }
            }

        case .denied, .restricted:
            store.send(.photoLibraryPermissionDenied)

        @unknown default:
            store.send(.photoLibraryPermissionDenied)
        }
    }
}

struct DragHandle: View {
    var body: some View {
        Capsule()
            .fill(Color(.systemGray4))
            .frame(width: 40, height: 4)
            .padding(.top, 8)
    }
}

struct ProfileTileGrid: View {
    private let onCameraTapped: () -> Void
    private let onGalleryTapped: () -> Void
    private let onPresetTapped: (Int) -> Void

    init(
        onCameraTapped: @escaping () -> Void,
        onGalleryTapped: @escaping () -> Void,
        onPresetTapped: @escaping (Int) -> Void
    ) {
        self.onCameraTapped = onCameraTapped
        self.onGalleryTapped = onGalleryTapped
        self.onPresetTapped = onPresetTapped
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)
        LazyVGrid(columns: columns, spacing: 12) {
            ProfileTile(systemImage: "camera.fill", label: "카메라", action: onCameraTapped)
            ProfileTile(systemImage: "photo.on.rectangle", label: "갤러리", action: onGalleryTapped)
            ForEach(0..<ProfileImagePickerFeature.presetCount, id: \.self) { index in
                PresetTile(index: index) { onPresetTapped(index) }
            }
        }
    }
}

struct ProfileTile: View {
    private let systemImage: String
    private let label: String
    private let action: () -> Void

    init(systemImage: String, label: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.label = label
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                Text(label)
                    .font(.system(size: 11))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

struct PresetTile: View {
    private let index: Int
    private let action: () -> Void

    init(index: Int, action: @escaping () -> Void) {
        self.index = index
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("3D face")
                    .font(.system(size: 12, weight: .semibold))
                Text("\(index + 1)")
                    .font(.system(size: 12))
            }
            .foregroundStyle(Color(.systemGray))
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
