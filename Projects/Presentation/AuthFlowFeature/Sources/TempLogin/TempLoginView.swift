//
//  TempLoginView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture

public struct TempLoginView: View {
    @Bindable private var store: StoreOf<TempLoginFeature>

    public init(store: StoreOf<TempLoginFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 16) {
            Color.clear.frame(maxHeight: .infinity)

            VStack(spacing: 8) {
                Text("Bangawo")
                    .font(.largeTitle.bold())
                Text("임시 로그인 화면")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Color.clear.frame(maxHeight: .infinity)

            PrimaryFilledButton(title: "회원가입 플로우 진입") {
                store.send(.signUpButtonTapped)
            }

            PrimaryOutlinedButton(title: "메인 진입") {
                store.send(.enterMainButtonTapped)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

struct PrimaryFilledButton: View {
    private let title: String
    private let isEnabled: Bool
    private let action: () -> Void

    init(title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isEnabled ? Color.black : Color(.systemGray3),
                    in: RoundedRectangle(cornerRadius: 12)
                )
        }
        .disabled(!isEnabled)
    }
}

struct PrimaryOutlinedButton: View {
    private let title: String
    private let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.bold())
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 1)
                )
        }
    }
}
