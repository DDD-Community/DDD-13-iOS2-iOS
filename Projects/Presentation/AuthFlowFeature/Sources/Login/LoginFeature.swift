//
//  LoginFeature.swift
//  AuthFlowFeature
//
//  소셜 로그인 진입 화면 Reducer
//

import ComposableArchitecture
import CoreDependencies
import DomainInterface
import Entity
import Utill

@Reducer
public struct LoginFeature {
    @Dependency(\.socialAuthClient) private var socialAuthClient

    @ObservableState
    public struct State: Equatable {
        public var isLoading: Bool = false
        public var error: String? = nil

        public init() {}
    }

    public enum Action {
        // MARK: - 사용자 액션
        case kakaoLoginTapped // 카카오 로그인
        case appleLoginTapped // 애플 로그인
        case naverLoginTapped // 네이버 로그인
        case loginResponse(Result<LoginResult, SocialAuthClientError>)

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
                state.error = nil
                Log.debug("카카오 로그인 클릭")
                return signIn(provider: .kakao)

            case .appleLoginTapped:
                state.isLoading = true
                state.error = nil
                Log.debug("애플 로그인 클릭")
                return signIn(provider: .apple)

            case .naverLoginTapped:
                state.isLoading = true
                state.error = nil
                Log.debug("네이버 로그인 클릭")
                return signIn(provider: .naver)

            case let .loginResponse(.success(loginResult)):
                state.isLoading = false
                Log.debug("로그인 성공 - isNewMember: \(loginResult.isNewMember), registrationCompleted: \(loginResult.registrationCompleted)")
                if !loginResult.registrationCompleted {
                    return .send(.delegate(.needsSignUp(tempToken: loginResult.tokens.accessToken))) // 회원 가입이 안된 상태
                } else {
                    return .send(.delegate(.didLoginSuccess)) // 회원가입 이미 한 상태
                }

            case let .loginResponse(.failure(error)):
                state.isLoading = false
                state.error = error.localizedDescription
                Log.debug("로그인 실패: \(error.localizedDescription)")
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

private extension LoginFeature {
    func signIn(provider: SocialAuthProvider) -> Effect<Action> {
        let client = socialAuthClient

        return .run { send in
            do {
                let loginResult = try await client.signIn(provider)
                await send(.loginResponse(.success(loginResult)))
            } catch let error as SocialAuthClientError {
                await send(.loginResponse(.failure(error)))
            } catch {
                await send(.loginResponse(.failure(.underlying(error.localizedDescription))))
            }
        }
    }
}
