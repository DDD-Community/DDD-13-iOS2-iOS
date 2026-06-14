//
//  GroupNameSheet.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

// MARK: - Modifier

/// 모임명 입력 BottomSheet 를 present 하는 modifier.
private struct GroupNameSheetModifier: ViewModifier {
    @Bindable var store: StoreOf<GroupCreationFeature>

    func body(content: Content) -> some View {
        content.bottomSheet(
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
            GroupNameSheetContent(store: store)
        }
    }
}

extension View {
    func groupNameSheet(store: StoreOf<GroupCreationFeature>) -> some View {
        modifier(GroupNameSheetModifier(store: store))
    }
}

// MARK: - Content

/// 모임명 입력 BottomSheet 내용.
private struct GroupNameSheetContent: View {
    @Bindable var store: StoreOf<GroupCreationFeature>

    var body: some View {
        TextInput(
            title: "모임명",
            placeholder: "ex: 삼총사 모임, 26기 대학동기",
            maxCount: 30,
            text: $store.groupNameDraft
        )
        .dismissKeyboardOnTap()
    }
}
