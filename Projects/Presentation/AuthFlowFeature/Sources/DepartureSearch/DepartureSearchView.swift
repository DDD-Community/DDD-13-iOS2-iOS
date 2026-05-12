//
//  DepartureSearchView.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import Entity

public struct DepartureSearchView: View {
    @Bindable private var store: StoreOf<DepartureSearchFeature>

    public init(store: StoreOf<DepartureSearchFeature>) {
        self.store = store
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("\(store.nickname)님\n미리 출발지만 등록해주세요")
                .font(.title2.bold())
                .padding(.top, 16)

            SearchTriggerButton(selectedStation: store.selectedStation) {
                store.send(.searchTriggerTapped)
            }

            Color.clear.frame(maxHeight: .infinity)

            PrimaryFilledButton(
                title: "다음",
                isEnabled: store.isNextEnabled
            ) {
                store.send(.nextButtonTapped)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .sheet(
            item: $store.scope(state: \.searchSheet, action: \.searchSheet)
        ) { sheetStore in
            StationSearchSheet(store: sheetStore)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct SearchTriggerButton: View {
    private let selectedStation: Station?
    private let action: () -> Void

    init(selectedStation: Station?, action: @escaping () -> Void) {
        self.selectedStation = selectedStation
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(.systemGray2))
                Text(selectedStation?.name ?? "지역, 지하철역 명으로 찾기")
                    .font(.body)
                    .foregroundStyle(selectedStation == nil ? Color(.systemGray2) : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}
