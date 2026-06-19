//
//  PurposeSheet.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - Modifier

/// 모임 목적(theme tag) 선택 BottomSheet 를 present 하는 modifier.
private struct PurposeSheetModifier: ViewModifier {
    @Bindable var store: StoreOf<GroupCreationFeature>

    func body(content: Content) -> some View {
        content.bottomSheetNative(
            isPresented: $store.isPurposeSheetPresented,
            header: .init(
                title: "모임 목적",
                onClose: { store.send(.purposeSheetDismissed) }
            ),
            primaryButton: .init(
                title: "등록하기",
                isEnabled: store.isPurposeDraftValid,
                action: { store.send(.purposeConfirmed) }
            )
        ) {
            PurposeSheetContent(store: store)
        }
    }
}

extension View {
    func purposeSheet(store: StoreOf<GroupCreationFeature>) -> some View {
        modifier(PurposeSheetModifier(store: store))
    }
}

// MARK: - Content

/// 모임 목적(theme tag) 선택 BottomSheet 내용.
/// 서버에서 fetch 한 `store.themeTags`(모임 목적 목록)를 행으로 렌더링한다.
private struct PurposeSheetContent: View {
    let store: StoreOf<GroupCreationFeature>

    var body: some View {
        VStack(spacing: 0) {
            ForEach(store.themeTags) { themeTag in
                PurposeRow(
                    themeTag: themeTag,
                    isSelected: store.purposeDraft == themeTag,
                    onTap: { store.send(.purposeSelected(themeTag)) }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - PurposeRow

/// 모임 목적(theme tag) 단일 행. `themeTag.code` 로 로컬 아이콘을 매핑하며,
/// 매핑되는 아이콘이 없는 목적은 아이콘 없이 displayName 만 표시한다.
private struct PurposeRow: View {
    let themeTag: ThemeTag
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing300) {
                if let icon = PurposeIcon.image(for: themeTag.code) {
                    icon
                        .resizable()
                        .scaledToFill()
                        .frame(width: Metric.iconLength, height: Metric.iconLength)
                        .clipShape(Circle())
                }

                BangawoText(themeTag.displayName, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Checkbox(variant: .ghost, state: .enabled, size: .medium)
                }
            }
            .padding(.vertical, Spacing.spacing300)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private enum Metric {
        static let iconLength: CGFloat = 32
    }
}

// MARK: - PurposeIcon

/// 모임 목적(theme tag) `code` → 로컬 아이콘.
/// 서버 응답에는 아이콘 정보가 없으므로 클라이언트가 code 로 아이콘을 매칭한다.
/// 목적 아이콘 에셋은 `ic_purpose_{keyword}` 포맷으로, 목적별로 trailing keyword 만 다르다.
/// 서버 code(대문자 스네이크)를 소문자로 변환해 같은 포맷의 에셋 이름을 만들고,
/// 그 이름의 에셋이 존재할 때만 매칭한다(목적별 매직스트링 분기 없음).
/// 대응 에셋이 없는 code(예: `STUDY`)는 아이콘 없이 displayName 만 표시된다.
private enum PurposeIcon {
    private static let assetPrefix = "ic_purpose_"

    static func image(for code: String) -> Image? {
        Image.assetIfExists(named: assetPrefix + code.lowercased())
    }
}
