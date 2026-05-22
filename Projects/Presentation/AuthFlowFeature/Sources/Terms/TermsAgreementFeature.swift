//
//  TermsAgreementFeature.swift
//  Presentation
//
//  필수 약관 동의 화면 Feature
//

import Foundation

import ComposableArchitecture

@Reducer
public struct TermsAgreementFeature {
    @ObservableState
    public struct State: Equatable {
        public var clauses: [TermClause]
        public var agreedIDs: Set<String>
        public var pdfClause: TermClause?

        public init(
            clauses: [TermClause] = TermClause.allRequired,
            agreedIDs: Set<String> = [],
            pdfClause: TermClause? = nil
        ) {
            self.clauses = clauses
            self.agreedIDs = agreedIDs
            self.pdfClause = pdfClause
        }

        public var isAllAgreed: Bool {
            !clauses.isEmpty && clauses.allSatisfy { agreedIDs.contains($0.id) }
        }

        public var isStartEnabled: Bool { isAllAgreed }
    }

    public enum Action {
        case agreeAllToggleTapped
        case clauseToggleTapped(id: String)
        case clausePDFTapped(id: String)
        case pdfDismissed
        case startButtonTapped
        case backButtonTapped
        case changeLoginIDTapped
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case completeAgreement
            case navigateBack
            case changeLoginID
        }
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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

                return .send(.delegate(.completeAgreement))

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
