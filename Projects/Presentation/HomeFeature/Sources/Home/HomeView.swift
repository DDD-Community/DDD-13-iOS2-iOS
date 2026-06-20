//
//  HomeView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture
import DesignSystem
import Entity

public struct HomeView: View {
    @Bindable private var store: StoreOf<HomeFeature>
    @State private var isFABExpanded = false

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    NavigationMain(
                        background: .clear,
                        trailingIcons: [
                            NavigationIconItem(
                                icon: .bell24,
                                showsBadge: store.hasUnreadNotifications
                            ) { store.send(.notificationButtonTapped) },
                            NavigationIconItem(icon: .user24) {
                                store.send(.myPageButtonTapped)
                            }
                        ]
                    )

                    Tab(
                        labels: ["모임", "리마인더"],
                        selectedIndex: Binding(
                            get: { store.selectedTabIndex },
                            set: { store.send(.tabSelected($0)) }
                        ),
                        variant: .scrollable,
                        size: .large
                    )

                    if store.selectedTabIndex == 0 {
                        GroupListContent(
                            groups: store.groups,
                            inviteCardDesign: store.inviteCardDesign,
                            showsInviteCard: store.isInviteCardVisible,
                            onCreateTapped: { store.send(.createGroupRowTapped) },
                            onGroupTapped: { store.send(.groupCardTapped($0)) },
                            onInviteClose: {
                                store.send(
                                    .inviteCardCloseButtonTapped,
                                    animation: .easeInOut(duration: 0.3)
                                )
                            },
                            onInviteTapped: { store.send(.inviteButtonTapped) }
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Colors.gray200.ignoresSafeArea())

                FAB(
                    isPressed: $isFABExpanded,
                    menuItems: [
                        Menu.Item(label: "모임 만들기", icon: .Asset.icPlus24) {
                            isFABExpanded = false
                            store.send(.fabCreateGroupTapped)
                        },
                        Menu.Item(label: "모임 참여하기", icon: .Asset.icUsersPlus24) {
                            isFABExpanded = false
                            store.send(.fabJoinGroupTapped)
                        }
                    ]
                )
                .padding(.trailing, Spacing.spacing300)
                .padding(.bottom, Spacing.spacing400)
            }
            .onAppear { store.send(.onAppear) }
            .fullScreenCover(item: $store.scope(state: \.creationView, action: \.creationView)) { creationStore in
                GroupCreationView(store: creationStore)
            }
        } destination: { pathStore in
            switch pathStore.case {
            case let .detail(detailStore):
                GroupDetailView(store: detailStore)
            }
        }
    }
}

// MARK: - Group List

private struct GroupListContent: View {
    let groups: [Entity.Group]
    let inviteCardDesign: HomeFeature.InviteCardDesign
    let showsInviteCard: Bool
    let onCreateTapped: () -> Void
    let onGroupTapped: (Entity.Group) -> Void
    let onInviteClose: () -> Void
    let onInviteTapped: () -> Void

    var body: some View {
        if groups.isEmpty {
            CreateGroupRow(onTap: onCreateTapped)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            ScrollView {
                VStack(spacing: 0) {
                    if showsInviteCard {
                        InviteCard(
                            design: inviteCardDesign,
                            onClose: onInviteClose,
                            onInvite: onInviteTapped
                        )
                        .padding(.horizontal, Spacing.spacing300)
                        .padding(.top, Spacing.spacing400)
                        .transition(.scale.combined(with: .opacity))
                    }

                    GroupListHeader()

                    LazyVStack(spacing: Spacing.spacing250) {
                        ForEach(groups) { group in
                            GroupCard(group: group, onTap: { onGroupTapped(group) })
                        }
                    }
                    .padding(.horizontal, Spacing.spacing300)
                }
                .padding(.bottom, 80)
            }
        }
    }
}

private struct GroupListHeader: View {
    var body: some View {
        BangawoText("참여 중인 모임", textStyle: .titleSmall)
            .foregroundStyle(Colors.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.spacing500)
            .padding(.bottom, Spacing.spacing300)
            .padding(.horizontal, Spacing.spacing400)
    }
}

