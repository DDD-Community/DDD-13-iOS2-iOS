import SwiftUI

import DesignSystem

struct BottomSheetDemoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ContentOnlySection()
                HeaderOnlySection()
                SingleButtonSection()
                DoubleButtonSection()
                ScrollableSection()
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("BottomSheet")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ContentOnlySection

private struct ContentOnlySection: View {
    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Content Only")
            VStack(spacing: 0) {
                DemoRow("헤더·버튼 없음") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .bangawoBottomSheet(isPresented: $isPresented, contentVerticalPadding: Spacing.spacing400) {
            Text("컨텐츠만 있는 시트입니다.")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - HeaderOnlySection

private struct HeaderOnlySection: View {
    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Header Only")
            VStack(spacing: 0) {
                DemoRow("헤더 + 닫기 버튼") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .bangawoBottomSheet(
            isPresented: $isPresented,
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: { isPresented = false }
            ),
            contentVerticalPadding: Spacing.spacing400
        ) {
            Text("헤더만 있는 시트입니다.")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - SingleButtonSection

private struct SingleButtonSection: View {
    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Button 1")
            VStack(spacing: 0) {
                DemoRow("헤더 + 버튼 1개") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .bangawoBottomSheet(
            isPresented: $isPresented,
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: { isPresented = false }
            ),
            contentVerticalPadding: Spacing.spacing400,
            buttons: [.init(title: "확인") { isPresented = false }]
        ) {
            Text("버튼이 1개인 시트입니다.")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - DoubleButtonSection

private struct DoubleButtonSection: View {
    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Button 2")
            VStack(spacing: 0) {
                DemoRow("헤더 + 버튼 2개") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .bangawoBottomSheet(
            isPresented: $isPresented,
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: { isPresented = false }
            ),
            contentVerticalPadding: Spacing.spacing400,
            buttons: [
                .init(title: "취소") { isPresented = false },
                .init(title: "확인") { isPresented = false }
            ]
        ) {
            Text("버튼이 2개인 시트입니다.")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - ScrollableSection

private struct ScrollableSection: View {
    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Scrollable Content")
            VStack(spacing: 0) {
                DemoRow("콘텐츠 오버플로우") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .bangawoBottomSheet(
            isPresented: $isPresented,
            header: .init(title: "스크롤 테스트", onClose: { isPresented = false }),
            contentVerticalPadding: Spacing.spacing400,
            buttons: [.init(title: "확인") { isPresented = false }]
        ) {
            VStack(spacing: Spacing.spacing200) {
                ForEach(0..<10, id: \.self) { i in
                    Text("항목 \(i + 1)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BottomSheetDemoView()
    }
}
