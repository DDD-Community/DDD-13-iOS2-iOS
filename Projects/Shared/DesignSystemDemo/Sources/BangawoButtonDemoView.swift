import SwiftUI
import DesignSystem

struct BangawoButtonDemoView: View {
    @State private var isLoading = false
    @State private var isDisabled = false
    @State private var widthType: BangawoButton.WidthType = .default

    private let sizeLabels = ["xsmall", "small", "medium", "large"]
    private let sizes: [BangawoButton.Size] = [.xsmall, .small, .medium, .large]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                controlSection
                variantSection("weak", variant: .weak)
                variantSection("solid", variant: .solid)
                keyboardSection
                customBackgroundSection
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Button")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Controls

    private var controlSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("Controls")

            VStack(spacing: 0) {
                Toggle("Loading", isOn: $isLoading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                rowDivider()

                Toggle("Disabled", isOn: $isDisabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                rowDivider()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Width")
                        .font(.body)
                    Picker("Width", selection: $widthType) {
                        Text("Default").tag(BangawoButton.WidthType.default)
                        Text("MaxWidth").tag(BangawoButton.WidthType.maxWidth)
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

    // MARK: - Variant Section

    private func variantSection(_ title: String, variant: BangawoButton.Variant) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader(title)

            VStack(spacing: 0) {
                ForEach(0..<sizes.count, id: \.self) { i in
                    HStack(alignment: .center, spacing: 12) {
                        Text(sizeLabels[i])
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 52, alignment: .leading)

                        buttonView("Label", variant: variant, size: sizes[i])
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if i < sizes.count - 1 { rowDivider() }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Keyboard Attached

    private var keyboardSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("keyboard attached")
                .padding(.horizontal, 20)

            BangawoButton("Label", variant: .solid, size: .medium) {}
                .loading(isLoading)
                .disabled(isDisabled)
                .keyboardAttached()
        }
    }

    // MARK: - Custom Background

    private var customBackgroundSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionHeader("custom background")

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    Text("blue")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .leading)

                    buttonView("Label", variant: .weak, size: .small, customBackground: .blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                rowDivider()

                HStack(alignment: .center, spacing: 12) {
                    Text("red")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .leading)

                    buttonView("Label", variant: .solid, size: .small, customBackground: .red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .card()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Helpers

    private func buttonView(
        _ title: String,
        variant: BangawoButton.Variant,
        size: BangawoButton.Size,
        customBackground: Color? = nil
    ) -> some View {
        let base = BangawoButton(title, variant: variant, size: size) {}
            .loading(isLoading)
            .disabled(isDisabled)
            .buttonWidth(widthType)

        if let bg = customBackground {
            return base.buttonBackgroundColor(bg)
        } else {
            return base
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.leading, 4)
    }

    private func rowDivider() -> some View {
        Divider().padding(.leading, 16)
    }
}

// MARK: - Card ViewModifier

private extension View {
    func card() -> some View {
        self
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BangawoButtonDemoView()
    }
}
