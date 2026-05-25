//
//  ProfileImageView.swift
//  Presentation
//
//  ProfileImage를 시각화하는 공용 컴포넌트
//

import SwiftUI

import DesignSystem

struct ProfileImageDisplay: View {
    private let image: ProfileImage

    init(image: ProfileImage) {
        self.image = image
    }

    var body: some View {
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
}
