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
                onPresetTapped: { index in store.send(.presetSelected(index: index)) }
            )
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileTileGrid: View {
    private let onPresetTapped: (Int) -> Void

    init(onPresetTapped: @escaping (Int) -> Void) {
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
                }
                .buttonStyle(.plain)
            }
        }
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
