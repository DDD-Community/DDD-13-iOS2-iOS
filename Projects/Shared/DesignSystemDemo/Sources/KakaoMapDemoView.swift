import SwiftUI

import DesignSystem

struct KakaoMapDemoView: View {
    @State private var selectedPlaceID: String?
    @State private var focusedCoordinate: MapCoordinate?
    @State private var pins: [MapPin] = []
    @State private var memberPins: [MapPin] = []
    @State private var memberRoutes: [MapRoute] = []

    private let seoulCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    private let samplePlaces: [SamplePlace] = [
        SamplePlace(name: "감성카페", coordinate: MapCoordinate(latitude: 37.5665, longitude: 126.9780), iconAsset: "ic_map_pin_cafe"),
        SamplePlace(name: "남산다이닝", coordinate: MapCoordinate(latitude: 37.5512, longitude: 126.9882), iconAsset: "ic_map_pin_restaurant"),
        SamplePlace(name: "경복궁디저트", coordinate: MapCoordinate(latitude: 37.5796, longitude: 126.9770), iconAsset: "ic_map_pin_dessert"),
        SamplePlace(name: "명동포차", coordinate: MapCoordinate(latitude: 37.5637, longitude: 126.9850), iconAsset: "ic_map_pin_bar"),
        SamplePlace(name: "광화문식당", coordinate: MapCoordinate(latitude: 37.5759, longitude: 126.9769), iconAsset: "ic_map_pin_food"),
    ]

    // 그룹 멤버 4명. 각자 출발지에서 선택한 목적지까지 색이 구분된 경로를 그린다.
    private let members: [Member] = [
        Member(id: "member_1", name: "지은", location: MapCoordinate(latitude: 37.5443, longitude: 126.9520), color: .blue),
        Member(id: "member_2", name: "현우", location: MapCoordinate(latitude: 37.5980, longitude: 127.0010), color: .red),
        Member(id: "member_3", name: "수민", location: MapCoordinate(latitude: 37.5320, longitude: 127.0250), color: .green),
        Member(id: "member_4", name: "도현", location: MapCoordinate(latitude: 37.5870, longitude: 126.9400), color: .orange),
    ]

    var body: some View {
        VStack(spacing: 0) {
            KakaoMap(
                routes: memberRoutes,
                pins: pins + memberPins,
                initialCenter: seoulCenter,
                initialZoomLevel: 10,
                focusedCoordinate: focusedCoordinate
            )
            .onPinTapped { pin in
                // 샘플 장소(MapPinLabel) 핀을 탭하면 해당 핀을 중심으로 포커스를 이동한다.
                // 멤버 핀(MemberRoutePinLabel) 탭은 포커스 이동 대상이 아니다.
                guard let place = samplePlaces.first(where: { $0.id == pin.id }) else { return }

                selectedPlaceID = place.id
                focusedCoordinate = place.coordinate
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(height: 300)
            .padding(.horizontal, 16)
            .padding(.top, 16)

            placeList
        }
        .navigationTitle("KakaoMap")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            buildPins()
        }
    }

    private var placeList: some View {
        List(samplePlaces) { place in
            Button {
                select(place)
            } label: {
                HStack(spacing: 12) {
                    Image(assetName: place.iconAsset)
                        .resizable()
                        .frame(width: Metric.iconLength, height: Metric.iconLength)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Colors.gray00, lineWidth: Metric.iconBorderWidth)
                        )
                        .shadow(
                            color: Constant.iconShadowColor,
                            radius: Metric.iconShadowRadius,
                            x: 0,
                            y: Metric.iconShadowOffsetY
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(place.name)
                            .foregroundStyle(.primary)
                        Text(place.coordinateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if selectedPlaceID == place.id {
                        Image(systemName: "scope")
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .listRowBackground(
                selectedPlaceID == place.id
                    ? Color(.secondarySystemBackground)
                    : Color(.systemBackground)
            )
        }
        .listStyle(.plain)
    }

    // MARK: - 장소 선택

    // 목적지(샘플 장소) 선택 시 4명 멤버가 각자 출발지에서 목적지까지 가는
    // 임의의 점선 경로와, 출발지에 표시할 멤버 핀(환승·소요시간)을 함께 갱신한다.
    @MainActor
    private func select(_ place: SamplePlace) {
        selectedPlaceID = place.id
        focusedCoordinate = place.coordinate

        memberRoutes = members.map { member in
            MapRoute(
                id: member.id,
                coordinates: makeArbitraryPath(from: member.location, to: place.coordinate),
                dotStyle: RouteDotStyle(color: member.color, spacing: 2)
            )
        }

        memberPins = members.map { member in
            MemberRoutePinLabel(
                avatarType: .d3,
                routeColor: member.color,
                transferCount: Int.random(in: 0...4),
                durationMinutes: Int.random(in: 20...90)
            )
            .makePin(id: member.id, coordinate: member.location)
        }
    }

    // 출발지 → 목적지 사이에 중간 waypoint 를 직선 보간 + 수직 방향 랜덤 오프셋으로 끼워
    // "임의의 경로"처럼 보이는 좌표 배열을 만든다(실제 길찾기 API 미사용).
    private func makeArbitraryPath(from start: MapCoordinate, to end: MapCoordinate) -> [MapCoordinate] {
        let segments = 4
        let deltaLatitude = end.latitude - start.latitude
        let deltaLongitude = end.longitude - start.longitude

        var path: [MapCoordinate] = [start]
        for index in 1 ..< segments {
            let ratio = Double(index) / Double(segments)
            let baseLatitude = start.latitude + deltaLatitude * ratio
            let baseLongitude = start.longitude + deltaLongitude * ratio

            // 진행 방향에 수직인 성분으로 흔들어 곡선처럼 보이게 한다.
            let offset = Double.random(in: -0.25 ... 0.25)
            path.append(
                MapCoordinate(
                    latitude: baseLatitude - deltaLongitude * offset,
                    longitude: baseLongitude + deltaLatitude * offset
                )
            )
        }
        path.append(end)
        return path
    }

    // MARK: - Pin 구성

    @MainActor
    private func buildPins() {
        pins = samplePlaces.map { place in
            MapPinLabel(assetName: place.iconAsset, title: place.name)
                .makePin(id: place.name, coordinate: place.coordinate)
        }
    }
}

// MARK: - SamplePlace

private struct SamplePlace: Identifiable {
    let name: String
    let coordinate: MapCoordinate
    let iconAsset: String

    var id: String { name }

    var coordinateText: String {
        String(format: "%.4f, %.4f", coordinate.latitude, coordinate.longitude)
    }
}

// MARK: - Member

private struct Member: Identifiable {
    let id: String
    let name: String
    let location: MapCoordinate
    let color: RouteDotColor
}

// MARK: - Constants

private enum Metric {
    static let iconLength: CGFloat = 24
    static let iconBorderWidth: CGFloat = 1.2
    static let iconShadowRadius: CGFloat = 14.4
    static let iconShadowOffsetY: CGFloat = 4.8
}

private enum Constant {
    static let iconShadowColor = Color(
        red: 43 / 255,
        green: 43 / 255,
        blue: 43 / 255,
        opacity: 31 / 255
    )
}
