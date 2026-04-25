//
//  LoginFeature.swift
//  Presentation
//
//  Created by DDD-iOS2 on 4/25/26.
//  Copyright (c) 2025 DDD, Ltd., All rights reserved.
//

import ComposableArchitecture
import DomainInterface
import Entity
import Utill

@Reducer
public struct LoginFeature {
    @Dependency(\.socialAuthClient) private var socialAuthClient

    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var selectedProvider: SocialAuthProvider? = nil
        public var error: String? = nil

        public init() {}
    }

    public enum Action {
        // MARK: - 사용자 액션
        case kakaoLoginTapped // 카카오 로그인
        case appleLoginTapped // 애플 로그인
        case naverLoginTapped // 네이버 로그인
        case socialLoginResponse(Result<SocialAuthToken, SocialAuthClientError>)

        // MARK: - 부모 Coordinator 전달용
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didLoginSuccess // 이미 가입한 회원이면 로그인 성공
            case needsSignUp(tempToken: String) // 가입한 이력이 없으면 회원가입으로
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .kakaoLoginTapped:
                state.isLoading = true
                state.selectedProvider = .kakao
                state.error = nil
                Log.debug("카카오 로그인 클릭")
                return login(provider: .kakao)

            case .appleLoginTapped:
                state.isLoading = true
                state.selectedProvider = .apple
                state.error = nil
                Log.debug("애플 로그인 클릭")
                return login(provider: .apple)

            case .naverLoginTapped:
                state.isLoading = true
                state.selectedProvider = .naver
                state.error = nil
                Log.debug("네이버 로그인 클릭")
                return login(provider: .naver)

            case let .socialLoginResponse(.success(token)): // 각 sns 로그인 성공 후 통합 로직
                state.isLoading = false
                Log.debug("소셜 로그인 성공: \(token.accessToken)")
                // TODO: AuthUseCase 연결 후 서버 로그인/회원가입 분기 처리
                return .none

            case let .socialLoginResponse(.failure(error)): // 각 sns 로그인 실패 후 통합 로직
                state.isLoading = false
                state.error = error.localizedDescription
                Log.debug("소셜 로그인 실패: \(error.localizedDescription)")
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private extension LoginFeature {
    func login(provider: SocialAuthProvider) -> Effect<Action> {
        let socialAuthClient = socialAuthClient

        return .run { send in
            do {
                let token = try await socialAuthClient.login(provider)
                await send(.socialLoginResponse(.success(token)))
            } catch let error as SocialAuthClientError { // TODO: 애플, 네이버 연동 필요
                await send(.socialLoginResponse(.failure(error)))
            } catch {
                await send(.socialLoginResponse(.failure(.underlying(error.localizedDescription))))
            }
        }
    }
}
