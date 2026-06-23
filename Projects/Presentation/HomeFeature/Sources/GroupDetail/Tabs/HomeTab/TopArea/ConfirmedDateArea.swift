//
//  ConfirmedDateArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity
import Utill

// MARK: - 케이스 2: 약속 날짜 확정 (completed / recommended)

struct ConfirmedDateArea: View {
    let store: StoreOf<HomeTabFeature>

    private var confirmedDate: Date? {
        guard let confirmedDate = store.groupDetail?.confirmedDate else { return nil }
        return ConfirmedDateFormatter.date(from: confirmedDate)
    }

    private var dayNumber: String {
        confirmedDate.map { DateFormatterStore.day.string(from: $0) } ?? "-"
    }

    private var weekdayEnglish: String {
        confirmedDate.map { DateFormatterStore.weekdayEnglish.string(from: $0).uppercased() } ?? ""
    }

    private var fullDateLabel: String {
        guard let confirmedDate else { return "약속 날짜를 불러오는 중이에요" }
        return DateFormatterStore.string(from: confirmedDate, format: "M월 d일(E) a h시 mm분")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing250) {
            BangawoText("약속 날짜 확정", textStyle: .titleMedium)
                .foregroundStyle(Colors.gray900)

            VStack(alignment: .trailing, spacing: Spacing.spacing200) {
                HStack(spacing: Sizing.sizing75) {
                    VStack(spacing: Spacing.spacing50) {
                        BangawoText(dayNumber, textStyle: .titleMediumEmphasized)
                            .foregroundStyle(Colors.gray900)

                        BangawoText(weekdayEnglish, textStyle: .bodyXSmall)
                            .foregroundStyle(Colors.gray700)
                    }
                    .padding(.vertical, Spacing.spacing150)
                    .padding(.horizontal, Spacing.spacing250)
                    .background(
                        RoundedRectangle(cornerRadius: BorderRadius.borderRadius250)
                            .fill(Colors.gray200)
                    )

                    VStack(alignment: .leading, spacing: Spacing.spacing50) {
                        BangawoText("약속 날짜", textStyle: .bodySmall)
                            .foregroundStyle(Colors.gray700)

                        BangawoText(fullDateLabel, textStyle: .titleSmall)
                            .foregroundStyle(Colors.gray800)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                BangawoButton("장소고르기", variant: .solid, size: .small) {
                    store.send(.selectPlaceTapped)
                }
            }
            .padding(Spacing.spacing300)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .fill(
                        RadialGradient(
                            colors: [Colors.neutralAlpha700, Colors.neutralAlpha900],
                            center: .center,
                            startRadius: 0,
                            endRadius: Metric.cardGradientRadius
                        )
                    )
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Spacing.spacing400)
        .padding(.top, Spacing.spacing400)
        .padding(.bottom, Spacing.spacing500)
    }
}

// MARK: - Constants

private enum Metric {
    static let cardGradientRadius: CGFloat = 300
}

private enum ConfirmedDateFormatter {
    static func date(from raw: String) -> Date? {
        // 서버 confirmedDate는 타임존 없는 로컬 날짜 문자열로 내려온다. 예: 2026-06-25T10:00:00
        if let date = DateFormatterStore.date(from: raw, format: "yyyy-MM-dd'T'HH:mm:ss") {
            return date
        }

        if let date = DateFormatterStore.date(from: raw, format: "yyyy-MM-dd'T'HH:mm:ss.SSS") {
            return date
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: raw) {
            return date
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        return isoFormatter.date(from: raw)
    }
}
