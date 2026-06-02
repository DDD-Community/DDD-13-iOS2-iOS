//
//  GroupCreationView.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

struct GroupCreationView: View {
    @Bindable var store: StoreOf<GroupCreationFeature>

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                title: "모임 만들기",
                trailingIcons: [
                    NavigationIconItem(icon: .close24) { store.send(.closeButtonTapped) }
                ]
            )

            GroupCreationContent(store: store)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            // TODO: ActionButton 확장 PR 머지 후 isEnabled(store.isCreateEnabled) 반영
            ActionButton(
                buttonLayout: .single(title: "만들기", action: { store.send(.createButtonTapped) })
            )
        }
        .background(.white)
        .bottomSheet(
            isPresented: $store.isGroupNameSheetPresented,
            header: .init(
                title: "모임 만들기",
                onClose: { store.send(.groupNameSheetDismissed) }
            ),
            primaryButton: .init(
                title: "완료",
                isEnabled: store.isGroupNameDraftValid,
                action: { store.send(.groupNameConfirmed) }
            )
        ) {
            TextInput(
                title: "모임명",
                placeholder: "ex: 삼총사 모임, 26기 대학동기",
                maxCount: 30,
                text: $store.groupNameDraft
            )
        }
    }
}

// MARK: - Content

private struct GroupCreationContent: View {
    @Bindable var store: StoreOf<GroupCreationFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing500) {
            TextInput(
                title: "모임명",
                placeholder: "ex: 삼총사 모임, 26기 대학동기",
                text: $store.groupTitle
            )
            // 텍스트필드 직접 입력 대신 탭 시 모임명 입력 BottomSheet를 present
            .overlay {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { store.send(.groupNameFieldTapped) }
            }

            ListField(title: "모임 목적") {
                Button { store.send(.purposeFieldTapped) } label: {
                    Badge(
                        store.selectedPurpose?.rawValue ?? "비즈니스",
                        trailingIcon: Image.Asset.icArrowSmallDown16,
                        showTrailingIcon: true,
                        variant: .solid,
                        size: .large
                    )
                }
                .buttonStyle(.plain)
            }

            ListField(title: "장소 분위기") {
                Button { store.send(.atmosphereFieldTapped) } label: {
                    Badge(
                        store.selectedAtmosphere ?? "편안한",
                        trailingIcon: Image.Asset.icArrowSmallDown16,
                        showTrailingIcon: true,
                        variant: .solid,
                        size: .large
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, Spacing.spacing800)
        .padding(.horizontal, Spacing.spacing450)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - ListField

private struct ListField<Content: View>: View {
    private let title: String
    @ViewBuilder private let content: () -> Content

    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing300) {
            BangawoText(title, textStyle: .titleSmallEmphasized)
                .foregroundStyle(Colors.gray900)

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#Preview("모임 만들기") {
    BangawoPreview {
        GroupCreationView(
            store: Store(initialState: GroupCreationFeature.State()) {
                GroupCreationFeature()
            }
        )
    }
}

#Preview("입력 완료") {
    BangawoPreview {
        GroupCreationView(
            store: Store(
                initialState: {
                    var state = GroupCreationFeature.State()
                    state.groupTitle = "주말 등산 모임"
                    state.selectedPurpose = .sports
                    state.selectedAtmosphere = "활기찬"
                    return state
                }()
            ) {
                GroupCreationFeature()
            }
        )
    }
}
