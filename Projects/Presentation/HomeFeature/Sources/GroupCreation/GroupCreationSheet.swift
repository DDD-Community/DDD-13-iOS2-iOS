//
//  GroupCreationSheet.swift
//  HomeFeature
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

struct GroupCreationSheet: View {
    @Bindable var store: StoreOf<GroupCreationSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(onClose: { store.send(.closeButtonTapped) })

            Group {
                if store.step == .info {
                    GroupInfoPage(store: store)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .leading),
                                removal: .move(edge: .leading)
                            )
                        )
                } else {
                    GroupPurposePage(store: store)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing),
                                removal: .move(edge: .trailing)
                            )
                        )
                }
            }
            .animation(.easeInOut(duration: 0.25), value: store.step)
        }
        .background(.white)
    }
}

// MARK: - Sheet Header

private struct SheetHeader: View {
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Text("모임 만들기")
                .pretendardCustomFont(textStyle: .bodyLargeEmphasized)
                .foregroundStyle(.gray900)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray700)
                    .frame(width: Sizing.sizing400, height: Sizing.sizing400)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.spacing300)
        .frame(height: 56)
    }
}

// MARK: - 화면 A: 모임 정보 작성

private struct GroupInfoPage: View {
    @Bindable var store: StoreOf<GroupCreationSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: Spacing.spacing400) {
                TextInput(
                    title: "모임명",
                    isRequired: true,
                    placeholder: "모임명을 입력해주세요",
                    maxCount: 20,
                    text: $store.groupTitle
                )

                PurposeSelectField(
                    selectedPurpose: store.selectedPurpose,
                    onTap: { store.send(.purposeButtonTapped) }
                )
            }
            .padding(.horizontal, Spacing.spacing300)
            .padding(.top, Spacing.spacing300)

            Spacer()

            CreateButton(
                isEnabled: store.isCreateEnabled,
                onTap: { store.send(.createButtonTapped) }
            )
            .padding(.horizontal, Spacing.spacing300)
            .padding(.bottom, Spacing.spacing400)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct PurposeSelectField: View {
    let selectedPurpose: GroupPurpose?
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            HStack(spacing: 0) {
                Text("모임 목적")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(.gray900)
                    .padding(.vertical, Spacing.spacing50)
                Text("*")
                    .pretendardCustomFont(textStyle: .bodyMedium)
                    .foregroundStyle(Colors.red500)
                    .padding(.vertical, Spacing.spacing50)
            }

            Button(action: onTap) {
                HStack(spacing: 0) {
                    Text(selectedPurpose?.rawValue ?? "목적을 선택해주세요")
                        .pretendardCustomFont(textStyle: .bodyLarge)
                        .foregroundStyle(selectedPurpose == nil ? .gray500 : .gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray500)
                }
                .padding(.horizontal, Spacing.spacing250)
                .frame(height: 52)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                        .stroke(.gray200, lineWidth: BorderWidth.borderWidth150)
                )
            }
            .buttonStyle(.plain)
        }
    }
}

private struct CreateButton: View {
    let isEnabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("만들기")
                .pretendardCustomFont(textStyle: .bodyLargeEmphasized)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Sizing.sizing500)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                        .fill(isEnabled ? Color(hex: "FF3C27") : Color.gray300)
                )
        }
        .disabled(!isEnabled)
        .buttonStyle(.plain)
    }
}

// MARK: - 화면 B: 모임 목적 리스트

private struct GroupPurposePage: View {
    @Bindable var store: StoreOf<GroupCreationSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(GroupPurpose.allCases) { purpose in
                        PurposeRow(
                            purpose: purpose,
                            isSelected: store.pendingPurpose == purpose,
                            onTap: { store.send(.purposeTapped(purpose)) }
                        )
                    }
                }
                .padding(.top, Spacing.spacing200)
            }

            RegisterButton(onTap: { store.send(.registerButtonTapped) })
                .padding(.horizontal, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing400)
                .padding(.top, Spacing.spacing250)
        }
    }
}

private struct PurposeRow: View {
    let purpose: GroupPurpose
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                Text(purpose.rawValue)
                    .pretendardCustomFont(textStyle: .bodyLarge)
                    .foregroundStyle(isSelected ? Color(hex: "FF3C27") : .gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(hex: "FF3C27"))
                }
            }
            .padding(.horizontal, Spacing.spacing300)
            .frame(height: 52)
            .background(isSelected ? Color(hex: "FF3C27").opacity(0.05) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

private struct RegisterButton: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text("등록하기")
                .pretendardCustomFont(textStyle: .bodyLargeEmphasized)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: Sizing.sizing500)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                        .fill(Color(hex: "FF3C27"))
                )
        }
        .buttonStyle(.plain)
    }
}