private struct CreateGroupRow: View {
    let onTap: () -> Void

    private enum Metric {
        static let cornerRadius: CGFloat = BorderRadius.borderRadius250
        static let gradientEndRadius: CGFloat = 240
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.spacing300) {
                Image.Asset.icPlus24
                    .renderingMode(.template)
                    .foregroundStyle(Colors.gray800)

                BangawoText("모임 생성하기", textStyle: .titleLarge)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, Spacing.spacing500)
            .padding(.horizontal, Spacing.spacing400)
            .background(background)
        }
        .buttonStyle(.plain)
        .padding(.top, Spacing.spacing600)
        .padding(.horizontal, Spacing.spacing400)
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: Metric.cornerRadius)
            .fill(
                RadialGradient(
                    colors: [Colors.grayAlpha50, Colors.grayAlpha200],
                    center: .center,
                    startRadius: 0,
                    endRadius: Metric.gradientEndRadius
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: Metric.cornerRadius)
                    .stroke(Colors.gray50, lineWidth: BorderWidth.borderWidth100)
            )
    }
}

// MARK: - Group Card

private struct GroupCard: View {
    let group: Entity.Group
    let onTap: () -> Void

    private enum Metric {
        static let cornerRadius: CGFloat = BorderRadius.borderRadius350
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                GroupInfoArea(group: group)

