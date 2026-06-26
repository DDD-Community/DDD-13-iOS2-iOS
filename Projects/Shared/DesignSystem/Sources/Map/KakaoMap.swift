import Foundation
import SwiftUI

public struct KakaoMap: View {
    private let routes: [MapRoute]
    private let pins: [MapPin]
    private let initialCenter: MapCoordinate
    private let initialZoomLevel: Int
    private let fitsToPins: Bool
    private let focusedCoordinate: MapCoordinate?
    private let focusBottomInset: CGFloat
    private var onPinTapped: ((MapPin) -> Void)?
    private var onCenterChanged: ((MapViewport) -> Void)?

    /// 화면 이탈/재진입 시 엔진을 토글하기 위한 상태값.
    /// onAppear(true) → activateEngine, onDisappear(false) → resetEngine
    @State private var isVisible: Bool = false

    public init(
        routes: [MapRoute] = [],
        pins: [MapPin] = [],
        initialCenter: MapCoordinate,
        initialZoomLevel: Int = 15,
        fitsToPins: Bool = false,
        focusedCoordinate: MapCoordinate? = nil,
        focusBottomInset: CGFloat = 0
    ) {
        self.routes = routes
        self.pins = pins
        self.initialCenter = initialCenter
        self.initialZoomLevel = initialZoomLevel
        self.fitsToPins = fitsToPins
        self.focusedCoordinate = focusedCoordinate
        self.focusBottomInset = focusBottomInset
    }

    public func onPinTapped(_ handler: @escaping (MapPin) -> Void) -> KakaoMap {
        var copy = self
        copy.onPinTapped = handler
        return copy
    }

    /// 사용자가 드래그로 지도를 이동한 뒤 카메라 움직임이 멈췄을 때
    /// 변경된 중심 좌표와 현재 줌 레벨을 `MapViewport`로 전달한다.
    public func onCenterChanged(_ handler: @escaping (MapViewport) -> Void) -> KakaoMap {
        var copy = self
        copy.onCenterChanged = handler
        return copy
    }

    public var body: some View {
        #if DEBUG
        if Self.isRunningForPreviews {
            KakaoMapPreviewPlaceholder(
                pins: pins,
                initialCenter: initialCenter,
                onPinTapped: onPinTapped
            )
        } else {
            liveMap
        }
        #else
        liveMap
        #endif
    }

    private var liveMap: some View {
        KakaoMapRepresentable(
            isVisible: $isVisible,
            routes: routes,
            pins: pins,
            initialCenter: initialCenter,
            initialZoomLevel: initialZoomLevel,
            fitsToPins: fitsToPins,
            focusedCoordinate: focusedCoordinate,
            focusBottomInset: focusBottomInset,
            onPinTapped: onPinTapped,
            onCenterChanged: onCenterChanged
        )
        .onAppear {
            self.isVisible = true
        }
        .onDisappear {
            self.isVisible = false
        }
    }

    #if DEBUG
    private static var isRunningForPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    #endif
}

// MARK: - Preview Placeholder

#if DEBUG
private struct KakaoMapPreviewPlaceholder: View {
    let pins: [MapPin]
    let initialCenter: MapCoordinate
    var onPinTapped: ((MapPin) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.gray.opacity(Metric.mapBackgroundOpacity)

                previewGrid

                ForEach(pins) { pin in
                    previewPin(pin)
                        .position(position(for: pin.coordinate, in: geometry.size))
                        .onTapGesture {
                            onPinTapped?(pin)
                        }
                }

                VStack(spacing: Metric.captionSpacing) {
                    Text("KakaoMap Preview")
                        .font(.caption.weight(.semibold))

                    Text("실제 지도는 앱 실행에서 렌더링됩니다")
                        .font(.caption2)
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, Metric.captionHorizontalPadding)
                .padding(.vertical, Metric.captionVerticalPadding)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: Metric.captionCornerRadius))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, Metric.captionTopPadding)
            }
        }
    }

    private var previewGrid: some View {
        ZStack {
            ForEach(0..<Metric.gridLineCount, id: \.self) { index in
                Rectangle()
                    .fill(Color.white.opacity(Metric.gridLineOpacity))
                    .frame(height: Metric.gridLineWidth)
                    .offset(y: CGFloat(index - Metric.gridCenterIndex) * Metric.gridSpacing)

                Rectangle()
                    .fill(Color.white.opacity(Metric.gridLineOpacity))
                    .frame(width: Metric.gridLineWidth)
                    .offset(x: CGFloat(index - Metric.gridCenterIndex) * Metric.gridSpacing)
            }
        }
    }

    private func previewPin(_ pin: MapPin) -> some View {
        VStack(spacing: Metric.pinTitleSpacing) {
            Circle()
                .fill(Color.red)
                .frame(width: Metric.pinSize, height: Metric.pinSize)
                .overlay {
                    Circle()
                        .fill(Color.white)
                        .frame(width: Metric.pinInnerSize, height: Metric.pinInnerSize)
                }
                .shadow(radius: Metric.pinShadowRadius, y: Metric.pinShadowYOffset)

            if !pin.title.isEmpty {
                Text(pin.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .padding(.horizontal, Metric.pinTitleHorizontalPadding)
                    .padding(.vertical, Metric.pinTitleVerticalPadding)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: Metric.pinTitleCornerRadius))
            }
        }
    }

    private func position(for coordinate: MapCoordinate, in size: CGSize) -> CGPoint {
        let xOffset = (coordinate.longitude - initialCenter.longitude) * Metric.coordinateScale
        let yOffset = (initialCenter.latitude - coordinate.latitude) * Metric.coordinateScale

        return CGPoint(
            x: size.width / 2 + xOffset,
            y: size.height / 2 + yOffset
        )
    }
}

private enum Metric {
    static let mapBackgroundOpacity = 0.18

    static let captionSpacing: CGFloat = 2
    static let captionHorizontalPadding: CGFloat = 10
    static let captionVerticalPadding: CGFloat = 6
    static let captionCornerRadius: CGFloat = 8
    static let captionTopPadding: CGFloat = 12

    static let gridLineCount = 9
    static let gridCenterIndex = 4
    static let gridSpacing: CGFloat = 44
    static let gridLineWidth: CGFloat = 1
    static let gridLineOpacity = 0.55

    static let pinSize: CGFloat = 18
    static let pinInnerSize: CGFloat = 7
    static let pinShadowRadius: CGFloat = 3
    static let pinShadowYOffset: CGFloat = 2
    static let pinTitleSpacing: CGFloat = 4
    static let pinTitleHorizontalPadding: CGFloat = 6
    static let pinTitleVerticalPadding: CGFloat = 3
    static let pinTitleCornerRadius: CGFloat = 6

    static let coordinateScale: Double = 5_500
}
#endif

#Preview {
    let seoulCenter = MapCoordinate(latitude: 37.5665, longitude: 126.9780)

    KakaoMap(
        routes: [
            MapRoute(
                coordinates: [
                    MapCoordinate(latitude: 37.5665, longitude: 126.9780),
                    MapCoordinate(latitude: 37.5637, longitude: 126.9850),
                    MapCoordinate(latitude: 37.5512, longitude: 126.9882),
                ],
                dotStyle: RouteDotStyle(color: .blue, spacing: 2)
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
