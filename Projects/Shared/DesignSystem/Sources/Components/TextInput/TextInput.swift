//
//  TextInput.swift
//  DesignSystem
//

import SwiftUI

// MARK: - TextInput

public struct TextInput: View {
    private let type: TextInputType
    private let title: String?
    private let isRequired: Bool
    private let isOptional: Bool
    private let placeholder: String
    private let helperText: String?
    private let maxCount: Int?
    private let state: TextInputState

    @Binding private var text: String
    @FocusState private var isFocused: Bool

    public init(
        type: TextInputType = .textfield,
        title: String? = nil,
        isRequired: Bool = false,
        isOptional: Bool = false,
        placeholder: String = "",
        helperText: String? = nil,
        maxCount: Int? = nil,
        state: TextInputState = .default,
        text: Binding<String>
    ) {
        self.type = type
        self.title = title
        self.isRequired = isRequired
        self.isOptional = isOptional
        self.placeholder = placeholder
        self.helperText = helperText
        self.maxCount = maxCount
        self.state = state
        self._text = text
    }

    private var effectiveState: TextInputState {
        switch state {
        case .readOnly, .disabled, .error:
            return state
        default:
            if isFocused {
                return text.isEmpty ? .focused : .typing
            }
            return text.isEmpty ? .default : .typed
        }
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            if title != nil || isRequired || isOptional {
                TextInputTitleArea(
                    title: title,
                    isRequired: isRequired,
                    isOptional: isOptional
                )
            }

            switch type {
            case .textfield:
                TextInputFieldArea(
                    placeholder: placeholder,
                    state: effectiveState,
                    text: $text,
                    isFocused: $isFocused
                )
            case .datefield:
                // TODO: datefield 구현 예정
                EmptyView()
            case .timefield:
                // TODO: timefield 구현 예정
                EmptyView()
            }

            if helperText != nil || maxCount != nil {
                TextInputHelperArea(
                    helperText: helperText,
                    state: effectiveState,
                    currentCount: text.count,
                    maxCount: maxCount
                )
            }
        }
    }
}

// MARK: - TextInputTitleArea

private struct TextInputTitleArea: View {
    let title: String?
    let isRequired: Bool
    let isOptional: Bool

    var body: some View {
        HStack(spacing: 0) {
            if let title {
                Text(title)
                    .pretendardFont(family: .SemiBold, size: Typography.typographySize200)
                    .foregroundStyle(Colors.gray900)
                    .padding(.vertical, Spacing.spacing50)
            }
            if isRequired {
                Text("*")
                    .pretendardFont(family: .SemiBold, size: Typography.typographySize200)
                    .foregroundStyle(Colors.red500)
                    .padding(.vertical, Spacing.spacing50)
            }
            if isOptional {
                Text("(optional)")
                    .pretendardFont(family: .Medium, size: Typography.typographySize200)
                    .foregroundStyle(Colors.gray600)
                    .padding(.vertical, Spacing.spacing50)
                    .padding(.leading, Spacing.spacing100)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - TextInputFieldArea

private struct TextInputFieldArea: View {
    let placeholder: String
    let state: TextInputState
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool

    private var isInteractive: Bool {
        state != .readOnly && state != .disabled
    }

    private var textColor: Color {
        switch state {
        case .readOnly: return Colors.gray600
        case .disabled: return Colors.gray500
        default: return Colors.gray900
        }
    }

    var body: some View {
        TextInputContainer(state: state) {
            HStack(spacing: 0) {
                TextField(
                    text: $text,
                    prompt: Text(placeholder).foregroundStyle(Colors.gray500)
                ) {
                    EmptyView()
                }
                .pretendardFont(family: .Regular, size: Typography.typographySize300)
                .foregroundStyle(textColor)
                .padding(.vertical, Spacing.spacing50)
                .focused($isFocused)
                .disabled(!isInteractive)
                .tint(Colors.blue500)

                if !text.isEmpty && isInteractive {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Colors.gray400)
                    }
                    .padding(.leading, Spacing.spacing200)
                }
            }
        }
    }
}

// MARK: - TextInputContainer

private struct TextInputContainer<Content: View>: View {
    let state: TextInputState
    @ViewBuilder let content: () -> Content

    private var hasBorder: Bool {
        switch state {
        case .readOnly, .disabled: return false
        default: return true
        }
    }

    private var borderColor: Color {
        switch state {
        case .typing, .typed: return Colors.gray700
        case .error: return Colors.red600
        default: return Colors.gray200
        }
    }

    private var backgroundFill: Color {
        switch state {
        case .readOnly, .disabled: return Colors.gray200
        default: return .clear
        }
    }

    var body: some View {
        content()
            .padding(Spacing.spacing250)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                    .fill(backgroundFill)
            )
            .overlay {
                if hasBorder {
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                        .stroke(borderColor, lineWidth: BorderWidth.borderWidth150)
                }
            }
    }
}

// MARK: - TextInputHelperArea

private struct TextInputHelperArea: View {
    let helperText: String?
    let state: TextInputState
    let currentCount: Int
    let maxCount: Int?

