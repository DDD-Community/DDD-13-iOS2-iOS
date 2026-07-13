//
//  PlaceVoteParticipantsView.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import CoreDependencies
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
                VStack(alignment: .leading, spacing: 0) {
                    Header()
                    ParticipantsList(participants: store.participants)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Colors.gray00)
        .task { store.send(.task) }
    }
}

// MARK: - Header

/// 장소 투표 참여 현황 타이틀.
private struct Header: View {
    var body: some View {
        BangawoText("현재 참여중인 팀원", textStyle: .titleMedium)
            .foregroundStyle(Colors.gray900)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, Spacing.spacing300)
            .padding(.bottom, Spacing.spacing200)
            .padding(.horizontal, Spacing.spacing400)
    }
}

// MARK: - Participants List

/// 팀원 수 라벨과 멤버 행 리스트.
private struct ParticipantsList: View {
    let participants: [PlaceVoteParticipant]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ListHeader(count: participants.count)

            ForEach(participants) { participant in
                ParticipantRow(participant: participant)
            }
        }
        .padding(.vertical, Spacing.spacing300)
        .padding(.horizontal, Spacing.spacing400)
    }
}

// MARK: - List Header

/// 참여 팀원 수를 표시하는 리스트 헤더.
private struct ListHeader: View {
    let count: Int

    var body: some View {
        BangawoText("팀원 \(count)명", textStyle: .bodySmall)
            .foregroundStyle(Colors.gray800)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Spacing.spacing100)
    }
}

// MARK: - Participant Row

/// 멤버 한 명을 나타내는 행. 아이콘 / 이름 / 출발지 / 투표 참여 여부로 구성된다.
private struct ParticipantRow: View {
    let participant: PlaceVoteParticipant

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            memberInfo
                .frame(maxWidth: .infinity, alignment: .leading)

            VoteParticipationBadge(isVoteCompleted: participant.voted)
        }
        .padding(.vertical, Spacing.spacing300)
    }

    private var memberInfo: some View {
        HStack(spacing: Spacing.spacing250) {
            ProfileAsset(profileImageUrl: participant.profileImageUrl)

            VStack(alignment: .leading, spacing: Spacing.spacing100) {
                HStack(spacing: Spacing.spacing100) {
                    BangawoText(participant.name, textStyle: .titleMedium)
                        .foregroundStyle(Colors.gray900)

                    if participant.isMe {
                        MeChip()
                    }
                }

                BangawoText(departureLabel, textStyle: .bodyMedium)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// 출발지명. 없으면 안내 문구를 노출한다.
    private var departureLabel: String {
        participant.departureName ?? Constant.emptyDepartureLabel
    }
}

// MARK: - Profile Asset

/// 프로필 이미지를 Asset 컴포넌트 사이즈에 맞춰 노출한다.
private struct ProfileAsset: View {
    let profileImageUrl: String?

    var body: some View {
        AsyncImage(url: profileImageUrl.flatMap(URL.init(string:))) { phase in
            switch phase {
            case .success(let image):
                Asset(assetType: .image(image), size: .s40, isSelected: false)

            default:
                Asset(assetType: .image(Image.Asset.imgAvatarPlaceholder), size: .s40, isSelected: false)
            }
        }
    }
}

// MARK: - Me Chip

/// 멤버 이름 우측에 붙는 "나" 라벨 칩.
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

// MARK: - Vote Participation Badge

/// 멤버의 투표 참여 여부 라벨. 완료는 강조, 미참여는 흐린 색으로 구분한다.
private struct VoteParticipationBadge: View {
    let isVoteCompleted: Bool

    var body: some View {
        Badge(
            isVoteCompleted ? "투표 완료" : "미참여",
            variant: isVoteCompleted ? .solid : .outline,
            size: .medium
        )
    }
}

// MARK: - Constants

private enum Metric {
    static let meChipVerticalPadding: CGFloat = 3
}

private enum Constant {
    static let emptyDepartureLabel = "출발지 미설정"
}

// MARK: - Preview

#if DEBUG
private func makePlaceVoteParticipantsStore() -> StoreOf<PlaceVoteParticipantsFeature> {
    var state = PlaceVoteParticipantsFeature.State(meetingId: 1)
    state.participants = VoteClient.previewPlaceVoteParticipants

    return Store(initialState: state) {
        PlaceVoteParticipantsFeature()
    } withDependencies: {
        $0.voteClient = .previewValue
    }
}

#Preview("기본") {
    BangawoPreview {
        PlaceVoteParticipantsView(
            store: makePlaceVoteParticipantsStore(),
            onClose: {}
        )
    }
}
#endif
