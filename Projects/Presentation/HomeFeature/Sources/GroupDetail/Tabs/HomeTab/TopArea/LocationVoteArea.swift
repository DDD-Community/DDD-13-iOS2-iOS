//
//  LocationVoteArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

// MARK: - 케이스 3: 장소 투표 (completed / voting)

struct LocationVoteArea: View {
    let store: StoreOf<HomeTabFeature>

    /// 후보 좌표로 구성한 지도 핀. `candidates` 변경 시 `.task`에서 재구성한다.
    @State private var pins: [MapPin] = []

    private var candidates: [PlaceVoteCandidate] {
        store.placeVote?.candidates ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TitleArea(deadline: store.placeVote?.deadline)

            MapArea(
                pins: pins,
                candidates: candidates,
                totalParticipants: store.placeVote?.totalParticipants ?? 0
            )

            VoteButton {
                store.send(.placeVoteParticipationTapped)
            }
        }
        .padding(.vertical, Spacing.spacing300)
        .padding(.horizontal, Spacing.spacing350)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius400)
                .fill(Colors.white)
        )
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
        .task(id: candidates.map(\.id)) {
            buildPins()
        }
    }

    @MainActor
    private func buildPins() {
        pins = candidates.compactMap { candidate in
            guard
                let latitude = candidate.latitude,
                let longitude = candidate.longitude
            else { return nil }

            return MapPinLabel(assetName: Constant.placePinAsset, title: candidate.name)
                .makePin(
                    id: String(candidate.id),
                    coordinate: MapCoordinate(latitude: latitude, longitude: longitude)
                )
        }
    }
}

// MARK: - Title Area

private struct TitleArea: View {
    let deadline: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing100) {
            BangawoText("약속 장소 투표하기", textStyle: .titleMedium)
                .foregroundStyle(Colors.gray800)

            DeadlineDescription(deadline: deadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, Spacing.spacing100)
        .padding(.bottom, Spacing.spacing200)
    }
}

// MARK: - Deadline Description

private struct DeadlineDescription: View {
    let deadline: String?

    @State private var now = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if let remaining = PlaceVoteFormatter.remaining(deadline, now: now) {
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

// MARK: - Map Area

private struct MapArea: View {
    let pins: [MapPin]
    let candidates: [PlaceVoteCandidate]
    let totalParticipants: Int

    var body: some View {
        KakaoMap(
            pins: pins,
            initialCenter: mapCenter,
            initialZoomLevel: mapZoomLevel
        )
        .allowsHitTesting(false)
        .clipShape(RoundedRectangle(cornerRadius: BorderRadius.borderRadius400))
        .overlay(alignment: .bottom) {
            ParticipantLabel(totalParticipants: totalParticipants)
                .padding(.bottom, Metric.participantLabelBottomInset)
        }
        .aspectRatio(Metric.mapAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }

    /// 위경도가 모두 존재하는 후보의 좌표 목록.
    private var coordinates: [MapCoordinate] {
        candidates.compactMap { candidate in
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

    /// 모든 후보 핀이 보이도록 bounding box span으로 근사 계산한 줌 레벨.
    /// KakaoMap에 fit-bounds API가 없어 span→level 휴리스틱으로 산출한다.
    private var mapZoomLevel: Int {
        guard coordinates.count > 1 else { return Constant.singlePinZoomLevel }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let latitudeSpan = (latitudes.max() ?? 0) - (latitudes.min() ?? 0)
        let longitudeSpan = (longitudes.max() ?? 0) - (longitudes.min() ?? 0)

        return zoomLevel(forSpan: max(latitudeSpan, longitudeSpan))
    }

    private func zoomLevel(forSpan span: Double) -> Int {
        if span < 0.005 { return 16 }
        if span < 0.01 { return 15 }
        if span < 0.02 { return 14 }
        if span < 0.04 { return 13 }
        if span < 0.08 { return 12 }

        return 11
    }
}

// MARK: - Participant Label

private struct ParticipantLabel: View {
    let totalParticipants: Int

    var body: some View {
        HStack(spacing: Spacing.spacing100) {
            AssetPack(avatarTypes: avatarTypes)

            BangawoText("현재 \(totalParticipants)명 참여 중", textStyle: .bodySmall)
                .foregroundStyle(Colors.gray700)
        }
        .padding(.vertical, Spacing.spacing150)
        .padding(.horizontal, Spacing.spacing250)
        .background(Capsule().fill(Colors.gray00))
        .overlay(
            Capsule().stroke(Colors.gray100, lineWidth: BorderWidth.borderWidth100)
        )
        .tokenShadow(BoxShadow.boxShadow100)
    }

    private var avatarTypes: [Avatar.AvatarType] {
        Array(repeating: .placeholder, count: min(totalParticipants, AssetPack.Metric.maxVisible))
    }
}

// MARK: - Vote Button

private struct VoteButton: View {
    let onTap: () -> Void

    var body: some View {
        BangawoButton(
            "약속 장소 투표하기",
            variant: .solid,
            size: .medium,
            widthType: .maxWidth,
            action: onTap
        )
        .padding(.top, Spacing.spacing300)
        .padding(.bottom, Spacing.spacing200)
    }
}

// MARK: - Place Vote Formatter

private enum PlaceVoteFormatter {
    /// 마감까지 남은 시간 표시 값. orange 영역에 들어갈 `"{N일 }HH:MM:SS"` 텍스트와 마감 여부를 담는다.
    struct Remaining {
        let timeText: String
        let isExpired: Bool
    }

    /// `now` 기준 마감까지 남은 시간 컴포넌트. 파싱 실패 시 nil(표시 안 함).
    /// deadline은 UTC instant로 파싱되고 `now`도 절대값이므로 timeIntervalSince로 잔여 초를 직접 구한다.
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
    /// 지도 가로:세로 비율 (가로 287 / 세로 160).
    static let mapAspectRatio: CGFloat = 287.0 / 160.0
    /// 참여 라벨을 지도 하단에서 띄우는 여백.
    static let participantLabelBottomInset: CGFloat = 14
}

private enum Constant {
    /// 후보 장소 핀에 사용하는 아이콘 에셋.
    static let placePinAsset = "ic_pin_24"
    /// 후보 좌표가 없을 때 사용하는 기본 지도 중심(서울 시청).
    static let defaultCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)
    /// 후보가 1개일 때 사용하는 기본 줌 레벨.
    static let singlePinZoomLevel = 16
}