    private var isError: Bool { state == .error }

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.spacing50) {
            if let helperText {
                if isError {
                    HStack(alignment: .top, spacing: Spacing.spacing50) {
                        Image.Asset.icCircleExclamation
                            .renderingMode(.template)
                            .foregroundStyle(Colors.red600)
                        Text(helperText)
                            .pretendardFont(family: .Regular, size: Typography.typographySize100)
                            .foregroundStyle(Colors.red600)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    Text(helperText)
                        .pretendardFont(family: .Regular, size: Typography.typographySize100)
                        .foregroundStyle(Colors.gray600)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Color.clear
                    .frame(maxWidth: .infinity)
            }

            if let maxCount {
                Text("\(currentCount)/\(maxCount)")
                    .pretendardFont(family: .Regular, size: Typography.typographySize100)
                    .foregroundStyle(isError ? Colors.red600 : Colors.gray600)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
    }
}

// MARK: - Preview

#Preview("TextInput States") {
    ScrollView {
        VStack(spacing: Spacing.spacing400) {
            PreviewDefaultState()
            PreviewReadOnlyState()
            PreviewDisabledState()
            PreviewErrorState()
            PreviewOptionalFields()
        }
        .padding(Spacing.spacing300)
    }
}

private struct PreviewDefaultState: View {
    @State private var text = ""

    var body: some View {
        TextInput(
            title: "모임 이름",
            isRequired: true,
            placeholder: "모임 이름을 입력하세요",
            helperText: "20자 이내로 입력해주세요",
            maxCount: 20,
            text: $text
        )
    }
}

private struct PreviewReadOnlyState: View {
    @State private var text = "읽기 전용 텍스트"

    var body: some View {
        TextInput(
            title: "읽기 전용",
            placeholder: "",
            state: .readOnly,
            text: $text
        )
    }
}

private struct PreviewDisabledState: View {
    @State private var text = ""

    var body: some View {
        TextInput(
            title: "비활성화",
            placeholder: "비활성화된 필드",
            state: .disabled,
            text: $text
        )
    }
}

private struct PreviewErrorState: View {
    @State private var text = "잘못된 입력"

    var body: some View {
        TextInput(
            title: "에러 상태",
            isRequired: true,
            placeholder: "입력하세요",
            helperText: "올바른 형식으로 입력해주세요",
            maxCount: 20,
            state: .error,
            text: $text
        )
    }
}

private struct PreviewOptionalFields: View {
    @State private var text = ""

    var body: some View {
        TextInput(
            title: "선택 항목",
            isOptional: true,
            placeholder: "입력하지 않아도 됩니다",
            helperText: "선택적으로 입력할 수 있습니다",
            text: $text
        )
    }
}
