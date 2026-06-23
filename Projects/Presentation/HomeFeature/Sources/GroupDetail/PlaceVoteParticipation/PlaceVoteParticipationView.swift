//
//  PlaceVoteParticipationView.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 약속 장소 투표 참여 화면.
// TODO: 장소 투표 참여 기능 구현 시 실제 화면으로 교체
struct PlaceVoteParticipationView: View {
    let store: StoreOf<PlaceVoteParticipationFeature>

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                trailingIcons: [
                    NavigationIconItem(icon: .close24) { dismiss() }
                ]
            )

            BangawoText("약속 장소 투표 (임시)", textStyle: .bodyMedium)
                .foregroundStyle(Colors.gray600)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
