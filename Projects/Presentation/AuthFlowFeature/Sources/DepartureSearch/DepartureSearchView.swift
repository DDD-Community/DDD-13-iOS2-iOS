//
//  DepartureSearchView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import Entity

public struct DepartureSearchView: View {
    @Bindable private var store: StoreOf<DepartureSearchFeature>
    @State private var isToastVisible = false

    public init(store: StoreOf<DepartureSearchFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                leadingAction: { store.send(.backButtonTapped) }
            )

            if store.selectedStation == nil {
                TopHero(
                    asset: Image.Asset.imgDeparture3d,
                    title: "출발지를 입력해 주세요",
                    description: "첫 입력 후에는 알아서 기억할게요",
                    assetSize: .large
                )
            } else {
                TopHero(
                    title: "이 위치에서 출발하시나요?",
                    description: "앞으로 장소 선정의 기준이 될게요"
                )
            }

            SearchArea(store: store)

            if store.selectedStation != nil {
                ActionButton(
                    buttonLayout: .single(title: "시작하기") {
                        store.send(.nextButtonTapped)
                    },
                    upperContent: .toast(message: "출발지가 등록되었어요"),
                    isUpperContentVisible: $isToastVisible
                )
            }
        }
        .onChange(of: store.selectedStation) { _, new in
            guard new != nil else { return }
            // 이미 토스트가 노출 중일 때도 재선택 시 다시 보여주기 위해 리셋 후 재발화
            isToastVisible = false
            Task { @MainActor in isToastVisible = true }
        }
        .fullScreenCover(
            item: $store.scope(state: \.searchSheet, action: \.searchSheet)
        ) { sheetStore in
            StationSearchSheet(store: sheetStore)
        }
    }
}

// MARK: - Preview

#Preview("출발지 미선택") {
    BangawoPreview {
        DepartureSearchView(
            store: Store(initialState: DepartureSearchFeature.State()) {
                DepartureSearchFeature()
            }
        )
    }
}

#Preview("역 선택 후") {
    BangawoPreview {
        DepartureSearchView(
            store: Store(
                initialState: DepartureSearchFeature.State(
                    selectedStation: Station(
                        id: "1",
                        name: "강남역",
                        addressName: "서울 강남구 역삼동",
                        roadAddressName: "서울 강남구 강남대로 396",
                        x: 127.0276368,
                        y: 37.4979502
                    )
                )
            ) {
                DepartureSearchFeature()
            }
        )
    }
}

// MARK: - SearchArea

private struct SearchArea: View {
    let store: StoreOf<DepartureSearchFeature>

    var body: some View {
        VStack(spacing: 0) {
            SearchField(
                placeholder: "역 이름 또는 주소 검색",
                text: .constant(store.selectedStation?.name ?? "")
            )
            .overlay(
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { store.send(.searchTriggerTapped) }
            )
            Color.clear.frame(maxHeight: .infinity)
        }
        .padding(.horizontal, Spacing.spacing450)
    }
}
