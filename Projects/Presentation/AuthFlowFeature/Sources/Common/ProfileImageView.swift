//
//  ProfileImageView.swift
//  Presentation
//
//  ProfileImage를 시각화하는 공용 컴포넌트
//

import SwiftUI

struct ProfileImageDisplay: View {
    private let image: ProfileImage
    private let size: CGFloat

    init(image: ProfileImage, size: CGFloat) {
        self.image = image
        self.size = size
    }

    var body: some View {
        Group {
            switch image {
            case .none:
                Circle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(size * 0.25)
                            .foregroundStyle(Color(.systemGray2))
                    )

            case let .data(data):
                if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Circle().fill(Color(.systemGray5))
                }

            case let .preset(index):
                Circle()
                    .fill(Color(.systemGray6))
                    .overlay(
                        Text("3D face\n\(index + 1)")
                            .font(.system(size: size * 0.18, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color(.systemGray))
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
