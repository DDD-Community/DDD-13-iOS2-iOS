//
//  PickedPlaceTab.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 장소 투표 후보 담기 화면의 "담은 장소" 탭.
/// 모임원 가로 리스트 → 카테고리 필터 → 담은 장소 리스트(중복 제거)를 보여주고,
/// 호스트에게는 하단에 투표 생성 버튼을 노출한다.
struct PickedPlaceTab: View {
    let store: StoreOf<SelectPlaceFeature>

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    MemberStrip(members: store.members)
                        .padding(.vertical, Spacing.spacing300)

                    if store.isPickedPlaceEmpty {
                        PickedPlaceEmptyView {
                            store.send(.goPickPlaceTapped)
                        }
                    } else {
                        CategoryFilterStrip(
                            filters: store.categoryFilters,
                            selectedCategory: store.selectedFilterCategory,
                            onSelect: { store.send(.categoryFilterSelected($0)) }
                        )
                        .padding(.bottom, Spacing.spacing200)

                        PickedPlaceList(places: store.filteredPickedPlaces)
                    }
                }
            }

            if store.isHost {
                CreateVoteButton {
                    store.send(.createVoteTapped)
                }
            }
        }
    }
}

// MARK: - 멤버 가로 스크롤 리스트

private struct MemberStrip: View {
    let members: [SelectPlaceMember]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.spacing300) {
                ForEach(members) { member in
                    MemberItem(member: member)
                }
            }
            .padding(.horizontal, Spacing.spacing400)
        }
    }
}

private struct MemberItem: View {
    let member: SelectPlaceMember

    private var avatarType: Avatar.AvatarType {
        guard
            let urlString = member.profileImageUrl,
            let url = URL(string: urlString)
        else { return .placeholder }

        return .image(url)
    }

    var body: some View {
        VStack(spacing: Spacing.spacing150) {
            Avatar(avatarType: avatarType, size: .s56)
                .opacity(member.hasPicked ? 1 : Opacity.opacity400)

            BangawoText(member.nickname, textStyle: .bodySmall)
                .foregroundStyle(member.hasPicked ? Colors.gray800 : Colors.gray500)
        }
    }
}

// MARK: - 카테고리 필터 칩

private struct CategoryFilterStrip: View {
    let filters: [SelectPlaceFeature.CategoryFilter]
    let selectedCategory: NearbyPlaceCategory
    let onSelect: (NearbyPlaceCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.spacing200) {
                ForEach(filters) { filter in
                    CategoryFilterChip(
                        label: filter.label,
                        isSelected: selectedCategory == filter.category,
                        onTap: { onSelect(filter.category) }
                    )
                }
            }
            .padding(.horizontal, Spacing.spacing400)
        }
    }
}

private struct CategoryFilterChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            BangawoText(label, textStyle: .labelSmall)
                .foregroundStyle(isSelected ? Colors.gray00 : Colors.gray700)
                .padding(.horizontal, Spacing.spacing250)
                .padding(.vertical, Spacing.spacing150)
                .background(
                    RoundedRectangle(cornerRadius: BorderRadius.borderRadiusFull)
                        .fill(isSelected ? Colors.gray900 : Colors.gray100)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 담은 장소 리스트

private struct PickedPlaceList: View {
    let places: [PickedPlace]

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(places) { place in
                PlaceRow {
                    BangawoText("\(place.pickedCount)명", textStyle: .labelSmallEmphasized)
                        .foregroundStyle(Colors.gray700)
                }
            }
        }
    }
}

// MARK: - 빈 상태

private struct PickedPlaceEmptyView: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: Spacing.spacing300) {
            BangawoText("아직 담은 장소가 없어요", textStyle: .bodyMedium)
                .foregroundStyle(Colors.gray600)

            BangawoButton("투표 후보 담으러가기", variant: .weak, size: .medium, action: onTap)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.spacing700)
        .padding(.horizontal, Spacing.spacing400)
    }
}

// MARK: - 투표 생성 버튼 (호스트 한정)

private struct CreateVoteButton: View {
    let onTap: () -> Void

    var body: some View {
        BangawoButton(
            "투표 생성하기",
            variant: .solid,
            size: .large,
            widthType: .maxWidth,
            action: onTap
        )
        .padding(.horizontal, Spacing.spacing400)
        .padding(.vertical, Spacing.spacing300)
    }
}

// MARK: - Preview

#if DEBUG
private struct PickedPlaceTabPreview: View {
    private let store: StoreOf<SelectPlaceFeature>

    init(
        pickedPlaces: [PickedPlace] = PickedPlace.mock,
        isHost: Bool = false
    ) {
        self.store = Store(
            initialState: SelectPlaceFeature.State(pickedPlaces: pickedPlaces, isHost: isHost)
        ) {
            SelectPlaceFeature()
        }
    }

    var body: some View {
        PickedPlaceTab(store: store)
    }
}

#Preview("게스트") {
    BangawoPreview {
        PickedPlaceTabPreview()
    }
}

#Preview("호스트") {
    BangawoPreview {
        PickedPlaceTabPreview(isHost: true)
    }
}

#Preview("빈 상태") {
    BangawoPreview {
        PickedPlaceTabPreview(pickedPlaces: [])
    }
}
#endif
