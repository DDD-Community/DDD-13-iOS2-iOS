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
            ForEach(Array(Asset.D3.profileFaces.enumerated()), id: \.offset) { index, face in
                Button {
                    onPresetTapped(index)
                } label: {
                    Asset(
                        assetType: .d3(face),
                        size: .s48,
                        isSelected: selectedIndex == index
                    )
                    .background(Circle().fill(Colors.gray300))
                }
                .buttonStyle(.plain)
            }
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
                Asset(assetType: .d3(.avatarPlaceholder), size: .s104)

            case let .data(data):
                if let uiImage = UIImage(data: data) {
                    Asset(assetType: .image(Image(uiImage: uiImage)), size: .s104)
                } else {
                    Asset(assetType: .d3(.avatarPlaceholder), size: .s104)
                }

            case let .preset(index):
                let face = Asset.D3.profileFaces.indices.contains(index)
                    ? Asset.D3.profileFaces[index]
                    : .avatarPlaceholder
                Asset(assetType: .d3(face), size: .s104)
            }
        }
        .background(Circle().fill(backgroundColor))
    }

    private var backgroundColor: Color {
        if case .preset = image { return Colors.gray300 }

        return Colors.gray200
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
