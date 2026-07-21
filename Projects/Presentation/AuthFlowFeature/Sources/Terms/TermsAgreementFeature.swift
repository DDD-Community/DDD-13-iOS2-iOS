//
//  TermsAgreementFeature.swift
//  Presentation
//
//  필수 약관 동의 화면 Feature
//

import ComposableArchitecture
import Foundation

@Reducer
public struct TermsAgreementFeature {
    @ObservableState
    public struct State: Equatable {
        public var clauses: [TermClause]
        public var agreedIDs: Set<Int>
        public var pdfClause: TermClause?
        public var isLoading: Bool
        public var errorMessage: String?

        public init(
            clauses: [TermClause] = TermClause.temporaryClauses,
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
        case onAppear
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

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // 약관 항목은 임시로 고정된 값(TermClause.temporaryClauses)을 사용한다
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
