//
//  StationSearchSheet.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import DesignSystem
import Entity

struct StationSearchSheet: View {
    @Bindable var store: StoreOf<StationSearchSheetFeature>

    var body: some View {
        VStack(spacing: 0) {
            NavigationPage(
                background: .clear,
                trailingIcons: [
                    NavigationIconItem(icon: .close24) {
                        store.send(.closeButtonTapped)
                    }
                ]
            )

            SearchField(
                placeholder: "지역, 지하철역 명으로 찾기",
                text: $store.keyword
            )
            .padding(.horizontal, Spacing.spacing450)
            .frame(maxWidth: .infinity)
            .background(Colors.gray00)

            StationResultList(
                isLoading: store.isLoading,
                stations: store.stations,
                onSelect: { station in store.send(.stationTapped(station)) }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct StationResultList: View {
    private let isLoading: Bool
    private let stations: [Station]
    private let onSelect: (Station) -> Void

    init(
        isLoading: Bool,
        stations: [Station],
        onSelect: @escaping (Station) -> Void
    ) {
        self.isLoading = isLoading
        self.stations = stations
        self.onSelect = onSelect
    }

    var body: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if stations.isEmpty {
            Text("검색 결과가 없습니다")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(stations) { station in
                        // TODO: 추후 listRow 컴포넌트 추가 예정 - 디자인 명세 필요
                        StationRow(station: station) { onSelect(station) }
                        Divider()
                    }
                }
                .padding(.top, 16)
                .padding(.horizontal, Spacing.spacing450)
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

// MARK: - Preview

#Preview("기본 (빈 상태)") {
    BangawoPreview {
        StationSearchSheet(
            store: Store(initialState: StationSearchSheetFeature.State()) {
                StationSearchSheetFeature()
            }
        )
    }
}

#Preview("검색 결과 있음") {
    BangawoPreview {
        StationSearchSheet(
            store: Store(
                initialState: StationSearchSheetFeature.State(
                    keyword: "강남",
                    stations: [
                        Station(
                            id: "1",
                            name: "강남역",
                            addressName: "서울 강남구 역삼동",
                            roadAddressName: "서울 강남구 강남대로 396",
                            x: 127.0276368,
                            y: 37.4979502
                        ),
                        Station(
                            id: "2",
                            name: "강남구청역",
                            addressName: "서울 강남구 삼성동",
                            roadAddressName: "서울 강남구 봉은사로 425",
                            x: 127.0448716,
                            y: 37.5172485
                        ),
                        Station(
                            id: "3",
                            name: "강남터미널",
                            addressName: "서울 서초구 반포동",
                            roadAddressName: "서울 서초구 신반포로 194",
                            x: 127.0047041,
                            y: 37.5049791
                        )
                    ]
                )
            ) {
                StationSearchSheetFeature()
            }
        )
    }
}

#Preview("로딩 중") {
    BangawoPreview {
        StationSearchSheet(
            store: Store(
                initialState: StationSearchSheetFeature.State(
                    keyword: "강남",
                    isLoading: true
                )
            ) {
                StationSearchSheetFeature()
            }
        )
    }
}

// MARK: - StationRow

struct StationRow: View {
    private let station: Station
    private let action: () -> Void

    init(station: Station, action: @escaping () -> Void) {
        self.station = station
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.body.bold())
                    .foregroundStyle(.black)
                Text(fullAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var fullAddress: String {
        station.roadAddressName.isEmpty
            ? station.addressName : station.roadAddressName
    }
}
