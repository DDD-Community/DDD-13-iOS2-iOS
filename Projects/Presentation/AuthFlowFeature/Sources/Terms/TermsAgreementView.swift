//
//  TermsAgreementView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

public struct TermsAgreementView: View {
    @Bindable private var store: StoreOf<TermsAgreementFeature>

    public init(store: StoreOf<TermsAgreementFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { store.send(.backButtonTapped) }
            )

            TopHero(
                asset: Image.Asset.imgAgreement3d,
                title: "편리한 이용을 위해\n약관동의가 필요해요",
                assetSize: .large
            )

            Button { store.send(.agreeAllToggleTapped) } label: {
                CheckboxRow(
                    "전체 동의하기",
                    checkboxVariant: .circle,
                    checkboxState: store.isAllAgreed ? .enabled : .disabled,
                    size: .medium,
                    arrowDirection: .right
                )
                .padding(.vertical, Spacing.spacing50)
                .background(Colors.gray50)
                .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius250))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Spacing.spacing450)

            Spacer().frame(height: Spacing.spacing300)

            VStack(spacing: Spacing.spacing100) {
                ForEach(store.clauses) { clause in
                    Button { store.send(.clauseToggleTapped(id: clause.id)) } label: {
                        CheckboxRow(
                            clause.title,
                            checkboxVariant: .circle,
                            checkboxState: store.agreedIDs.contains(clause.id) ? .enabled : .disabled,
                            size: .small,
                            arrowDirection: .right,
                            titleColor: Colors.gray700
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Spacing.spacing450)

            Color.clear.frame(maxHeight: .infinity)

            ActionButton(
                buttonLayout: .single(title: "다음", action: { store.send(.startButtonTapped) }),
                lowerContent: .init("로그인 아이디 변경", type: .textWithArrow, action: { store.send(.changeLoginIDTapped) })
            )
        }
        // TODO: clausePDFTapped 시 약관 내용을 웹뷰로 present해야 합니다
    }
}

#Preview {
    BangawoPreview {
        TermsAgreementView(
            store: Store(initialState: TermsAgreementFeature.State()) {
                TermsAgreementFeature()
            }
        )
    }
}
