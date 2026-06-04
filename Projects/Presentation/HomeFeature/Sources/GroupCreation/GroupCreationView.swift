//
//  GroupCreationView.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

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
        // 모임 목적(theme tag) 목록 fetch. 뷰가 사라지면 Effect도 함께 취소되도록 .task 사용
        .task { await store.send(.onAppear).finish() }
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
        .bottomSheet(
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
        .bottomSheet(
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
                        store.selectedThemeTag?.displayName ?? "비즈니스",
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
                        atmosphereBadgeTitle,
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

    private var atmosphereBadgeTitle: String {
        store.selectedAtmospheres.isEmpty
            ? "편안한"
            : store.selectedAtmospheres.map(\.rawValue).joined(separator: ", ")
    }
}

// MARK: - AtmosphereSheetContent

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

// MARK: - PurposeSheetContent

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

/// 모임 목적(theme tag) `code` → 로컬 아이콘 에셋 매핑.
/// 서버 응답에는 아이콘 정보가 없으므로 code 기준으로 클라이언트가 매핑한다.
/// 매핑 테이블에 없는 code(예: `DINING`, `STUDY`)는 아이콘 없이 표시한다.
private enum PurposeIcon {
    static func image(for code: String) -> Image? {
        switch code {
        case "BUSINESS":    return Image.Asset.icPurposeBusiness
        case "SOCIAL":      return Image.Asset.icPurposeSocial
        case "FAMILY":      return Image.Asset.icPurposeFamily
        case "CASUAL_MEAL": return Image.Asset.icPurposeDining
        case "BIRTHDAY":    return Image.Asset.icPurposeBirthday
        case "WEDDING":     return Image.Asset.icPurposeWedding
        default:            return nil
        }
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
                    state.themeTags = [ThemeTag(code: "SOCIAL", displayName: "친목")]
                    state.selectedThemeTag = ThemeTag(code: "SOCIAL", displayName: "친목")
                    state.selectedAtmospheres = [.openView, .spacious]
                    return state
                }()
            ) {
                GroupCreationFeature()
            }
        )
    }
}
