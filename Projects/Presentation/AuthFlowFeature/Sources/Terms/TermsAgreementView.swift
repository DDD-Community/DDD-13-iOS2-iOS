//
//  TermsAgreementView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture

public struct TermsAgreementView: View {
    @Bindable private var store: StoreOf<TermsAgreementFeature>

    public init(store: StoreOf<TermsAgreementFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Bangawo에 참여하려면\n약관 동의가 필요해요")
                .font(.title2.bold())
                .padding(.top, 24)

            AgreeAllRow(isOn: store.isAllAgreed) {
                store.send(.agreeAllToggleTapped)
            }

            Divider()

            VStack(spacing: 16) {
                ForEach(store.clauses) { clause in
                    ClauseRow(
                        clause: clause,
                        isOn: store.agreedIDs.contains(clause.id),
                        onToggle: { store.send(.clauseToggleTapped(id: clause.id)) },
                        onPDF: { store.send(.clausePDFTapped(id: clause.id)) }
                    )
                }
            }

            Color.clear.frame(maxHeight: .infinity)

            PrimaryFilledButton(
                title: "시작하기",
                isEnabled: store.isStartEnabled
            ) {
                store.send(.startButtonTapped)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .sheet(
            isPresented: Binding(
                get: { store.pdfClause != nil },
                set: { isPresented in
                    if !isPresented { store.send(.pdfDismissed) }
                }
            )
        ) {
            if let clause = store.pdfClause {
                NavigationStack {
                    TermPDFViewer(clause: clause)
                        .navigationTitle(clause.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("닫기") { store.send(.pdfDismissed) }
                            }
                        }
                }
            }
        }
    }
}

struct AgreeAllRow: View {
    private let isOn: Bool
    private let action: () -> Void

    init(isOn: Bool, action: @escaping () -> Void) {
        self.isOn = isOn
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                CheckmarkIcon(isOn: isOn)
                Text("전체 동의하기")
                    .font(.body.bold())
                    .foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
    }
}

struct ClauseRow: View {
    private let clause: TermClause
    private let isOn: Bool
    private let onToggle: () -> Void
    private let onPDF: () -> Void

    init(
        clause: TermClause,
        isOn: Bool,
        onToggle: @escaping () -> Void,
        onPDF: @escaping () -> Void
    ) {
        self.clause = clause
        self.isOn = isOn
        self.onToggle = onToggle
        self.onPDF = onPDF
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                CheckmarkIcon(isOn: isOn)
            }
            .buttonStyle(.plain)

            Text(clause.title)
                .font(.body)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onPDF) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color(.systemGray2))
            }
            .buttonStyle(.plain)
        }
    }
}

struct CheckmarkIcon: View {
    private let isOn: Bool

    init(isOn: Bool) {
        self.isOn = isOn
    }

    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(isOn ? Color.black : Color(.systemGray3))
    }
}
