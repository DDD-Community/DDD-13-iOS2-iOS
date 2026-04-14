import SwiftUI

public struct KakaoMap: View {
    private let routes: [MapRoute]
    private let pins: [MapPin]
    private let initialCenter: MapCoordinate
    private let initialZoomLevel: Int
    private var onPinTapped: ((MapPin) -> Void)?
    
    @State private var isVisible: Bool = false

    public init(
        routes: [MapRoute] = [],
        pins: [MapPin] = [],
        initialCenter: MapCoordinate,
        initialZoomLevel: Int = 15
    ) {
        self.routes = routes
        self.pins = pins
        self.initialCenter = initialCenter
        self.initialZoomLevel = initialZoomLevel
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
