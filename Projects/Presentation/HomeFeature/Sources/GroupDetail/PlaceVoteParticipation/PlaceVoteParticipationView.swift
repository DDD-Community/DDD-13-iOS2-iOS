//
//  PlaceVoteParticipationView.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

/// 약속 장소 투표 참여 화면.
/// 전체 화면 카카오맵 위에 NavigationPage 와 MapBottomSheet 가 겹쳐진 구조다.
struct PlaceVoteParticipationView: View {
    let store: StoreOf<PlaceVoteParticipationFeature>

    @Environment(\.dismiss) private var dismiss

    /// 후보 좌표로 구성한 지도 핀. `candidates` 변경 시 `.task`에서 재구성한다.
    @State private var pins: [MapPin] = []

    var body: some View {
        ZStack(alignment: .top) {
            // TODO: 멤버핀, 경로 표기는 멤버 좌표/경로 데이터 확보 후 연동
            KakaoMap(
                pins: pins,
                initialCenter: mapCenter,
                initialZoomLevel: mapZoomLevel
            )
            .ignoresSafeArea()

            NavigationPage(
                background: .clear,
                trailingIcons: [
                    NavigationIconItem(icon: .close24) { dismissCover() }
                ]
            )

            MapBottomSheet(detents: [.medium, .large], initialDetent: .medium) {
                PlaceVoteSheetContent(store: store)
                    .padding(.horizontal, Spacing.spacing400)
            }

            PlaceVoteButtonArea(store: store, onComplete: dismissCover)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .task(id: store.candidates.map(\.id)) {
            buildPins()
        }
    }

    private func dismissCover() {
        dismiss()
    }

    @MainActor
    private func buildPins() {
        pins = store.candidates.compactMap { candidate in
            guard
                let latitude = candidate.latitude,
                let longitude = candidate.longitude
            else { return nil }

            return MapPinLabel(image: candidate.categoryLabel.pinIcon, title: candidate.name)
                .makePin(
                    id: String(candidate.id),
                    coordinate: MapCoordinate(latitude: latitude, longitude: longitude)
                )
        }
    }

    /// 위경도가 모두 존재하는 후보의 좌표 목록.
    private var coordinates: [MapCoordinate] {
        store.candidates.compactMap { candidate in
            guard
                let latitude = candidate.latitude,
                let longitude = candidate.longitude
            else { return nil }

            return MapCoordinate(latitude: latitude, longitude: longitude)
        }
    }

    /// 후보 좌표들의 bounding box 중심. 좌표가 없으면 기본 중심을 반환한다.
    private var mapCenter: MapCoordinate {
        guard !coordinates.isEmpty else { return Constant.defaultCenter }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let centerLatitude = ((latitudes.min() ?? 0) + (latitudes.max() ?? 0)) / 2
        let centerLongitude = ((longitudes.min() ?? 0) + (longitudes.max() ?? 0)) / 2

        return MapCoordinate(latitude: centerLatitude, longitude: centerLongitude)
    }

    /// 모든 후보 핀이 보이도록 bounding box span 으로 근사 계산한 줌 레벨.
    private var mapZoomLevel: Int {
        guard coordinates.count > 1 else { return Constant.singlePinZoomLevel }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let latitudeSpan = (latitudes.max() ?? 0) - (latitudes.min() ?? 0)
        let longitudeSpan = (longitudes.max() ?? 0) - (longitudes.min() ?? 0)
        let span = max(latitudeSpan, longitudeSpan)

        if span < 0.005 { return 16 }
        if span < 0.01 { return 15 }
        if span < 0.02 { return 14 }
        if span < 0.04 { return 13 }
        if span < 0.08 { return 12 }

        return 11
    }
}

// MARK: - Sheet Content

private struct PlaceVoteSheetContent: View {
    let store: StoreOf<PlaceVoteParticipationFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing300) {
            PlaceVoteHeader(store: store)

            VStack(spacing: Spacing.spacing200) {
                ForEach(store.candidates) { candidate in
                    PlaceVoteRow(
                        candidate: candidate,
                        mode: store.mode,
                        isSelected: store.selectedPlaceId == candidate.id,
                        isTop: store.topPlaceId == candidate.id,
                        onTap: { store.send(.placeSelected(candidate.id)) }
                    )
                }
            }
        }
        .padding(.top, Spacing.spacing100)
    }
}

// MARK: - Sheet Header

