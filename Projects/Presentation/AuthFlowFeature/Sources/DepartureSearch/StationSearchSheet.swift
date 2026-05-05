//
//  StationSearchSheet.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture
import Entity

struct StationSearchSheet: View {
    @Bindable var store: StoreOf<StationSearchSheetFeature>

    var body: some View {
        VStack(spacing: 16) {
            SearchSheetHeader {
                store.send(.closeButtonTapped)
            }

            SearchKeywordField(keyword: $store.keyword)

            StationResultList(
                isLoading: store.isLoading,
                stations: store.stations,
                onSelect: { station in store.send(.stationTapped(station)) }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct SearchSheetHeader: View {
    private let onClose: () -> Void

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    var body: some View {
        HStack {
            Color.clear.frame(maxWidth: .infinity)
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct SearchKeywordField: View {
    @Binding private var keyword: String

    init(keyword: Binding<String>) {
        self._keyword = keyword
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color(.systemGray2))
            TextField("지역, 지하철역 명으로 찾기", text: $keyword)
                .textFieldStyle(.plain)
                .submitLabel(.search)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
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
                        StationRow(station: station) { onSelect(station) }
                        Divider()
                    }
                }
            }
        }
    }
}

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
                Text(districtLevelAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    private var districtLevelAddress: String {
        let source = station.roadAddressName.isEmpty
            ? station.addressName : station.roadAddressName
        return Self.truncateToDistrict(source)
    }

    private static let administrativeSuffixes: Set<Character> = ["시", "도", "군", "구"]

    private static func truncateToDistrict(_ address: String) -> String {
        let tokens = address.split(separator: " ")
        let prefix = tokens.prefix { token in
            guard let last = token.last else { return false }
            return administrativeSuffixes.contains(last)
        }

        return prefix.isEmpty
            ? address
            : prefix.joined(separator: " ")
    }
}
