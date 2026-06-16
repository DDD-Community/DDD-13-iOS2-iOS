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
            AvatarContent(avatarType: avatarType, size: size)
            if let iconType {
                IconArea(iconType: iconType, size: size)
            }
        }
        .frame(width: size.length, height: size.length)
    }
}

// MARK: - AvatarContent

private struct AvatarContent: View {
    let avatarType: Avatar.AvatarType
    let size: Avatar.Size

    var body: some View {
        Group {
            switch avatarType {
            case .d3(let asset):
                asset.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size.length, height: size.length)
                    .background(Colors.gray200)

            case .image(let url):
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Circle()
                            .fill(Colors.gray200)
                    }
                }

            case .placeholder:
                Circle()
                    .fill(Colors.gray200)
                    .overlay {
                        Image.Asset.imgAvatarPlaceholder
                            .resizable()
                            .scaledToFit()
                            .padding(size.backgroundPadding)
                    }

            case .localImage(let image):
                image
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size.length, height: size.length)
        .clipShape(Circle())
    }
}

// MARK: - IconArea

private struct IconArea: View {
    let iconType: Avatar.IconType
    let size: Avatar.Size

    var body: some View {
        // .edit 타입만 인터랙티브 — 나머지(host, pin, star)는 비인터랙티브 뱃지
        if case .edit(let action) = iconType {
            Button(action: action) { iconCircle }
                .buttonStyle(.plain)
        } else {
            iconCircle
        }
    }

    private var iconCircle: some View {
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
    ScrollView([.vertical, .horizontal]) {
        VStack(alignment: .leading, spacing: 32) {
            BangawoText("3D Avatar", textStyle: .titleLarge)
            HStack(spacing: 12) {
                ForEach(Avatar.Size.allCases, id: \.length) { size in
                    Avatar(avatarType: .d3(.face01), size: size)
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
                Avatar(avatarType: .placeholder, size: .s56, iconType: .edit(action: {}))
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
