//
//  Avatar.swift
//  DesignSystem
//

import SwiftUI

public struct Avatar: View {
    // MARK: - Properties

    private let avatarType: AvatarType
    private let size: Size
    private let iconType: IconType?

    // MARK: - Init

    public init(
        avatarType: AvatarType,
        size: Size,
        iconType: IconType? = nil
    ) {
        self.avatarType = avatarType
        self.size = size
        self.iconType = iconType
    }

    // MARK: - Body

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            avatarContent
            if let iconType {
                IconArea(iconType: iconType, size: size)
            }
        }
        .frame(width: size.length, height: size.length)
    }

    // MARK: - Avatar Content

    @ViewBuilder
    private var avatarContent: some View {
        switch avatarType {
        case .d3:
            CircleBackground(size: size) {
                Image.Asset.imgAvatar3d
                    .resizable()
                    .scaledToFit()
            }

        case .image(let url):
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.length, height: size.length)
                        .clipShape(Circle())
                default:
                    Circle()
                        .fill(Colors.gray200)
                        .frame(width: size.length, height: size.length)
                }
            }

        case .placeholder:
            CircleBackground(size: size) {
                Image.Asset.imgAvatarPlaceholder
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

// MARK: - CircleBackground

private struct CircleBackground<Content: View>: View {
    let size: Avatar.Size
    let content: () -> Content

    init(size: Avatar.Size, @ViewBuilder content: @escaping () -> Content) {
        self.size = size
        self.content = content
    }

    var body: some View {
        Circle()
            .fill(Colors.gray200)
            .frame(width: size.length, height: size.length)
            .overlay {
                content()
                    .padding(size.backgroundPadding)
            }
    }
}

// MARK: - IconArea

private struct IconArea: View {
    let iconType: Avatar.IconType
    let size: Avatar.Size

    var body: some View {
        ZStack {
            Circle()
                .fill(Colors.gray00)
                .frame(
                    width: size.iconCircleSize + size.iconBorderWidth * 2,
                    height: size.iconCircleSize + size.iconBorderWidth * 2
                )
            Circle()
                .fill(iconType.backgroundColor)
                .frame(width: size.iconCircleSize, height: size.iconCircleSize)
            iconType.icon
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(Colors.gray00)
                .frame(width: size.iconSize, height: size.iconSize)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            BangawoText("3D Avatar", textStyle: .titleLarge)
            HStack(spacing: 12) {
                ForEach(Avatar.Size.allCases, id: \.length) { size in
                    Avatar(avatarType: .d3, size: size)
                }
            }

            Divider()

            BangawoText("Placeholder Avatar", textStyle: .titleLarge)
            HStack(spacing: 12) {
                ForEach(Avatar.Size.allCases, id: \.length) { size in
                    Avatar(avatarType: .placeholder, size: size)
                }
            }

            Divider()

            BangawoText("Icon Types (size 56)", textStyle: .titleLarge)
            HStack(spacing: 16) {
                Avatar(avatarType: .placeholder, size: .s56, iconType: .host)
                Avatar(avatarType: .placeholder, size: .s56, iconType: .pin)
                Avatar(avatarType: .placeholder, size: .s56, iconType: .edit)
                Avatar(avatarType: .placeholder, size: .s56, iconType: .star)
            }

            Divider()

            BangawoText("Icon Sizes (host)", textStyle: .titleLarge)
            HStack(spacing: 12) {
                ForEach(Avatar.Size.allCases, id: \.length) { size in
                    Avatar(avatarType: .placeholder, size: size, iconType: .host)
                }
            }
        }
        .padding(24)
    }
}
