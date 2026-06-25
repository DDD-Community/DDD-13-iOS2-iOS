//
//  PlaceVoteParticipantsView.swift
//  Presentation
//

import SwiftUI

import DesignSystem
import Entity

// MARK: - Place Vote Participants

/// 장소 투표에 참여 중인 팀원 현황 화면.
/// 멤버 리스트를 노출하고, 각 멤버의 투표 참여 여부를 trailing 에 표기한다.
struct PlaceVoteParticipantsView: View {
    let members: [GroupDetailMember]
    /// 내가 투표를 완료했는지 여부. (멤버별 투표 여부 데이터가 없어 "나" 만 정확히 반영)
    let isMyVoteCompleted: Bool
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                trailingIcons: [
                    NavigationIconItem(icon: .close24, action: onClose)
                ]
            )

            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.spacing400) {
                    BangawoText("현재 참여 중인 팀원", textStyle: .titleMedium)
                        .foregroundStyle(Colors.gray900)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ParticipantsList(members: members, isMyVoteCompleted: isMyVoteCompleted)
                }
                .padding(.horizontal, Spacing.spacing400)
                .padding(.top, Spacing.spacing200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.gray00)
    }
}

// MARK: - Participants List

/// 팀원 수 라벨과 멤버 행 리스트.
private struct ParticipantsList: View {
    let members: [GroupDetailMember]
    let isMyVoteCompleted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BangawoText("팀원 \(members.count)명", textStyle: .bodySmall)
                .foregroundStyle(Colors.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.spacing100)

            ForEach(members) { member in
                ParticipantRow(
                    member: member,
                    // TODO: 서버에 후보별/멤버별 voters 필드 추가 시 실제 투표 여부로 교체
                    isVoteCompleted: member.isMe ? isMyVoteCompleted : false
                )
            }
        }
    }
}

// MARK: - Participant Row

/// 멤버 한 명을 나타내는 행. 아이콘 / 이름 / 출발지 / 투표 참여 여부로 구성된다.
private struct ParticipantRow: View {
    let member: GroupDetailMember
    let isVoteCompleted: Bool

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            HStack(spacing: Spacing.spacing250) {
                Asset(assetType: .image(profileImage), size: .s40, isSelected: false)

                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    BangawoText(member.nickname, textStyle: .titleMedium)
                        .foregroundStyle(Colors.gray900)

                    BangawoText(departureLabel, textStyle: .bodyMedium)
                        .foregroundStyle(Colors.gray700)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VoteParticipationLabel(isVoteCompleted: isVoteCompleted)
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

// MARK: - Vote Participation Label

/// 멤버의 투표 참여 여부 라벨. 완료는 강조, 미참여는 흐린 색으로 구분한다.
private struct VoteParticipationLabel: View {
    let isVoteCompleted: Bool

    var body: some View {
        BangawoText(isVoteCompleted ? "투표 완료" : "미참여", textStyle: .bodyMedium)
            .foregroundStyle(isVoteCompleted ? Colors.gray800 : Colors.gray500)
    }
}

// MARK: - Constants

private enum Constant {
    static let emptyDepartureLabel = "출발지 미설정"
}
