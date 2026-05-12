//
//  LoginView.swift
//  AuthFlowFeature
//
//  소셜 로그인 진입 화면
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

public struct LoginView: View {
    let store: StoreOf<LoginFeature>

    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - 로고 영역
            Text("반가워")
                .pretendardCustomFont(textStyle: .heading0)
                .foregroundStyle(.navy900)

            Spacer()

            // MARK: - 소셜 로그인 버튼
            VStack(spacing: 12) {
                KakaoLoginButton {
                    store.send(.kakaoLoginTapped)
                }
                NaverLoginButton {
                    store.send(.naverLoginTapped)
                }
                AppleLoginButton {
                    store.send(.appleLoginTapped)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .disabled(store.isLoading)
        .overlay {
            if store.isLoading {
                ProgressView()
            }
        }
    }
}

private struct KakaoLoginButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "message.fill")
                Text("카카오로 3초 만에 로그인")
                    .pretendardCustomFont(textStyle: .bodyBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.gray900)
            .background(Color(hex: "FEE500"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct AppleLoginButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "apple.logo")
                Text("Apple로 로그인")
                    .pretendardCustomFont(textStyle: .bodyBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.gray900)
            .background(.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct NaverLoginButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text("N")
                    .pretendardCustomFont(textStyle: .titleBold)
                Text("네이버 로그인")
                    .pretendardCustomFont(textStyle: .bodyBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.gray100)
            .background(Color(hex: "03C75A"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    LoginView(
        store: Store(initialState: LoginFeature.State()) {
            LoginFeature()
        }
    )
}
