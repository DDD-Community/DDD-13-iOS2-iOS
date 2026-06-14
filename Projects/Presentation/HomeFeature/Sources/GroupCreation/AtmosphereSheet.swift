//
//  AtmosphereSheet.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - Modifier

/// 장소 분위기 선택 BottomSheet 를 present 하는 modifier.
private struct AtmosphereSheetModifier: ViewModifier {
    @Bindable var store: StoreOf<GroupCreationFeature>

    func body(content: Content) -> some View {
        content.bottomSheet(
            isPresented: $store.isAtmosphereSheetPresented,
            header: .init(
                title: "장소 분위기",
                description: "원하는 분위기를 골라보세요 (최대 3개)",
                onClose: { store.send(.atmosphereSheetDismissed) }
            ),
            primaryButton: .init(
                title: "등록하기",
                isEnabled: store.isAtmosphereDraftValid,
                action: { store.send(.atmosphereConfirmed) }
            )
        ) {
            AtmosphereSheetContent(store: store)
        }
    }
}

extension View {
    func atmosphereSheet(store: StoreOf<GroupCreationFeature>) -> some View {
        modifier(AtmosphereSheetModifier(store: store))
    }
}

// MARK: - Content

/// 장소 분위기 선택 BottomSheet 내용.
private struct AtmosphereSheetContent: View {
    let store: StoreOf<GroupCreationFeature>

    var body: some View {
        VStack(spacing: 0) {
            ForEach(PlaceAtmosphere.allCases) { atmosphere in
                AtmosphereRow(
                    title: atmosphere.rawValue,
                    isSelected: store.atmosphereDraft.contains(atmosphere),
                    onTap: { store.send(.atmosphereToggled(atmosphere)) }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - AtmosphereRow

private struct AtmosphereRow: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing200) {
                Checkbox(
                    variant: .circle,
                    state: isSelected ? .enabled : .disabled,
                    size: .medium
                )

                BangawoText(title, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, Spacing.spacing300)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
