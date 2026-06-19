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
        switch store.homeTopAreaKind {
        case .dateVote:
            DateVoteTopPage(store: store)

        case .confirmedDate:
            ConfirmedDateArea(store: store)

        case .locationVote:
            LocationVoteArea(store: store)

        case .confirmedPlace:
            ConfirmedPlaceArea(store: store)

        case .default:
            DefaultTopPage(store: store)
        }
    }
}

// MARK: - Default Top Page (before / before)

private struct DefaultTopPage: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        TopPage(
            d3Asset: .groupDetail,
            title: store.group.name,
            description: store.group.themeTagDisplay,
            buttonTitle: "장소 정하기",
            buttonVariant: .solid,
            buttonSize: .small,
            showButton: store.isMeHost,
            showLowerArea: false,
            buttonAction: { store.send(.decidePlaceTapped) }
        )
    }
}
