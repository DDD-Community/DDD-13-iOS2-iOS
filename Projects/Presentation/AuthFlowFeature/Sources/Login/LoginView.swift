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

            Image.Asset.imgLogin3d
                .resizable()
                .scaledToFit()
                .frame(height: 240)

            Spacer()

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
            .padding(.bottom, 32)
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
            HStack(spacing: 0) {
                Image.Asset.symKakao
                Text("카카오로 3초 만에 로그인")
                    .pretendardFont(family: .SemiBold, size: 16)
                    .lineSpacing(6)
                    .foregroundStyle(Color(hex: "000000").opacity(0.8))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: Sizing.sizing600)
            .background(Color(hex: "FEE500"))
            .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius250))
        }
    }
}

private struct NaverLoginButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Image.Asset.symNaver
                Text("네이버 로그인")
                    .pretendardFont(family: .SemiBold, size: 16)
                    .lineSpacing(6)
                    .foregroundStyle(.gray100)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: Sizing.sizing600)
            .background(Color(hex: "03A94D"))
            .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius250))
        }
    }
}

private struct AppleLoginButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Image.Asset.symApple
                Text("Apple로 로그인")
                    .pretendardFont(family: .SemiBold, size: 16)
                    .lineSpacing(6)
                    .foregroundStyle(Color(hex: "17171C"))
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: Sizing.sizing600)
            .background(.gray100)
            .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius250))
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                    .stroke(Color(hex: "BCBDC5"), lineWidth: 1)
            )
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