                if group.memberCount > 1 {
                    GroupMemberArea(group: group)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Metric.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Group Info Area

private struct GroupInfoArea: View {
    let group: Entity.Group

    private enum Metric {
        static let cornerRadius: CGFloat = BorderRadius.borderRadius350
        static let gradientEndRadius: CGFloat = 200
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            topLeadingRadius: Metric.cornerRadius,
            topTrailingRadius: Metric.cornerRadius
        )
    }

    private var showsInProgressBadge: Bool {
        group.listStatus == .inProgress
            && group.memberCount >= 2
            && (group.locationStatus == .voting || group.dateVoteStatus == .inProgress)
    }

    var body: some View {
        HStack(spacing: Spacing.spacing300) {
            ThemeIcon(themeTagCode: group.themeTagCode)
                .clipShape(Circle())

            HStack(alignment: .top, spacing: Spacing.spacing200) {
                VStack(alignment: .leading, spacing: Spacing.spacing50) {
                    BangawoText(group.themeTagDisplay, textStyle: .bodyMedium)
                        .foregroundStyle(Colors.gray700)

                    BangawoText(group.name, textStyle: .titleMediumEmphasized)
                        .foregroundStyle(Colors.gray800)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if showsInProgressBadge {
                    Badge(
                        "진행 중",
                        leadingIcon: Image.Asset.icStatus16,
                        showLeadingIcon: true,
                        variant: .solid,
                        size: .medium
                    )
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, Spacing.spacing400)
        .padding(.horizontal, Spacing.spacing300)
        .background(
            shape.fill(
                RadialGradient(
                    colors: [Colors.neutralAlpha500, Colors.neutralAlpha900],
                    center: .center,
                    startRadius: 0,
                    endRadius: Metric.gradientEndRadius
                )
            )
        )
        .overlay(
            shape.stroke(Colors.gray00, lineWidth: BorderWidth.borderWidth100)
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Theme Icon

private struct ThemeIcon: View {
    let themeTagCode: String

    var body: some View {
        if let icon = Image.assetIfExists(named: "ic_purpose_" + themeTagCode.lowercased()) {
            Asset(assetType: .image(icon), size: .s40)
        } else {
            Circle().fill(Colors.gray200)
        }
    }
}

// MARK: - Group Member Area

private struct GroupMemberArea: View {
    let group: Entity.Group

    private enum Metric {
        static let cornerRadius: CGFloat = BorderRadius.borderRadius350
    }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(
            bottomLeadingRadius: Metric.cornerRadius,
            bottomTrailingRadius: Metric.cornerRadius
        )
    }

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            HStack(spacing: Spacing.spacing100) {
                MemberAvatarStack(members: group.members)

                if group.memberCount > MemberAvatarStack.Metric.maxVisible {
                    BangawoText(
                        "외 \(group.memberCount - MemberAvatarStack.Metric.maxVisible)명",
                        textStyle: .bodySmall
                    )
                    .foregroundStyle(Colors.gray700)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image.Asset.icArrowSmallRight24
                .renderingMode(.template)
                .foregroundStyle(Colors.gray700)
        }
        .padding(.vertical, Spacing.spacing250)
        .padding(.horizontal, Spacing.spacing300)
        .background(shape.fill(Colors.gray50))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Colors.gray200)
                .frame(height: BorderWidth.borderWidth100)
        }
    }
}

// MARK: - Member Avatar Stack

private struct MemberAvatarStack: View {
    let members: [GroupMember]

    enum Metric {
        static let maxVisible: Int = 4
        static let overlap: CGFloat = 6
    }

    var body: some View {
        HStack(spacing: -Metric.overlap) {
            ForEach(Array(members.prefix(Metric.maxVisible).enumerated()), id: \.element.id) { index, member in
                Avatar(avatarType: avatarType(for: member), size: .s24)
                    .zIndex(Double(index))
            }
        }
    }

    private func avatarType(for member: GroupMember) -> Avatar.AvatarType {
        guard
            let urlString = member.profileImageUrl,
            let url = URL(string: urlString)
        else { return .placeholder }

        return .image(url)
    }
}

// MARK: - Previews

#if DEBUG
private enum HomePreview {
    static func member(_ id: Int) -> GroupMember {
        GroupMember(id: id, nickname: "멤버\(id)", profileImageUrl: nil, attendanceStatus: .join)
    }

    static func group(
        id: Int,
        name: String,
        locationStatus: GroupLocationStatus,
        dateVoteStatus: GroupDateVoteStatus,
        memberCount: Int
    ) -> Entity.Group {
        Entity.Group(
            id: id,
            meetingId: id,
            name: name,
            themeTagCode: "BIRTHDAY",
            themeTagDisplay: "생일 파티",
            listStatus: .inProgress,
            locationStatus: locationStatus,
            dateVoteStatus: dateVoteStatus,
            locationAddress: nil,
            memberCount: memberCount,
            members: (1...memberCount).map { member($0) }
        )
    }

    static func store(groups: [Entity.Group]) -> StoreOf<HomeFeature> {
        Store(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.groupClient.fetchGroups = { groups }
        }
    }
}

#Preview("모임 0개") {
    HomeView(store: HomePreview.store(groups: []))
}

// 모임이 1개일 때 친구 초대 카드(배너) 노출 확인
#Preview("모임 1개 - 친구 초대 카드") {
    HomeView(
        store: HomePreview.store(groups: [
            HomePreview.group(
                id: 1,
                name: "첫 모임",
                locationStatus: .before,
                dateVoteStatus: .before,
                memberCount: 4
            )
        ])
    )
}

// GroupCard를 케이스별로 노출 (3개이므로 친구 초대 카드 미노출)
#Preview("모임 3개 - 케이스별") {
    HomeView(
        store: HomePreview.store(groups: [
            // 초대된 친구가 없는 경우 (멤버가 나 1명만 존재 → 멤버 영역 미노출)
            HomePreview.group(
                id: 1,
                name: "혼자 있는 모임",
                locationStatus: .before,
                dateVoteStatus: .before,
                memberCount: 1
            ),
            // 친구가 있고, 날짜나 장소 선정을 진행 중인 경우 (Badge 노출)
            HomePreview.group(
                id: 2,
                name: "선정 진행 중 모임",
                locationStatus: .before,
                dateVoteStatus: .before,
                memberCount: 4
            ),
            // 친구가 있고, 선정이 진행 중이 아닌 경우 (Badge 미노출)
            HomePreview.group(
                id: 3,
                name: "선정 완료 모임",
                locationStatus: .confirmed,
                dateVoteStatus: .completed,
                memberCount: 4
            )
        ])
    )
}
#endif