private struct PlaceVoteHeader: View {
    let store: StoreOf<PlaceVoteParticipationFeature>

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing150) {
            BangawoText("약속 장소 투표하기", textStyle: .titleLarge)
                .foregroundStyle(Colors.gray800)

            HStack(spacing: 0) {
                DeadlineDescription(deadline: store.deadline)

                if store.mode == .voted {
                    BangawoText(" · 현재 \(store.votedCount)명 참여", textStyle: .bodySmall)
                        .foregroundStyle(Colors.gray700)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Button Area

private struct PlaceVoteButtonArea: View {
    let store: StoreOf<PlaceVoteParticipationFeature>
    let onComplete: () -> Void

    var body: some View {
        switch store.mode {
        case .voting:
            if store.selectedPlaceId != nil {
                ActionButton(
                    buttonLayout: .single(
                        title: "투표하기",
                        isDisabled: store.isSubmitting,
                        action: { store.send(.voteButtonTapped) }
                    ),
                    hasGradientBackground: true
                )
                .padding(.bottom, Spacing.spacing200)
                .ignoresSafeArea(edges: .bottom)
            }

        case .voted:
            ActionButton(
                buttonLayout: .dual(
                    primaryTitle: "완료",
                    primaryAction: {
                        store.send(.completeButtonTapped)
                        onComplete()
                    },
                    secondaryTitle: "다시 투표하기",
                    secondaryAction: { store.send(.revoteButtonTapped) },
                    arrangement: .horizontal
                ),
                hasGradientBackground: true
            )
            .padding(.bottom, Spacing.spacing200)
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Place Vote Row

private struct PlaceVoteRow: View {
    let candidate: PlaceVoteCandidate
    let mode: PlaceVoteParticipationFeature.Mode
    let isSelected: Bool
    let isTop: Bool
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: Spacing.spacing200) {
            if mode == .voting {
                Checkbox(
                    variant: .circle,
                    state: isSelected ? .enabled : .disabled,
                    size: .small
                )
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
                voteResult
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
        .onTapGesture {
            guard mode == .voting else { return }

            onTap()
        }
    }

    private var voteResult: some View {
        VStack(alignment: .trailing, spacing: Spacing.spacing50) {
            if isTop {
                Badge("1위", variant: .solid, size: .small)
            }

            BangawoText("\(candidate.voteCount)명 투표", textStyle: .bodySmall)
                .foregroundStyle(Colors.gray700)
        }
    }

    private var backgroundColor: Color {
        if mode == .voted, isTop { return Colors.orange100 }
        if mode == .voting, isSelected { return Colors.gray200 }

        return Colors.gray50
    }

    private var borderColor: Color {
        if mode == .voted, isTop { return Colors.orange300 }
        if mode == .voting, isSelected { return Colors.gray300 }

        return Colors.gray200
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

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if let remaining = PlaceVoteCountdown.remaining(deadline, now: now) {
                if remaining.isExpired {
                    BangawoText("투표 종료", textStyle: .bodySmall)
                        .foregroundStyle(Colors.gray700)
                } else {
                    HStack(spacing: 0) {
                        BangawoText(remaining.timeText, textStyle: .bodySmall)
                            .foregroundStyle(Colors.orange600)

                        BangawoText(" 후 종료", textStyle: .bodySmall)
                            .foregroundStyle(Colors.gray700)
                    }
                }
            }
        }
        .onReceive(timer) { now = $0 }
    }
}

// MARK: - Countdown Formatter

private enum PlaceVoteCountdown {
    struct Remaining {
        let timeText: String
        let isExpired: Bool
    }

    /// `now` 기준 마감까지 남은 시간 컴포넌트. 파싱 실패 시 nil(표시 안 함).
    static func remaining(_ raw: String?, now: Date) -> Remaining? {
        guard
            let raw,
            let date = DateFormatterStore.date(
                from: raw,
                format: "yyyy-MM-dd'T'HH:mm:ss",
                locale: "en_US_POSIX",
                timeZone: "UTC"
            )
        else { return nil }

        let total = max(0, Int(date.timeIntervalSince(now)))
        guard total > 0 else { return Remaining(timeText: "", isExpired: true) }

        let days = total / 86400
        let hours = (total % 86400) / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60

        let time = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        let timeText = days > 0 ? "\(days)일 \(time)" : time

        return Remaining(timeText: timeText, isExpired: false)
    }
}

// MARK: - Constants

private enum Metric {
    /// 카테고리 아이콘 한 변 길이.
    static let categoryIconLength: CGFloat = 32
}

private enum Constant {
    /// 후보 좌표가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
    /// 후보가 1개일 때 사용하는 기본 줌 레벨.
    static let singlePinZoomLevel = 16
}
