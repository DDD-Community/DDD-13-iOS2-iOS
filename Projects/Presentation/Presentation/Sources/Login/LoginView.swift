//
//  LoginView.swift
//  Presentation
//
//  Created by DDD-iOS2 on 4/25/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
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
                kakaoLoginButton
                naverLoginButton
                googleLoginButton
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

// MARK: - 소셜 로그인 버튼 컴포넌트

private extension LoginView {

    var kakaoLoginButton: some View {
        Button {
            store.send(.kakaoLoginTapped)
        } label: {
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

    var googleLoginButton: some View {
        Button {
            store.send(.appleLoginTapped)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "g.circle.fill")
                Text("Google로 로그인")
                    .pretendardCustomFont(textStyle: .bodyBold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .foregroundStyle(.gray900)
            .background(.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    var naverLoginButton: some View {
        Button {
            store.send(.naverLoginTapped)
        } label: {
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
