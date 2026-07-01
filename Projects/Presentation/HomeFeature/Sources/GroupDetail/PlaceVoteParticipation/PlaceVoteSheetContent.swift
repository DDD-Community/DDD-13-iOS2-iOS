//
//  PlaceVoteSheetContent.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

// MARK: - Sheet Content

struct PlaceVoteSheetContent: View {
    let store: StoreOf<PlaceVoteParticipationFeature>
    let onFocusPlace: (MapCoordinate) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PlaceVoteHeader(store: store)

            PlaceVoteList(
                candidates: store.candidates,
                mode: store.mode,
                selectedPlaceIds: store.selectedPlaceIds,
                topPlaceId: store.topPlaceId,
                onTap: { focus($0) },
                onSelect: { store.send(.placeSelected($0)) }
            )
        }
        .padding(.bottom, UIScreen.safeAreaBottom + PlaceVoteButtonArea.height)
    }

    /// 멤버별 경로를 조회하고, 후보 좌표가 있으면 지도 포커싱을 요청한다.
    private func focus(_ candidate: PlaceVoteCandidate) {
        store.send(.placeRowTapped(candidate.id))

        guard
            let latitude = candidate.latitude,
            let longitude = candidate.longitude
        else { return }

        onFocusPlace(MapCoordinate(latitude: latitude, longitude: longitude))
    }
}

// MARK: - Sheet Header

private struct PlaceVoteHeader: View {
    let store: StoreOf<PlaceVoteParticipationFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing150) {
            BangawoText("약속 장소 투표하기", textStyle: .titleLarge)
                .foregroundStyle(Colors.gray800)

            HStack(spacing: Spacing.spacing100) {
                DeadlineDescription(deadline: store.deadline)

                if store.mode == .voted {
                    Button {
                        store.send(.participantsButtonTapped)
                    } label: {
                        HStack(spacing: Spacing.spacing100) {
                            BangawoText("\(store.votedCount)명 참여중", textStyle: .bodyMediumEmphasized)
                                .foregroundStyle(Colors.gray700)

                            Image.Asset.icArrowSmallRight16
                                .renderingMode(.template)
                                .foregroundStyle(Colors.gray700)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.spacing300)
        .padding(.bottom, Spacing.spacing200)
        .padding(.horizontal, Spacing.spacing400)
    }
}

// MARK: - Place Vote List

private struct PlaceVoteList: View {
    let candidates: [PlaceVoteCandidate]
    let mode: PlaceVoteParticipationFeature.Mode
    let selectedPlaceIds: Set<Int>
    let topPlaceId: Int?
    let onTap: (PlaceVoteCandidate) -> Void
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: Spacing.spacing250) {
            ForEach(candidates) { candidate in
                PlaceVoteRow(
                    candidate: candidate,
                    mode: mode,
                    isSelected: selectedPlaceIds.contains(candidate.id),
                    isTop: topPlaceId == candidate.id,
                    onTap: { onTap(candidate) },
                    onSelect: { onSelect(candidate.id) }
                )
            }
        }
        .padding(.top, Spacing.spacing300)
        .padding(.bottom, Spacing.spacing400)
        .padding(.horizontal, Spacing.spacing400)
    }
}

// MARK: - Place Vote Row

private struct PlaceVoteRow: View {
    let candidate: PlaceVoteCandidate
    let mode: PlaceVoteParticipationFeature.Mode
    let isSelected: Bool
    let isTop: Bool
    /// row 전체 탭. 해당 장소 좌표로 지도를 포커싱한다.
    let onTap: () -> Void
    /// checkbox 탭. 후보를 투표 대상으로 선택한다.
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            if mode == .voting {
                Checkbox(
                    variant: .circle,
                    state: isSelected ? .enabled : .disabled,
                    size: .small
                )
                .contentShape(Rectangle())
                .onTapGesture { onSelect() }
            }

            PlaceCategoryIcon(category: candidate.categoryLabel)
                .frame(width: Metric.categoryIconLength, height: Metric.categoryIconLength)

            VStack(alignment: .leading, spacing: Spacing.spacing50) {
                BangawoText(candidate.name, textStyle: .bodyMediumEmphasized)
                    .foregroundStyle(Colors.gray800)

                BangawoText(candidate.address, textStyle: .bodySmall)
                    .foregroundStyle(Colors.gray700)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if mode == .voted {
                VoteResult(isTop: isTop, voteCount: candidate.voteCount)
            }
        }
        .padding(Spacing.spacing250)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                .stroke(borderColor, lineWidth: BorderWidth.borderWidth100)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }

    private var backgroundColor: Color {
        if mode == .voted, isTop { return Colors.orange100 }
        if mode == .voting, isSelected { return Colors.gray50 }

        return Colors.gray50
    }

    private var borderColor: Color {
        if mode == .voted, isTop { return Colors.orange300 }
        if mode == .voting, isSelected { return Colors.gray200 }

        return Colors.gray200
    }
}

// MARK: - Vote Result

private struct VoteResult: View {
    let isTop: Bool
    let voteCount: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.spacing100) {
            if isTop {
                BangawoText("1위", textStyle: .labelXSmall)
                    .foregroundStyle(Colors.gray00)
                    .padding(.vertical, Spacing.spacing25)
                    .padding(.horizontal, Spacing.spacing200)
                    .background(
                        Capsule().fill(Colors.orange500)
                    )
            }

            BangawoText("\(voteCount)명 투표", textStyle: .bodyXSmall)
                .foregroundStyle(Colors.gray700)
        }
        .padding(.trailing, Spacing.spacing100)
    }
}

// MARK: - Category Icon

private struct PlaceCategoryIcon: View {
    let category: PlaceCategory

    var body: some View {
        category.pinIcon
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
    }
}

// MARK: - Deadline Description

private struct DeadlineDescription: View {
    let deadline: String?

    @State private var now = Date()

    var body: some View {
        Group {
            if let remaining = remaining(now: now) {
                if remaining.isExpired {
                    BangawoText("투표 종료", textStyle: .bodySmall)
                        .foregroundStyle(Colors.gray700)
                } else {
                    HStack(spacing: 0) {
                        BangawoText(timeText(for: remaining), textStyle: .bodySmall)
                            .foregroundStyle(Colors.orange600)

                        BangawoText(" 후 종료", textStyle: .bodySmall)
                            .foregroundStyle(Colors.gray700)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onReceive(Countdown.everySecond) { now = $0 }
    }

    /// 마감 문자열을 UTC instant로 파싱해 잔여 시간을 계산한다. 파싱 실패 시 nil(표시 안 함).
    private func remaining(now: Date) -> Countdown.Remaining? {
        guard
            let deadline,
            let date = DateFormatterStore.date(
                from: deadline,
                format: "yyyy-MM-dd'T'HH:mm:ss",
                locale: "en_US_POSIX",
                timeZone: "UTC"
            )
        else { return nil }

        return Countdown.remaining(until: date, now: now)
    }

    /// "{N일 }HH:MM:SS" 형식의 잔여 시간 텍스트.
    private func timeText(for remaining: Countdown.Remaining) -> String {
        remaining.days > 0
            ? "\(remaining.days)일 \(remaining.clockText)"
            : remaining.clockText
    }
}

// MARK: - Constants

private enum Metric {
    /// 카테고리 아이콘 한 변 길이.
    static let categoryIconLength: CGFloat = 32
}
