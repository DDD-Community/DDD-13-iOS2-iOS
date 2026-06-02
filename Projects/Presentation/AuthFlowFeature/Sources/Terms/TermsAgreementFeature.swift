//
//  TermsAgreementFeature.swift
//  Presentation
//
//  필수 약관 동의 화면 Feature
//

import ComposableArchitecture
import CoreDependencies
import Entity
import Foundation

@Reducer
public struct TermsAgreementFeature {
    public struct FetchError: Error, Equatable, Sendable {
        public let message: String
    }

    @ObservableState
    public struct State: Equatable {
        public var clauses: [TermClause]
        public var agreedIDs: Set<Int>
        public var pdfClause: TermClause?
        public var isLoading: Bool
        public var errorMessage: String?

        public init(
            clauses: [TermClause] = [],
            agreedIDs: Set<Int> = [],
            pdfClause: TermClause? = nil,
            isLoading: Bool = false,
            errorMessage: String? = nil
        ) {
            self.clauses = clauses
            self.agreedIDs = agreedIDs
            self.pdfClause = pdfClause
            self.isLoading = isLoading
            self.errorMessage = errorMessage
        }

        public var isAllAgreed: Bool {
            !clauses.isEmpty && clauses.allSatisfy { agreedIDs.contains($0.id) }
        }

        public var isStartEnabled: Bool {
            let requiredClauses = clauses.filter(\.isRequired)
            return !requiredClauses.isEmpty && requiredClauses.allSatisfy { agreedIDs.contains($0.id) }
        }
    }

    public enum Action {
        case onAppear // appear상태에서 이용약관 조회하기
        case signupTermsResponse(Result<[TermClause], FetchError>)
        case agreeAllToggleTapped
        case clauseToggleTapped(id: Int)
        case clausePDFTapped(id: Int)
        case pdfDismissed
        case startButtonTapped
        case backButtonTapped
        case changeLoginIDTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case completeAgreement(agreedTermIDs: [Int])
            case navigateBack
            case changeLoginID
        }
    }

    public init() {}

    @Dependency(\.signupTermsClient) private var signupTermsClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                let signupTermsClient = signupTermsClient
                return .run { send in
                    do {
                        let terms = try await signupTermsClient.fetchSignupTerms() // 이용약관 조회 api
                        await send(.signupTermsResponse(.success(terms.map(TermClause.init))))
                    } catch {
                        await send(.signupTermsResponse(.failure(FetchError(message: error.localizedDescription))))
                    }
                }

            case let .signupTermsResponse(.success(clauses)):
                state.isLoading = false
                state.clauses = clauses
                state.agreedIDs =  state.agreedIDs.intersection(Set(clauses.map(\.id)))
                return .none

            case let .signupTermsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.message
                return .none

            case .agreeAllToggleTapped:
                if state.isAllAgreed {
                    state.agreedIDs.removeAll()
                } else {
                    state.agreedIDs = Set(state.clauses.map(\.id))
                }
                return .none

            case let .clauseToggleTapped(id):
                if state.agreedIDs.contains(id) {
                    state.agreedIDs.remove(id)
                } else {
                    state.agreedIDs.insert(id)
                }
                return .none

            case let .clausePDFTapped(id):
                state.pdfClause = state.clauses.first(where: { $0.id == id })
                return .none

            case .pdfDismissed:
                state.pdfClause = nil
                return .none

            case .startButtonTapped:
                guard state.isStartEnabled else { return .none }
                let agreedTermIDs = state.clauses.map(\.id).filter { state.agreedIDs.contains($0)}
                return .send(.delegate(.completeAgreement(agreedTermIDs: agreedTermIDs)))

            case .backButtonTapped:
                return .send(.delegate(.navigateBack))

            case .changeLoginIDTapped:
                return .send(.delegate(.changeLoginID))

            case .delegate:
                return .none
            }
        }
    }
}

private extension TermClause {
    init(_ term: SignupTerm) {
        self.init(
            id: term.id,
            title: term.title,
            body: term.content,
            isRequired: term.isRequired
        )
    }
}
