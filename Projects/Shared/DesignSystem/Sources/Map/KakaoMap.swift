import SwiftUI

public struct KakaoMap: View {
    private let routes: [MapRoute]
    private let pins: [MapPin]
    private let initialCenter: MapCoordinate
    private let initialZoomLevel: Int
    private let focusedCoordinate: MapCoordinate?
    private var onPinTapped: ((MapPin) -> Void)?

    /// 화면 이탈/재진입 시 엔진을 토글하기 위한 상태값.
    /// onAppear(true) → activateEngine, onDisappear(false) → resetEngine
    @State private var isVisible: Bool = false

    public init(
        routes: [MapRoute] = [],
        pins: [MapPin] = [],
        initialCenter: MapCoordinate,
        initialZoomLevel: Int = 15,
        focusedCoordinate: MapCoordinate? = nil
    ) {
        self.routes = routes
        self.pins = pins
        self.initialCenter = initialCenter
        self.initialZoomLevel = initialZoomLevel
        self.focusedCoordinate = focusedCoordinate
    }

    public func onPinTapped(_ handler: @escaping (MapPin) -> Void) -> KakaoMap {
        var copy = self
        copy.onPinTapped = handler
        return copy
    }

    public var body: some View {
        KakaoMapRepresentable(
            isVisible: $isVisible,
            routes: routes,
            pins: pins,
            initialCenter: initialCenter,
            initialZoomLevel: initialZoomLevel,
            focusedCoordinate: focusedCoordinate,
            onPinTapped: onPinTapped
        )
        .onAppear {
            self.isVisible = true
        }
        .onDisappear {
            self.isVisible = false
        }
    }
}

#Preview {
    let seoulCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    KakaoMap(
        routes: [
            MapRoute(
                coordinates: [
                    MapCoordinate(latitude: 37.5665, longitude: 126.9780),
                    MapCoordinate(latitude: 37.5637, longitude: 126.9850),
                    MapCoordinate(latitude: 37.5512, longitude: 126.9882),
                ]
            )
        ],
        pins: [
            MapPin(
                coordinate: MapCoordinate(latitude: 37.5665, longitude: 126.9780),
                title: "출발지"
            ),
            MapPin(
                coordinate: MapCoordinate(latitude: 37.5512, longitude: 126.9882),
                title: "도착지"
            ),
        ],
        initialCenter: seoulCenter,
        initialZoomLevel: 14
    )
    .onPinTapped { pin in
        print("[Preview] pin tapped: \(pin.title)")
    }
    .ignoresSafeArea()
}
