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

            Group {
                if store.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.spacing400)
                } else if let errorMessage = store.errorMessage {
                    BangawoText(errorMessage, textStyle: .bodySmall)
                        .foregroundStyle(Colors.gray700)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, Spacing.spacing300)
                } else {
                    VStack(spacing: Spacing.spacing100) {
                        ForEach(store.clauses) { clause in
                            HStack(spacing: 0) {
                                Button { store.send(.clauseToggleTapped(id: clause.id)) } label: {
                                    CheckboxRow(
                                        clause.displayTitle,
                                        checkboxVariant: .circle,
                                        checkboxState: store.agreedIDs.contains(clause.id) ? .enabled : .disabled,
                                        size: .small,
                                        titleColor: Colors.gray700
                                    )
                                }
                                .buttonStyle(.plain)

                                Button { store.send(.clausePDFTapped(id: clause.id)) } label: {
                                    Image.Asset.icArrowSmallRight24
                                        .resizable()
                                        .renderingMode(.template)
                                        .scaledToFit()
                                        .frame(width: Sizing.sizing200, height: Sizing.sizing200)
                                        .foregroundStyle(Colors.gray600)
                                        .padding(Spacing.spacing200)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, Spacing.spacing450)

            Color.clear.frame(maxHeight: .infinity)

            ActionButton(
                buttonLayout: .single(
                    title: "다음",
                    isDisabled: !store.isStartEnabled,
                    action: { store.send(.startButtonTapped) }
                ),
                lowerContent: .init("로그인 아이디 변경", type: .textWithArrow, action: { store.send(.changeLoginIDTapped) })
            )
        }
        .onAppear { store.send(.onAppear) }
        .sheet(
            isPresented: Binding(
                get: { store.pdfClause != nil },
                set: { isPresented in
                    if !isPresented { store.send(.pdfDismissed) }
                }
            )
        ) {
            if let clause = store.pdfClause, let url = clause.url {
                NavigationStack {
                    TermWebView(url: url)
                        .navigationTitle(clause.displayTitle)
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

#Preview {
    BangawoPreview {
        TermsAgreementView(
            store: Store(initialState: TermsAgreementFeature.State()) {
                TermsAgreementFeature()
            }
        )
    }
}
