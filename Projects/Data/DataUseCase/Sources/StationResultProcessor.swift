//
//  StationResultProcessor.swift
//  DataUseCase
//
//  Kakao Local 검색 결과 후처리: 서울 한정 필터, 역명 prefix 필터, anchor 거리 정렬
//

import Entity
import Foundation

enum StationResultProcessor {
    static func process(_ stations: [Station], keyword: String) -> [Station] {
        let normalized = normalizeKeyword(keyword)
        guard !normalized.isEmpty else { return [] }

        let seoulOnly = stations.filter { isInSeoul($0) }
        let prefixFiltered = seoulOnly.filter { matchesStationPrefix($0, prefix: normalized) }
        return sortByAnchor(prefixFiltered, keyword: normalized)
    }

    private static func normalizeKeyword(_ keyword: String) -> String {
        var value = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasSuffix("역"), value.count > 1 {
            value.removeLast()
        }

        return value
    }

    private static func isInSeoul(_ station: Station) -> Bool {
        station.addressName.hasPrefix("서울") || station.roadAddressName.hasPrefix("서울")
    }

    private static func matchesStationPrefix(_ station: Station, prefix: String) -> Bool {
        let stationKey = station.name.split(separator: " ").first.map(String.init) ?? station.name
        return stationKey.hasPrefix(prefix)
    }

    private static func sortByAnchor(_ stations: [Station], keyword: String) -> [Station] {
        let indexed = stations.enumerated().map { (originalIndex: $0.offset, station: $0.element) }

        let p1 = indexed.filter { $0.station.name.contains(keyword) }
        let p2 = indexed.filter { !$0.station.name.contains(keyword) }

        let groups = groupByStationName(p1)
        let p1Sorted = groups.flatMap { $0.items }

        guard let anchor = p1Sorted.first?.station else {
            return p2.map(\.station)
        }

        let p2Sorted = p2
            .map { (item: $0, distance: squaredDistance(anchor, $0.station)) }
            .sorted { lhs, rhs in
                if lhs.distance != rhs.distance { return lhs.distance < rhs.distance }
                return lhs.item.originalIndex < rhs.item.originalIndex
            }
            .map { $0.item.station }

        return p1Sorted.map(\.station) + p2Sorted
    }

    private static func groupByStationName(
        _ items: [(originalIndex: Int, station: Station)]
    ) -> [(groupIndex: Int, items: [(originalIndex: Int, station: Station)])] {
        var orderedKeys: [String] = []
        var dict: [String: [(originalIndex: Int, station: Station)]] = [:]

        for item in items {
            let key = item.station.name.split(separator: " ").first.map(String.init) ?? item.station.name
            if dict[key] == nil { orderedKeys.append(key) }
            dict[key, default: []].append(item)
        }

        return orderedKeys.enumerated().map { offset, key in
            let bucket = (dict[key] ?? []).sorted { $0.originalIndex < $1.originalIndex }
            return (groupIndex: offset, items: bucket)
        }
    }

    private static func squaredDistance(_ lhs: Station, _ rhs: Station) -> Double {
        let dx = lhs.x - rhs.x
        let dy = lhs.y - rhs.y
        return dx * dx + dy * dy
    }
}
