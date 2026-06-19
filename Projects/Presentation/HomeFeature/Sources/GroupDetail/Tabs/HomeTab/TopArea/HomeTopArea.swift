//
//  HomeTopArea.swift
//  Presentation
//

import Foundation
import SwiftUI

import ComposableArchitecture

import DesignSystem
import Entity

// MARK: - Home Top Area

/// 모임 진행 단계(`dateVoteStatus` × `locationStatus`)에 따라 상단 영역을 분기한다.
struct HomeTopArea: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        switch (store.group.dateVoteStatus, store.group.locationStatus) {
        case (.inProgress, .before):
            DateVoteTopPage(store: store)

        case (.completed, .recommended):
            ConfirmedDateArea(store: store)

        case (.completed, .voting):
            LocationVoteArea(store: store)

        case (.completed, .confirmed):
            ConfirmedPlaceArea(store: store)

        default:
            DefaultTopPage(store: store)
        }
    }
}

// MARK: - Default Top Page (before / before)

struct DefaultTopPage: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        TopPage(
            d3Asset: .groupDetail,
            title: store.group.name,
            description: store.group.themeTagDisplay,
            buttonTitle: "장소 정하기",
            buttonVariant: .solid,
            buttonSize: .small,
            showLowerArea: false,
            buttonAction: { store.send(.decidePlaceTapped) }
        )
    }
}
