//
//  SearchField.swift
//  DesignSystem
//

import SwiftUI

public struct SearchField: View {
    private let placeholder: String
    @Binding private var text: String

    @FocusState private var isFocused: Bool
    @State private var cancelButtonWidth: CGFloat = 0

    public init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        ZStack(alignment: .trailing) {
            CancelButton {
                text = ""
                isFocused = false
            }
            .opacity(isFocused ? 1 : 0)
            .background(
                GeometryReader { geo in
                    Color.clear.onAppear { cancelButtonWidth = geo.size.width }
                }
            )

            InputContainer(
                placeholder: placeholder,
                text: $text,
                isFocused: $isFocused
            )
            .padding(.trailing, isFocused ? cancelButtonWidth + Spacing.spacing250 : 0)
            .frame(maxWidth: .infinity)
        }
        .animation(.easeInOut(duration: 0.1), value: isFocused)
    }
}

// MARK: - InputContainer

private extension SearchField {
    struct InputContainer: View {
        let placeholder: String
        @Binding var text: String
        @FocusState.Binding var isFocused: Bool

        var body: some View {
            HStack(spacing: Spacing.spacing200) {
                Image.Asset.icSearch24
                    .renderingMode(.template)
                    .foregroundStyle(Colors.gray500)

                TextField(
                    text: $text,
                    prompt: Text(placeholder).foregroundStyle(Colors.gray500)
                ) {
                    Text(placeholder)
                }
                .pretendardCustomFont(textStyle: .bodyLarge)
                .foregroundStyle(Colors.gray900)
                .focused($isFocused)
                .frame(maxWidth: .infinity)

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image.Asset.icCircleClose24
                            .renderingMode(.template)
                            .foregroundStyle(Colors.gray500)
                    }
                }
            }
            .padding(Spacing.spacing250)
            .frame(maxWidth: .infinity, minHeight: Spacing.spacing700)
            .background(Colors.grayAlpha200)
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                    .stroke(Colors.gray200, lineWidth: BorderWidth.borderWidth100)
            )
            .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius250))
        }
    }
}

// MARK: - CancelButton

private extension SearchField {
    struct CancelButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                BangawoText("취소", textStyle: .labelSmall)
                    .foregroundStyle(Colors.gray700)
                    .frame(minHeight: Spacing.spacing500)
                    .padding(.horizontal, Spacing.spacing250)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Preview

#Preview {
    @State var text = ""

    return VStack(spacing: Spacing.spacing400) {
        SearchField(placeholder: "검색어를 입력하세요", text: $text)
    }
    .padding(Spacing.spacing400)
}
