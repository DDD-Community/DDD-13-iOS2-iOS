import SwiftUI

import DesignSystem

struct AvatarDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                AvatarTypeSection()
                IconTypeSection()
                SizeSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Avatar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - AvatarTypeSection

private struct AvatarTypeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("type")
            VStack(spacing: 0) {
                DemoRow("d3") {
                    HStack(spacing: 8) {
                        Avatar(avatarType: .d3, size: .s32)
                        Avatar(avatarType: .d3, size: .s40)
                        Avatar(avatarType: .d3, size: .s56)
                    }
                }
                RowDivider()
                DemoRow("placeholder") {
                    HStack(spacing: 8) {
                        Avatar(avatarType: .placeholder, size: .s32)
                        Avatar(avatarType: .placeholder, size: .s40)
                        Avatar(avatarType: .placeholder, size: .s56)
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - IconTypeSection

private struct IconTypeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("icon type (s56)")
            VStack(spacing: 0) {
                DemoRow("host") { Avatar(avatarType: .placeholder, size: .s56, iconType: .host) }
                RowDivider()
                DemoRow("pin") { Avatar(avatarType: .placeholder, size: .s56, iconType: .pin) }
                RowDivider()
                DemoRow("edit") { Avatar(avatarType: .placeholder, size: .s56, iconType: .edit(action: {})) }
                RowDivider()
                DemoRow("star") { Avatar(avatarType: .placeholder, size: .s56, iconType: .star) }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - SizeSection

private struct SizeSection: View {
    private let sizes = Avatar.Size.allCases

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("size (host icon)")
            VStack(spacing: 0) {
                ForEach(Array(sizes.enumerated()), id: \.offset) { index, size in
                    DemoRow("s\(Int(size.length))") {
                        Avatar(avatarType: .placeholder, size: size, iconType: .host)
                    }
                    if index < sizes.count - 1 { RowDivider() }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        AvatarDemoView()
    }
}
