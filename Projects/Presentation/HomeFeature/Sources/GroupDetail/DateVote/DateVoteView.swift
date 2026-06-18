//
//  DateVoteView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 모임 날짜 투표 화면.
// TODO: 날짜 투표 기능 구현 시 실제 화면으로 교체
struct DateVoteView: View {
    let store: StoreOf<DateVoteFeature>

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                trailingIcons: [
                    NavigationIconItem(icon: .close24) { dismiss() }
                ]
            )

            BangawoText("날짜 투표 (임시)", textStyle: .bodyMedium)
                .foregroundStyle(Colors.gray600)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
