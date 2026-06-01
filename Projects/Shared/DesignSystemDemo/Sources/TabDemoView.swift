import SwiftUI

import DesignSystem

struct TabDemoView: View {
    @State private var variant: TabVariant = .fixed
    @State private var size: TabSize = .small
    @State private var selectedIndex = 0

    private var labels: [String] {
        variant == .fixed
            ? ["탭 1", "탭 2", "탭 3"]
            : ["전체", "모임", "스터디", "운동", "독서", "여행"]
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ControlSection(variant: $variant, size: $size)
                PreviewSection(
                    labels: labels,
                    selectedIndex: $selectedIndex,
                    variant: variant,
                    size: size
                )
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Tab")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: variant) { _, _ in selectedIndex = 0 }
    }
}

// MARK: - ControlSection

private struct ControlSection: View {
    @Binding private var variant: TabVariant
    @Binding private var size: TabSize

    init(variant: Binding<TabVariant>, size: Binding<TabSize>) {
        self._variant = variant
        self._size = size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Controls")

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    BangawoText("Variant", textStyle: .bodyLarge)
                    Picker("Variant", selection: $variant) {
                        BangawoText("fixed", textStyle: .bodyMedium).tag(TabVariant.fixed)
                        BangawoText("scrollable", textStyle: .bodyMedium).tag(TabVariant.scrollable)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                RowDivider()

                VStack(alignment: .leading, spacing: 8) {
                    BangawoText("Size", textStyle: .bodyLarge)
                    Picker("Size", selection: $size) {
                        BangawoText("small", textStyle: .bodyMedium).tag(TabSize.small)
                        BangawoText("large", textStyle: .bodyMedium).tag(TabSize.large)
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - PreviewSection

private struct PreviewSection: View {
    private let labels: [String]
    @Binding private var selectedIndex: Int
    private let variant: TabVariant
    private let size: TabSize

    init(
        labels: [String],
        selectedIndex: Binding<Int>,
        variant: TabVariant,
        size: TabSize
    ) {
        self.labels = labels
        self._selectedIndex = selectedIndex
        self.variant = variant
        self.size = size
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Preview")

            VStack(spacing: 0) {
                Tab(
                    labels: labels,
                    selectedIndex: $selectedIndex,
                    variant: variant,
                    size: size
                )

                BangawoText("선택된 탭: \(labels[selectedIndex])", textStyle: .bodyMedium)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TabDemoView()
    }
}
