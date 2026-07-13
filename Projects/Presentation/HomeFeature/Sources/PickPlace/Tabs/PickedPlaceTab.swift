//
//  PickedPlaceTab.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

/// 장소 투표 후보 담기 화면의 "담은 장소" 탭.
/// 모임원 가로 리스트 → 카테고리 필터 → 담은 장소 리스트(중복 제거)를 보여주고,
/// 호스트에게는 하단에 투표 생성 버튼을 노출한다.
struct PickedPlaceTab: View {
    let store: StoreOf<PickedPlaceTabFeature>

    var body: some View {
        VStack(spacing: 0) {
            if store.isPickedPlaceEmpty {
                VStack(spacing: 0) {
                    MemberStrip(members: store.members)
                        .padding(.top, Spacing.spacing300)

                    PickedPlaceEmptyView {
                        store.send(.goPickPlaceTapped)
                    }
                    .padding(.top, Spacing.spacing500)
                    .frame(maxHeight: .infinity)
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        MemberStrip(members: store.members)
                            .padding(.top, Spacing.spacing300)

                        PickedPlaceContent(
                            filters: store.categoryFilters,
                            selectedCategory: store.selectedFilterCategory,
                            places: store.filteredPickedPlaces,
                            onSelect: { store.send(.categoryFilterSelected($0)) }
                        )
                        .padding(.top, Spacing.spacing500)
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
    let members: [PickPlaceMember]

    private var sortedMembers: [PickPlaceMember] {
        members.filter(\.isMe) + members.filter { !$0.isMe }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Spacing.spacing300) {
                ForEach(sortedMembers) { member in
                    MemberItem(member: member)
                }
            }
            .padding(.horizontal, Spacing.spacing400)
        }
    }
}

private struct MemberItem: View {
    let member: PickPlaceMember

    private var avatarType: Avatar.AvatarType {
        guard
            let urlString = member.profileImageUrl,
            let url = URL(string: urlString)
        else { return .placeholder }

        return .image(url)
    }

    private var label: String {
        member.isMe ? "\(member.nickname) (나)" : member.nickname
    }

    var body: some View {
        VStack(spacing: Spacing.spacing350) {
            Avatar(avatarType: avatarType, size: .s56)
                .overlay {
                    Circle()
                        .stroke(Color(hex: Constant.avatarBorderHex), lineWidth: Metric.avatarBorderWidth)
                }

            BangawoText(label, textStyle: .bodySmall)
                .foregroundStyle(Colors.gray800)
        }
    }
}

private enum Metric {
    static let avatarBorderWidth: CGFloat = 1.78
    static let categoryFilterGap: CGFloat = 17
    static let filterToListSpacing: CGFloat = 21
}

private enum Constant {
    static let avatarBorderHex = "D8D8D8"
}

// MARK: - 카테고리 필터 칩

private struct CategoryFilterStrip: View {
    let filters: [PickedPlaceTabFeature.CategoryFilter]
    let selectedCategory: PlaceCategory
    let onSelect: (PlaceCategory) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Metric.categoryFilterGap) {
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
            BangawoText(label, textStyle: .titleSmall)
                .foregroundStyle(isSelected ? Colors.gray800 : Colors.gray700)
                .padding(.vertical, Spacing.spacing200)
                .padding(.horizontal, Spacing.spacing250)
                .background(
                    Capsule()
                        .fill(isSelected ? Colors.grayAlpha200 : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 담은 장소 컨텐츠 (카테고리 필터 + 리스트)

private struct PickedPlaceContent: View {
    let filters: [PickedPlaceTabFeature.CategoryFilter]
    let selectedCategory: PlaceCategory
    let places: [PickedPlace]
    let onSelect: (PlaceCategory) -> Void

    var body: some View {
        VStack(spacing: 0) {
            CategoryFilterStrip(
                filters: filters,
                selectedCategory: selectedCategory,
                onSelect: onSelect
            )
            .padding(.bottom, Metric.filterToListSpacing)

            PickedPlaceList(places: places)
        }
    }
}

// MARK: - 담은 장소 리스트

private struct PickedPlaceList: View {
    let places: [PickedPlace]

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(places) { place in
                PlaceRow(
                    placeName: place.name,
                    category: place.category,
                    displayAddress: place.address,
                    roadAddress: nil,
                    lotAddress: nil,
                    distance: nil
                ) {
                    if place.pickedCount > 1 {
                        BangawoText("\(place.pickedCount)명 선택", textStyle: .labelXSmall)
                            .foregroundStyle(Colors.gray00)
                            .padding(.vertical, Spacing.spacing100)
                            .padding(.horizontal, Spacing.spacing150)
                            .background(
                                RoundedRectangle(cornerRadius: BorderRadius.borderRadius150)
                                    .fill(Colors.orange600)
                            )
                    }
                }
            }
        }
    }
}

// MARK: - 빈 상태

private struct PickedPlaceEmptyView: View {
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            BangawoText("어느 장소가 가장 마음에 드시나요?", textStyle: .titleSmallEmphasized)
                .foregroundStyle(Colors.gray700)
                .multilineTextAlignment(.center)

            BangawoText("추천 장소들을 둘러보고\n다 함께 투표할 후보를 골라주세요!", textStyle: .titleSmall)
                .foregroundStyle(Colors.gray700)
                .multilineTextAlignment(.center)
                .padding(.top, Spacing.spacing225)

            BangawoButton("투표 후보 담으러가기", variant: .solid, size: .small, action: onTap)
                .padding(.top, Spacing.spacing500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    private let store: StoreOf<PickedPlaceTabFeature>

    init(
        members: [PickPlaceMember] = PickPlaceMember.mock,
        pickedPlaces: [PickedPlace] = PickedPlace.mock,
        isHost: Bool = false
    ) {
        self.store = Store(
            initialState: PickedPlaceTabFeature.State(
                members: members,
                pickedPlaces: pickedPlaces,
                isHost: isHost
            )
        ) {
            PickedPlaceTabFeature()
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
