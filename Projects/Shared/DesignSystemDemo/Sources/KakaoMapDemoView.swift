import SwiftUI
import DesignSystem

struct KakaoMapDemoView: View {
    @State private var tappedPin: MapPin?

    private let seoulCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    private let samplePins: [MapPin] = [
        MapPin(
            coordinate: MapCoordinate(latitude: 37.5665, longitude: 126.9780),
            title: "서울시청"
        ),
        MapPin(
            coordinate: MapCoordinate(latitude: 37.5512, longitude: 126.9882),
            title: "남산타워"
        ),
        MapPin(
            coordinate: MapCoordinate(latitude: 37.5796, longitude: 126.9770),
            title: "경복궁"
        ),
    ]

    private let sampleRoute: [MapRoute] = [
        MapRoute(
            coordinates: [
                MapCoordinate(latitude: 37.5796, longitude: 126.9770),
                MapCoordinate(latitude: 37.5735, longitude: 126.9790),
                MapCoordinate(latitude: 37.5665, longitude: 126.9780),
                MapCoordinate(latitude: 37.5512, longitude: 126.9882),
            ],
            lineColor: .systemBlue,
            lineWidth: 5
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            KakaoMap(
                routes: sampleRoute,
                pins: samplePins,
                initialCenter: seoulCenter,
                initialZoomLevel: 14
            )
            .onPinTapped { pin in
                tappedPin = pin
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(16)

            coordinateInfoSection
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .navigationTitle("KakaoMap")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var coordinateInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("좌표 정보")
                .font(.headline)

            if let pin = tappedPin {
                HStack {
                    Text(pin.title)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(pin.coordinate.latitude, specifier: "%.4f"), \(pin.coordinate.longitude, specifier: "%.4f")")
                        .foregroundStyle(.secondary)
                        .font(.footnote.monospaced())
                }
            } else {
                Text("핀을 탭하면 좌표가 표시됩니다")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            Text("중심: \(seoulCenter.latitude, specifier: "%.4f"), \(seoulCenter.longitude, specifier: "%.4f")")
                .foregroundStyle(.tertiary)
                .font(.caption.monospaced())
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
