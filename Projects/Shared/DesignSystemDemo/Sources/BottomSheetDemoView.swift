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
                KeyboardSection()
                SectionDivider("Overlay 방식")
                OverlayKeyboardSection()
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
        .bottomSheet(isPresented: $isPresented) {
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
        .bottomSheet(
            isPresented: $isPresented,
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: { isPresented = false }
            )
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
        .bottomSheet(
            isPresented: $isPresented,
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: { isPresented = false }
            ),
            primaryButton: .init(title: "확인") { isPresented = false }
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
        .bottomSheet(
            isPresented: $isPresented,
            header: .init(
                title: "제목입니다",
                description: "설명 텍스트가 여기에 표시됩니다.",
                onClose: { isPresented = false }
            ),
            primaryButton: .init(title: "확인") { isPresented = false },
            secondaryButton: .init(title: "취소") { isPresented = false }
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
        .bottomSheet(
            isPresented: $isPresented,
            header: .init(title: "스크롤 테스트", onClose: { isPresented = false }),
            primaryButton: .init(title: "확인") { isPresented = false }
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

// MARK: - KeyboardSection

private struct KeyboardSection: View {
    @State private var isPresented = false
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Keyboard")
            VStack(spacing: 0) {
                DemoRow("키보드 + TextField") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .bottomSheet(
            isPresented: $isPresented,
            header: .init(title: "키보드 테스트", onClose: { isPresented = false }),
            primaryButton: .init(title: "확인") { isPresented = false }
        ) {
            TextField("입력하세요", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - SectionDivider

private struct SectionDivider: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }
}

// MARK: - OverlayKeyboardSection

private struct OverlayKeyboardSection: View {
    @State private var isPresented = false
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Keyboard")
            VStack(spacing: 0) {
                DemoRow("키보드 + TextField") {
                    BangawoButton("열기", variant: .weak, size: .small) {
                        isPresented = true
                    }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
        .customBottomSheet(
            isPresented: $isPresented,
            header: .init(title: "키보드 테스트 (Overlay)", onClose: { isPresented = false }),
            primaryButton: .init(title: "확인") { isPresented = false }
        ) {
            TextField("입력하세요", text: $text)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BottomSheetDemoView()
    }
}
