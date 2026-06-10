import SwiftUI

import DesignSystem

struct KakaoMapDemoView: View {
    @State private var selectedPlaceID: String?
    @State private var focusedCoordinate: MapCoordinate?
    @State private var pins: [MapPin] = []

    private let seoulCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    private let samplePlaces: [SamplePlace] = [
        SamplePlace(name: "감성카페", coordinate: MapCoordinate(latitude: 37.5665, longitude: 126.9780), iconAsset: "ic_map_pin_cafe"),
        SamplePlace(name: "남산다이닝", coordinate: MapCoordinate(latitude: 37.5512, longitude: 126.9882), iconAsset: "ic_map_pin_restaurant"),
        SamplePlace(name: "경복궁디저트", coordinate: MapCoordinate(latitude: 37.5796, longitude: 126.9770), iconAsset: "ic_map_pin_dessert"),
        SamplePlace(name: "명동포차", coordinate: MapCoordinate(latitude: 37.5637, longitude: 126.9850), iconAsset: "ic_map_pin_bar"),
        SamplePlace(name: "광화문식당", coordinate: MapCoordinate(latitude: 37.5759, longitude: 126.9769), iconAsset: "ic_map_pin_food"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            KakaoMap(
                pins: pins,
                initialCenter: seoulCenter,
                initialZoomLevel: 14,
                focusedCoordinate: focusedCoordinate
            )
            .onPinTapped { pin in
                selectedPlaceID = pin.id
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

    private func select(_ place: SamplePlace) {
        selectedPlaceID = place.id
        focusedCoordinate = place.coordinate
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
