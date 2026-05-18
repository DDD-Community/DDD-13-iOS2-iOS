import SwiftUI
import DesignSystem

struct AssetDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                AssetTypeSection("3d", assetType: .d3)
                AssetTypeSection("image", assetType: .image)
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Asset")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - AssetTypeSection

private struct AssetTypeSection: View {
    private let title: String
    private let assetType: AssetKind

    init(_ title: String, assetType: AssetKind) {
        self.title = title
        self.assetType = assetType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)
            VStack(spacing: 0) {
                ForEach(AssetSizeRow.allCases) { row in
                    DemoRow(row.label) {
                        row.makeAsset(assetType: assetType)
                    }
                    if row != AssetSizeRow.allCases.last {
                        RowDivider()
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - AssetKind

private enum AssetKind {
    case d3
    case image
}

// MARK: - AssetSizeRow

private enum AssetSizeRow: CaseIterable, Identifiable {
    case s32, s40, s48, s64, s82, s104, s124, s280

    var id: Self { self }

    var label: String {
        switch self {
        case .s32: return "32"
        case .s40: return "40"
        case .s48: return "48"
        case .s64: return "64"
        case .s82: return "82"
        case .s104: return "104"
        case .s124: return "124"
        case .s280: return "280"
        }
    }

    var size: Asset.Size {
        switch self {
        case .s32: return .s32
        case .s40: return .s40
        case .s48: return .s48
        case .s64: return .s64
        case .s82: return .s82
        case .s104: return .s104
        case .s124: return .s124
        case .s280: return .s280
        }
    }

    @ViewBuilder
    func makeAsset(assetType: AssetKind) -> some View {
        switch assetType {
        case .d3:
            Asset(assetType: .d3(Image(systemName: "cube.fill")), size: size)
        case .image:
            Asset(assetType: .image(Image(systemName: "person.fill")), size: size)
        }
    }
}

#Preview {
    NavigationStack {
        AssetDemoView()
    }
}
