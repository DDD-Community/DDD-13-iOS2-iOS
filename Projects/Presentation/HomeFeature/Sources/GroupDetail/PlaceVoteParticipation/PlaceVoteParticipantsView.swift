//
//  PlaceVoteParticipantsView.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - Place Vote Participants

/// 장소 투표에 참여 중인 팀원 현황 화면.
/// 진입 시 참여 멤버를 조회하고, 각 멤버의 투표 참여 여부를 trailing 에 표기한다.
struct PlaceVoteParticipantsView: View {
    let store: StoreOf<PlaceVoteParticipantsFeature>
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

                    ParticipantsList(participants: store.participants)
                }
                .padding(.horizontal, Spacing.spacing400)
                .padding(.top, Spacing.spacing200)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.gray00)
        .task { store.send(.task) }
    }
}

// MARK: - Participants List

/// 팀원 수 라벨과 멤버 행 리스트.
private struct ParticipantsList: View {
    let participants: [PlaceVoteParticipant]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BangawoText("팀원 \(participants.count)명", textStyle: .bodySmall)
                .foregroundStyle(Colors.gray800)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, Spacing.spacing100)

            ForEach(participants) { participant in
                ParticipantRow(participant: participant)
            }
        }
    }
}

// MARK: - Participant Row

/// 멤버 한 명을 나타내는 행. 아이콘 / 이름 / 출발지 / 투표 참여 여부로 구성된다.
private struct ParticipantRow: View {
    let participant: PlaceVoteParticipant

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            HStack(spacing: Spacing.spacing250) {
                Avatar(avatarType: avatarType, size: .s40)

                VStack(alignment: .leading, spacing: Spacing.spacing100) {
                    BangawoText(participant.name, textStyle: .titleMedium)
                        .foregroundStyle(Colors.gray900)

                    BangawoText(departureLabel, textStyle: .bodyMedium)
                        .foregroundStyle(Colors.gray700)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            VoteParticipationLabel(isVoteCompleted: participant.voted)
        }
        .padding(.vertical, Spacing.spacing300)
    }

    /// 출발지명. 없으면 안내 문구를 노출한다.
    private var departureLabel: String {
        participant.departureName ?? Constant.emptyDepartureLabel
    }

    private var avatarType: Avatar.AvatarType {
        guard
            let urlString = participant.profileImageUrl,
            let url = URL(string: urlString)
        else { return .placeholder }

        return .image(url)
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
