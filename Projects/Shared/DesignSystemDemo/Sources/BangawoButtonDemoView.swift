import SwiftUI

import DesignSystem

struct BangawoButtonDemoView: View {
    @State private var isLoading = false
    @State private var isDisabled = false
    @State private var widthType: BangawoButton.WidthType = .default

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                ControlSection(isLoading: $isLoading, isDisabled: $isDisabled, widthType: $widthType)
                VariantSection(
                    "weak", variant: .weak,
                    isLoading: isLoading, isDisabled: isDisabled,
                    widthType: widthType
                )
                VariantSection(
                    "solid", variant: .solid,
                    isLoading: isLoading, isDisabled: isDisabled,
                    widthType: widthType
                )
                KeyboardSection(isLoading: isLoading, isDisabled: isDisabled)
                CustomBackgroundSection(
                    isLoading: isLoading,
                    isDisabled: isDisabled,
                    widthType: widthType
                )
            }
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Button")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ControlSection

private struct ControlSection: View {
    @Binding private var isLoading: Bool
    @Binding private var isDisabled: Bool
    @Binding private var widthType: BangawoButton.WidthType

    init(
        isLoading: Binding<Bool>,
        isDisabled: Binding<Bool>,
        widthType: Binding<BangawoButton.WidthType>
    ) {
        self._isLoading = isLoading
        self._isDisabled = isDisabled
        self._widthType = widthType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("Controls")

            VStack(spacing: 0) {
                Toggle("Loading", isOn: $isLoading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                RowDivider()

                Toggle("Disabled", isOn: $isDisabled)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                RowDivider()

                VStack(alignment: .leading, spacing: 8) {
                    BangawoText("Width", textStyle: .bodyLarge)
                    Picker("Width", selection: $widthType) {
                        BangawoText("Default", textStyle: .bodyMedium).tag(BangawoButton.WidthType.default)
                        BangawoText("MaxWidth", textStyle: .bodyMedium).tag(BangawoButton.WidthType.maxWidth)
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

// MARK: - VariantSection

private struct VariantSection: View {
    private enum Sizes {
        static let all: [BangawoButton.Size] = [.xsmall, .small, .medium, .large]
        static let labels = ["xsmall", "small", "medium", "large"]
    }

    private let title: String
    private let variant: BangawoButton.Variant
    private let isLoading: Bool
    private let isDisabled: Bool
    private let widthType: BangawoButton.WidthType

    init(
        _ title: String,
        variant: BangawoButton.Variant,
        isLoading: Bool,
        isDisabled: Bool,
        widthType: BangawoButton.WidthType
    ) {
        self.title = title
        self.variant = variant
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.widthType = widthType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title)

            VStack(spacing: 0) {
                ForEach(0..<Sizes.all.count, id: \.self) { i in
                    HStack(alignment: .center, spacing: 12) {
                        BangawoText(Sizes.labels[i], textStyle: .labelSmall)
                            .foregroundStyle(.secondary)
                            .frame(width: 52, alignment: .leading)

                        ButtonItem(
                            "Label",
                            variant: variant,
                            size: Sizes.all[i],
                            isLoading: isLoading,
                            isDisabled: isDisabled,
                            widthType: widthType
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if i < Sizes.all.count - 1 { RowDivider() }
                }
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - KeyboardSection

private struct KeyboardSection: View {
    private let isLoading: Bool
    private let isDisabled: Bool

    init(isLoading: Bool, isDisabled: Bool) {
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("keyboard attached")
                .padding(.horizontal, 20)

            BangawoButton(
                "Label",
                variant: .solid,
                size: .medium,
                isLoading: isLoading,
                isDisabled: isDisabled,
                isKeyboardAttached: true
            ) {}
        }
    }
}

// MARK: - CustomBackgroundSection

private struct CustomBackgroundSection: View {
    private let isLoading: Bool
    private let isDisabled: Bool
    private let widthType: BangawoButton.WidthType

    init(
        isLoading: Bool,
        isDisabled: Bool,
        widthType: BangawoButton.WidthType
    ) {
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.widthType = widthType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader("custom background")

            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {
                    BangawoText("blue", textStyle: .labelSmall)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .leading)

                    ButtonItem(
                        "Label",
                        variant: .weak,
                        size: .small,
                        customBackground: .blue,
                        isLoading: isLoading,
                        isDisabled: isDisabled,
                        widthType: widthType
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                RowDivider()

                HStack(alignment: .center, spacing: 12) {
                    BangawoText("red", textStyle: .labelSmall)
                        .foregroundStyle(.secondary)
                        .frame(width: 52, alignment: .leading)

                    ButtonItem(
                        "Label",
                        variant: .solid,
                        size: .small,
                        customBackground: .red,
                        isLoading: isLoading,
                        isDisabled: isDisabled,
                        widthType: widthType
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .card()
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - ButtonItem

private struct ButtonItem: View {
    private let title: String
    private let variant: BangawoButton.Variant
    private let size: BangawoButton.Size
    private let customBackground: Color?
    private let isLoading: Bool
    private let isDisabled: Bool
    private let widthType: BangawoButton.WidthType

    init(
        _ title: String,
        variant: BangawoButton.Variant,
        size: BangawoButton.Size,
        customBackground: Color? = nil,
        isLoading: Bool,
        isDisabled: Bool,
        widthType: BangawoButton.WidthType
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.customBackground = customBackground
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.widthType = widthType
    }

    var body: some View {
        BangawoButton(
            title,
            variant: variant,
            size: size,
            widthType: widthType,
            isLoading: isLoading,
            isDisabled: isDisabled,
            customBackgroundColor: customBackground
        ) {}
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BangawoButtonDemoView()
    }
}
