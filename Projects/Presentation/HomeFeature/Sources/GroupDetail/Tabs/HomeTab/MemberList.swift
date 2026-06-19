//
//  MemberList.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - Member List

/// 홈 탭의 멤버 리스트 영역.
/// 멤버가 있으면 "나" 영역과 팀원 리스트를, 없으면 친구 초대 버튼을 노출한다.
struct MemberList: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        // 상세 로드 전에는 멤버 영역을 비워 두고, 로드 후 멤버 유무에 따라 분기한다.
        if let members = store.groupDetail?.members {
            if members.isEmpty {
                InviteFriendButton {
                    store.send(.inviteFriendTapped)
                }
            } else {
                VStack(spacing: Spacing.spacing250) {
                    if let me = members.first(where: { $0.isMe }) {
                        MeArea(member: me) {
                            store.send(.myAttendanceBadgeTapped)
                        }
                    }

                    let others = members.filter { !$0.isMe }
                    if !others.isEmpty {
                        MembersListArea(members: others)
                    }
                }
            }
        }
    }
}

// MARK: - Me Area

/// "나" 영역. 공통 멤버 행에 좌우 패딩과 카드 배경을 더한다.
private struct MeArea: View {
    let member: GroupDetailMember
    let onAttendanceTap: () -> Void

    var body: some View {
        MemberRow(member: member, isMe: true, onAttendanceTap: onAttendanceTap)
            .padding(.horizontal, Spacing.spacing300)
            .memberCardBackground()
    }
}

// MARK: - Members List Area

/// 나를 제외한 팀원 리스트 영역. 팀원 수 라벨과 멤버 행 리스트를 카드 배경 안에 담는다.
private struct MembersListArea: View {
    let members: [GroupDetailMember]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BangawoText("팀원 \(members.count)명", textStyle: .bodySmall)
                .foregroundStyle(Colors.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.spacing100)

            ForEach(members) { member in
                MemberRow(member: member, isMe: false, onAttendanceTap: {})
            }
        }
        .padding(Spacing.spacing300)
        .memberCardBackground()
    }
}

// MARK: - Member Row

/// 멤버 한 명을 나타내는 공통 컴포넌트. 아이콘 / 이름 / 출발지 / 참여 여부 뱃지로 구성된다.
private struct MemberRow: View {
    let member: GroupDetailMember
    let isMe: Bool
    let onAttendanceTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            HStack(spacing: Spacing.spacing250) {
                Asset(assetType: .image(profileImage), size: .s40, isSelected: false)

                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    HStack(spacing: Spacing.spacing100) {
                        BangawoText(member.nickname, textStyle: .titleMedium)
                            .foregroundStyle(Colors.gray900)

                        if isMe {
                            MeChip()
                        }
                    }

                    BangawoText(departureLabel, textStyle: .bodyMedium)
                        .foregroundStyle(Colors.gray700)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            AttendanceBadge(
                status: member.attendanceStatus,
                showTrailingIcon: isMe,
                isInteractive: isMe,
                onTap: onAttendanceTap
            )
        }
        .padding(.vertical, Spacing.spacing300)
    }

    /// 기본 출발지(없으면 첫 출발지)의 장소명. 출발지가 없으면 안내 문구를 노출한다.
    private var departureLabel: String {
        let place = member.departurePlaces.first(where: { $0.isDefault })
            ?? member.departurePlaces.first
        return place?.placeName ?? Constant.emptyDepartureLabel
    }

    // TODO: profileImageUrl 비동기 이미지 로드 연동 시 교체
    private var profileImage: Image {
        Image.Asset.imgAvatarPlaceholder
    }
}

// MARK: - Me Chip

/// 멤버 이름 좌측에 붙는 "나" 라벨 칩.
private struct MeChip: View {
    var body: some View {
        BangawoText("나", textStyle: .bodySmall)
            .foregroundStyle(Colors.gray700)
            .padding(.vertical, Metric.meChipVerticalPadding)
            .padding(.horizontal, Spacing.spacing200)
            .overlay(
                Capsule()
                    .stroke(Colors.gray400, lineWidth: BorderWidth.borderWidth100)
            )
    }
}

// MARK: - Attendance Badge

/// 참여 여부 뱃지. 상태별 컬러 dot을 leading으로 노출하고,
/// "나" 영역에서는 trailing 화살표와 탭 인터랙션을 추가한다.
private struct AttendanceBadge: View {
    let status: AttendanceStatus
    let showTrailingIcon: Bool
    let isInteractive: Bool
    let onTap: () -> Void

    var body: some View {
        if isInteractive {
            Button(action: onTap) { badge }
                .buttonStyle(.plain)
        } else {
            badge
        }
    }

    private var badge: some View {
        Badge(
            status.displayLabel,
            leadingIcon: status.dotIcon,
            trailingIcon: Image.Asset.icArrowSmallDown16,
            showLeadingIcon: true,
            showTrailingIcon: showTrailingIcon,
            leadingIconColor: nil,
            trailingIconColor: Colors.gray800,
            variant: .solid,
            size: .medium
        )
    }
}

// MARK: - Invite Friend Button

private struct InviteFriendButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing250) {
                Image.Asset.icPlus24
                    .resizable()
                    .frame(width: Sizing.sizing200, height: Sizing.sizing200)

                BangawoText("친구 초대하기", textStyle: .bodyLarge)
                    .foregroundStyle(Colors.gray800)
            }
            .padding(Spacing.spacing200)
            .padding(Spacing.spacing200)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .fill(Colors.gray50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .stroke(Colors.gray200, lineWidth: BorderWidth.borderWidth150)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Attendance Status Mapping

private extension AttendanceStatus {
    /// 참여 상태별 컬러 dot 아이콘. (Entity 가 DesignSystem 을 의존할 수 없어 Presentation 에 둔다.)
    var dotIcon: Image {
        switch self {
        case .join: return Image.Asset.icDotGreen16
        case .late: return Image.Asset.icDotOrange16
        case .absent: return Image.Asset.icDotRed16
        case .unknown: return Image.Asset.icDotGray16
        }
    }
}

// MARK: - Member Card Background

private extension View {
    /// 멤버 카드 공통 배경: radial gradient + 1px 보더.
    func memberCardBackground() -> some View {
        background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .fill(
                    RadialGradient(
                        colors: [Colors.grayAlpha50, Colors.grayAlpha100],
                        center: .center,
                        startRadius: 0,
                        endRadius: Metric.cardGradientRadius
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                .stroke(Colors.gray200, lineWidth: BorderWidth.borderWidth100)
        )
    }
}

// MARK: - Constants

private enum Metric {
    static let cardGradientRadius: CGFloat = 160
    static let meChipVerticalPadding: CGFloat = 1
}

private enum Constant {
    static let emptyDepartureLabel = "출발지 미설정"
}
