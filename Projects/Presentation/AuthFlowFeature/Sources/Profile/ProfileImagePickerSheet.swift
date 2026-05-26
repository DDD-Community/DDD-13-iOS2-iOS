//
//  ProfileImagePickerSheet.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

struct ProfileImagePickerSheet: View {
    @Bindable var store: StoreOf<ProfileImagePickerFeature>

    var body: some View {
        VStack(spacing: Spacing.spacing400) {
            ProfileImageDisplay(image: store.candidate)

            ProfileTileGrid(
                selectedIndex: {
                    if case let .preset(index) = store.candidate { return index }
                    return nil
                }(),
                onPresetTapped: { index in store.send(.presetSelected(index: index)) }
            )
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileTileGrid: View {
    private let selectedIndex: Int?
    private let onPresetTapped: (Int) -> Void

    init(selectedIndex: Int?, onPresetTapped: @escaping (Int) -> Void) {
        self.selectedIndex = selectedIndex
        self.onPresetTapped = onPresetTapped
    }

    var body: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)
        LazyVGrid(columns: columns, spacing: Spacing.spacing400) {
            ForEach(0..<ProfileImagePickerFeature.presetCount, id: \.self) { index in
                Button {
                    onPresetTapped(index)
                } label: {
                    Asset(assetType: .d3(Image.Asset.imgAvatar3d), size: .s48)
                        .background(Circle().fill(Colors.grayAlpha200))
                        .overlay {
                            if selectedIndex == index {
                                ProfileTileSelectedOverlay()
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ProfileTileSelectedOverlay: View {
    var body: some View {
        Circle()
            .fill(Colors.grayAlpha500)
            .overlay {
                // TODO: 이미지 에셋으로 대체 예정
                Image(systemName: "checkmark")
                    .foregroundStyle(Colors.gray00)
            }
    }
}

private struct ProfileImageDisplay: View {
    private let image: ProfileImage

    init(image: ProfileImage) {
        self.image = image
    }

    var body: some View {
        Group {
            switch image {
            case .none:
                Asset(assetType: .d3(Image.Asset.imgAvatarPlaceholder), size: .s104)

            case let .data(data):
                if let uiImage = UIImage(data: data) {
                    Asset(assetType: .image(Image(uiImage: uiImage)), size: .s104)
                } else {
                    Asset(assetType: .d3(Image.Asset.imgAvatarPlaceholder), size: .s104)
                }

            case .preset:
                Asset(assetType: .d3(Image.Asset.imgAvatar3d), size: .s104)
            }
        }
        .background(Circle().fill(Colors.grayAlpha200))
    }
}

#Preview {
    ProfileImagePickerSheet(
        store: Store(initialState: ProfileImagePickerFeature.State(initialImage: .none)) {
            ProfileImagePickerFeature()
        }
    )
    .padding()
}
