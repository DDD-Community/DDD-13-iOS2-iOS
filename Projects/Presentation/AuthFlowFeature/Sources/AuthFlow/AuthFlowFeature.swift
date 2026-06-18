//
//  AuthFlowFeature.swift
//  Presentation
//
//  Login → Terms → ProfileInput → DepartureSearch의 회원가입 네비게이션 스택
//  인증 완료 시 부모(RootFeature)에 delegate를 발행해 메인 플로우로 위임한다
//

import ComposableArchitecture
import Entity
import Foundation
import StationSearchFeature
import Utill

@Reducer
public struct AuthFlowFeature {
    @Dependency(\.registerMemberClient) private var registerMemberClient

    @Reducer(state: .equatable)
    public enum Path {
        case terms(TermsAgreementFeature)
        case profile(ProfileInputFeature)
        case departure(DepartureSearchFeature)
    }
    
    public enum EntryPoint: Equatable { // 항상 로그인 화면부터 시작하지 않고, 상황에 따라 약관 화면부터 시작할 수 있게
        case login
        case terms
    }

    @ObservableState
    public struct State: Equatable {
      
        public var login: LoginFeature.State
        public var path: StackState<Path.State>
        @Presents public var stationSearch: StationSearchSheetFeature.State?
        public var suggestedProfileName: String? // SNS인증후 받은 이름이나 닉네임
        public var nickname: String // 실제 유저가 작성한 이름이나 닉네임(제안된 이름, 닉네임을 사용 안 할 수도 있기 때문에)
        public var agreedTermIDs: [Int]
        public var isRegistering: Bool
        public var registerErrorMessage: String?

        public init(
            entryPoint: EntryPoint = .login,
            login: LoginFeature.State = LoginFeature.State(),
            path: StackState<Path.State> = StackState<Path.State>(),
            suggestedProfileName: String? = nil,
            nickname: String = "",
            agreedTermIDs: [Int] = [],
            isRegistering: Bool = false,
            registerErrorMessage: String? = nil
        ) {
            self.login = login
            self.path = path
            self.stationSearch = nil
            self.suggestedProfileName = suggestedProfileName
            self.nickname = nickname
            self.agreedTermIDs = agreedTermIDs
            self.isRegistering = isRegistering
            self.registerErrorMessage = registerErrorMessage
            
            if entryPoint == .terms {
                self.path.append(.terms(TermsAgreementFeature.State())) // .terms일 때 path에 약관 화면 쌓는다.
            }
        }
    }

    public enum Action {
        case login(LoginFeature.Action)
        case path(StackActionOf<Path>)
        case stationSearch(PresentationAction<StationSearchSheetFeature.Action>)
        case registerMemberResponse(Result<Void, Error>)
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case authDidComplete
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }

        Reduce { state, action in
            switch action {
            case let .login(.delegate(.needsSignUp(_, suggestedName))):
                state.suggestedProfileName = suggestedName
                state.path.append(.terms(TermsAgreementFeature.State()))
                return .none

            case .login(.delegate(.didLoginSuccess)):
                return .send(.delegate(.authDidComplete))

            case .login:
                return .none

            case let .path(.element(id: _, action: .terms(.delegate(.completeAgreement(agreedTermIDs))))):
                state.agreedTermIDs = agreedTermIDs
                state.path.append(.profile(ProfileInputFeature.State(name: state.suggestedProfileName ?? "")))
                return .none

            case let .path(.element(id: _, action: .profile(.delegate(.proceedToDepartureSearch(name))))):
                state.nickname = name
                state.path.append(.departure(DepartureSearchFeature.State()))
                return .none

            case let .path(.element(id: _, action: .departure(.delegate(.registerRequested(station))))):
                guard !state.isRegistering else { return .none } // 중복 요청 방어 코드
                guard !state.nickname.isEmpty else {
                    state.registerErrorMessage = "닉네임 정보가 없습니다."
                    return .none
                }
                guard !state.agreedTermIDs.isEmpty else {
                    state.registerErrorMessage = "약관 동의 정보가 없습니다."
                    return .none
                }
                
                let registerMemberClient = self.registerMemberClient

                let member = RegisterMember(
                    nickname: state.nickname,
                    agreedTermsIds: state.agreedTermIDs,
                    departureLabel: station.name,
                    departureAddress: station.addressName,
                    departureRoadAddress: station.roadAddressName,
                    departurePlaceName: station.name,
                    latitude: station.y,
                    longitude: station.x
                )

                state.isRegistering = true
                state.registerErrorMessage = nil

                return .run { send in
                    do {
                        let result = try await registerMemberClient.register(
                            member
                        )
                        UserDefaults.standard.set(result.registrationCompleted, forKey: UserDefaultsKey.registrationCompleted)
                        await send(.registerMemberResponse(.success(())))
                    } catch {
                        Log.error("register failed: \(error)")
                        await send(.registerMemberResponse(.failure(error)))
                    }
                }

            case .path(.element(id: _, action: .departure(.delegate(.dismiss)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .departure(.delegate(.stationSearchRequested)))):
                state.stationSearch = StationSearchSheetFeature.State()
                return .none

            case .path(.element(id: _, action: .terms(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .profile(.delegate(.navigateBack)))):
                state.path.removeLast()
                return .none

            case let .stationSearch(.presented(.delegate(.stationSelected(station)))):
                state.stationSearch = nil
                let departureID = state.path.ids.first { id in
                    if case .departure = state.path[id: id] { return true }
                    return false
                }
                guard let id = departureID else { return .none }
                return .run { send in
                    await send(.path(.element(id: id, action: .departure(.stationSelected(station)))))
                }

            case .registerMemberResponse(.success):
                state.isRegistering = false
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.registrationCompleted) // 회원가입 완료시에 true로 갱신
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.isLogin)
                return .send(.delegate(.authDidComplete))

            case let .registerMemberResponse(.failure(error)):
                state.isRegistering = false
                state.registerErrorMessage = error.localizedDescription
                return .none

            case .stationSearch(.presented(.delegate(.dismissed))):
                state.stationSearch = nil
                return .none

            case .stationSearch:
                return .none

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$stationSearch, action: \.stationSearch) {
            StationSearchSheetFeature()
        }
    }
}
