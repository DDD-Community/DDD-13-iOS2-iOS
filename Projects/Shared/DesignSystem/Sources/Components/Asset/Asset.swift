//
//  Asset.swift
//  DesignSystem
//

import SwiftUI

public struct Asset: View {
    // MARK: - Properties

    private let assetType: AssetType
    private let size: Size
    private let isSelected: Bool

    // MARK: - Init

    public init(
        assetType: AssetType,
        size: Size,
        isSelected: Bool = false
    ) {
        self.assetType = assetType
        self.size = size
        self.isSelected = isSelected
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch assetType {
            case .d3(let d3):
                d3.image
                    .resizable()
                    .scaledToFit()

            case .image(let image):
                image
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: size.length, height: size.length)
        .overlay {
            if isSelected {
                SelectedOverlay(checkBoxLength: size.selectionCheckBoxLength)
            }
        }
    }
}

private struct SelectedOverlay: View {
    let checkBoxLength: CGFloat

    var body: some View {
        Circle()
            .fill(Colors.grayAlpha500)
            .overlay {
                Image.Asset.icCheckboxGhostEnabledMd
                    .resizable()
                    .frame(width: checkBoxLength, height: checkBoxLength)
                    .foregroundStyle(Colors.gray00)
            }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 32) {
            BangawoText("3D Asset (fit)", textStyle: .titleLarge)

            HStack(spacing: 16) {
                Asset(assetType: .d3(.face01), size: .s32)
                Asset(assetType: .d3(.face01), size: .s64)
                Asset(assetType: .d3(.face01), size: .s104)
            }

            Divider()

            BangawoText("Image Asset (fill + circle)", textStyle: .titleLarge)

            HStack(spacing: 16) {
                Asset(assetType: .image(Image(systemName: "person.fill")), size: .s32)
                Asset(assetType: .image(Image(systemName: "person.fill")), size: .s64)
                Asset(assetType: .image(Image(systemName: "person.fill")), size: .s104)
            }

            Divider()

            BangawoText("All Sizes (image)", textStyle: .titleLarge)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach([Asset.Size.s32, .s40, .s48, .s64, .s82, .s104, .s124], id: \.length) { size in
                    Asset(assetType: .image(Image(systemName: "person.fill")), size: size)
                }
            }
        }
        .padding(24)
    }
}
