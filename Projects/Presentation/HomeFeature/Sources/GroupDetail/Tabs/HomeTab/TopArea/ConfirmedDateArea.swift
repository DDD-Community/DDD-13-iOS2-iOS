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
    @Dependency(\.calendar) private var calendar

    // TODO: GroupDetail.confirmedDate 모델 연동 시 임시 Date 교체 + 서버 포맷 파싱
    private var confirmedDate: Date { Constant.tempConfirmedDate(calendar: calendar) }

    private var dayNumber: String { DateFormatterStore.day.string(from: confirmedDate) }
    private var weekdayEnglish: String { DateFormatterStore.weekdayEnglish.string(from: confirmedDate).uppercased() }
    private var fullDateLabel: String { DateFormatterStore.full.string(from: confirmedDate) }

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

private enum Constant {
    static func tempConfirmedDate(calendar: Calendar) -> Date {
        var components = DateComponents()
        components.year = 2026
        components.month = 6
        components.day = 28
        components.hour = 18
        components.minute = 30
        return calendar.date(from: components) ?? Date()
    }
}
