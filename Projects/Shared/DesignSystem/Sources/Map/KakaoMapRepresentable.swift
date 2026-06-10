@preconcurrency import KakaoMapsSDK
import SwiftUI

struct KakaoMapRepresentable: UIViewRepresentable {
    /// 화면 이탈/재진입 시 엔진을 토글하기 위한 상태값.
    /// onAppear(true) → activateEngine, onDisappear(false) → resetEngine
    @Binding var isVisible: Bool
    let routes: [MapRoute]
    let pins: [MapPin]
    let initialCenter: MapCoordinate
    let initialZoomLevel: Int
    let focusedCoordinate: MapCoordinate?
    var onPinTapped: ((MapPin) -> Void)?

    func makeUIView(context: Context) -> KMViewContainer {
        let container = KMViewContainer()
        context.coordinator.container = container
        context.coordinator.createController(container: container)

        DispatchQueue.main.async {
            context.coordinator.controller?.prepareEngine()
        }

        return container
    }

    // SDK 엔진 라이프사이클: prepareEngine → 인증 → activateEngine → addViews → 맵 렌더링
    // prepareEngine은 makeUIView에서 1회 호출하고,
    // activateEngine은 authenticationSucceeded 델리게이트에서 호출한다.
    // updateUIView는 화면 재진입(isVisible 토글) 시 엔진을 활성화/비활성화하는 역할만 담당한다.
    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        let coordinator = context.coordinator
        coordinator.pendingRoutes = routes
        coordinator.pendingPins = pins
        coordinator.pendingFocus = focusedCoordinate
        coordinator.onPinTapped = onPinTapped

        if isVisible {
            coordinator.controller?.activateEngine()

            if coordinator.isMapReady {
                coordinator.applyOverlays()
                coordinator.applyFocus()
            }
        } else {
            coordinator.controller?.resetEngine()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            routes: routes,
            pins: pins,
            initialCenter: initialCenter,
            initialZoomLevel: initialZoomLevel,
            focusedCoordinate: focusedCoordinate,
            onPinTapped: onPinTapped
        )
    }

    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: Coordinator) {
        coordinator.controller?.pauseEngine()
        coordinator.controller?.resetEngine()
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, MapControllerDelegate, KakaoMapEventDelegate {
        weak var container: KMViewContainer?
        var controller: KMController?
        var isMapReady = false
        var isEnginePrepared = false

        var pendingRoutes: [MapRoute]
        var pendingPins: [MapPin]
        var pendingFocus: MapCoordinate?
        var onPinTapped: ((MapPin) -> Void)?

        private let initialCenter: MapCoordinate
        private let initialZoomLevel: Int

        private var currentRoutes: [MapRoute] = []
        private var currentPins: [MapPin] = []
        private var currentFocus: MapCoordinate?
        private var pinMap: [String: MapPin] = [:]

        init(
            routes: [MapRoute],
            pins: [MapPin],
            initialCenter: MapCoordinate,
            initialZoomLevel: Int,
            focusedCoordinate: MapCoordinate?,
            onPinTapped: ((MapPin) -> Void)?
        ) {
            self.pendingRoutes = routes
            self.pendingPins = pins
            self.pendingFocus = focusedCoordinate
            self.initialCenter = initialCenter
            self.initialZoomLevel = initialZoomLevel
            self.onPinTapped = onPinTapped
        }

        func createController(container: KMViewContainer) {
            controller = KMController(viewContainer: container)
            controller?.delegate = self
        }

        // MARK: - MapControllerDelegate

        func addViews() {
            let defaultPosition = MapPoint(
                longitude: initialCenter.longitude,
                latitude: initialCenter.latitude
            )
            let mapviewInfo = MapviewInfo(
                viewName: MapIdentifier.viewName,
                appName: MapIdentifier.appName,
                viewInfoName: MapIdentifier.viewInfoName,
                defaultPosition: defaultPosition,
                defaultLevel: initialZoomLevel,
                enabled: true
            )
            controller?.addView(mapviewInfo)
        }

        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            guard let mapView = controller?.getView(viewName) as? KakaoMapsSDK.KakaoMap else {
                // TODO: Logger로 대체
                print("[KakaoMap] getView failed - could not cast to KakaoMap")
                return
            }
            mapView.eventDelegate = self
            isMapReady = true
            applyOverlays()
            applyFocus()
        }

        func addViewFailed(_ viewName: String, viewInfoName: String) {
            // TODO: Logger로 대체
            print("[KakaoMap] addView failed - viewName: \(viewName), viewInfoName: \(viewInfoName)")
            isMapReady = false
        }

        // 인증 성공 후 엔진을 활성화한다.
        // SDK 라이프사이클상 activateEngine()의 최초 호출 지점이다.
        // 이후 addViews → addViewSucceeded 순서로 맵 렌더링이 진행된다.
        func authenticationSucceeded() {
            if controller?.isEngineActive == false {
                controller?.activateEngine()
            }
        }

        func authenticationFailed(_ errorCode: Int, desc: String) {
            // TODO: Logger로 대체
            print("[KakaoMap] Authentication failed - code: \(errorCode), desc: \(desc)")
        }

        // MARK: - KakaoMapEventDelegate

        func poiDidTapped(kakaoMap: KakaoMapsSDK.KakaoMap, layerID: String, poiID: String, position: MapPoint) {
            guard let pin = pinMap[poiID] else { return }
            onPinTapped?(pin)
        }

        // MARK: - Overlay Management

        func applyOverlays() {
            guard isMapReady,
                  let mapView = controller?.getView(MapIdentifier.viewName) as? KakaoMapsSDK.KakaoMap
            else { return }

            if pendingRoutes != currentRoutes {
                applyRoutes(pendingRoutes, on: mapView)
                currentRoutes = pendingRoutes
            }

            if pendingPins != currentPins {
                applyPins(pendingPins, on: mapView)
                currentPins = pendingPins
            }
        }

        // 포커스 좌표가 갱신되면 해당 위치로 카메라를 애니메이션 이동한다.
        // 현재 줌 레벨을 유지하기 위해 target만 지정하는 CameraUpdate를 사용한다.
        func applyFocus() {
            guard
                isMapReady,
                let focus = pendingFocus,
                focus != currentFocus,
                let mapView = controller?.getView(MapIdentifier.viewName) as? KakaoMapsSDK.KakaoMap
            else { return }

            let target = MapPoint(longitude: focus.longitude, latitude: focus.latitude)
            let cameraUpdate = CameraUpdate.make(target: target, mapView: mapView)
            mapView.animateCamera(
                cameraUpdate: cameraUpdate,
                options: CameraAnimationOptions(autoElevation: false, consecutive: false, durationInMillis: 300)
            )
            currentFocus = focus
        }

        private func applyRoutes(_ routes: [MapRoute], on mapView: KakaoMapsSDK.KakaoMap) {
            let shapeManager = mapView.getShapeManager()
            shapeManager.removeShapeLayer(layerID: MapIdentifier.polylineLayer)

            guard !routes.isEmpty else { return }

            let styleSetID = MapIdentifier.polylineStyleSet

            var polylineStyles: [PolylineStyle] = []
            for route in routes {
                let perLevel = PerLevelPolylineStyle(
                    bodyColor: route.lineColor,
                    bodyWidth: route.lineWidth,
                    strokeColor: route.strokeColor,
                    strokeWidth: route.strokeWidth,
                    level: 0
                )
                polylineStyles.append(PolylineStyle(styles: [perLevel]))
            }

            let styleSet = PolylineStyleSet(styleSetID: styleSetID, styles: polylineStyles, capType: .round)
            shapeManager.addPolylineStyleSet(styleSet)

            guard let layer = shapeManager.addShapeLayer(
                layerID: MapIdentifier.polylineLayer,
                zOrder: 1,
                passType: .route
            ) else { return }

            var polylines: [MapPolyline] = []
            for (index, route) in routes.enumerated() {
                let points = route.coordinates.map {
                    MapPoint(longitude: $0.longitude, latitude: $0.latitude)
                }
                polylines.append(MapPolyline(line: points, styleIndex: UInt(index)))
            }

            let shapeOptions = MapPolylineShapeOptions(
                shapeID: MapIdentifier.polylineShape,
                styleID: styleSetID,
                zOrder: 0
            )
            shapeOptions.polylines = polylines

            if let shape = layer.addMapPolylineShape(shapeOptions, callback: nil) {
                shape.show()
            }
        }

        // 핀 표현은 SwiftUI 뷰를 렌더한 단일 이미지(아이콘+라벨)로 통일한다.
        // 네이티브 PoiText/TextStyle은 사용하지 않고, 스타일 등록(createPoiStyle)과
        // POI 추가(createPois)를 분리한다. (juhee-dev velog createPoiStyle 패턴 참고)
        private func applyPins(_ pins: [MapPin], on mapView: KakaoMapsSDK.KakaoMap) {
            let labelManager = mapView.getLabelManager()
            labelManager.removeLabelLayer(layerID: MapIdentifier.pinLayer)
            pinMap.removeAll()

            guard !pins.isEmpty else { return }

            createPoiStyles(pins, on: labelManager)

            let layerOptions = LabelLayerOptions(
                layerID: MapIdentifier.pinLayer,
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 10001
            )
            guard let layer = labelManager.addLabelLayer(option: layerOptions) else { return }
            layer.setClickable(true)

            createPois(pins, on: layer)
        }

        // 핀마다 SwiftUI 렌더 이미지를 심볼로 갖는 PoiStyle을 등록한다.
        // PoiIconStyle은 심볼 크기 지정 파라미터가 없어 전달된 이미지를 원본 크기로 렌더하므로,
        // 표시 크기는 호출부에서 이미지로 맞춰 전달한다.
        private func createPoiStyles(_ pins: [MapPin], on labelManager: LabelManager) {
            for (index, pin) in pins.enumerated() {
                let symbol = pin.iconImage ?? defaultPinImage()
                let iconStyle = PoiIconStyle(symbol: symbol, anchorPoint: pin.iconAnchor)
                let perLevel = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
                let poiStyle = PoiStyle(styleID: MapIdentifier.pinStyle(index: index), styles: [perLevel])
                labelManager.addPoiStyle(poiStyle)
            }
        }

        // 등록된 스타일을 참조해 좌표마다 POI를 추가하고 탭 매칭용 pinMap을 구성한다.
        private func createPois(_ pins: [MapPin], on layer: LabelLayer) {
            for (index, pin) in pins.enumerated() {
                let options = PoiOptions(styleID: MapIdentifier.pinStyle(index: index), poiID: pin.id)
                options.rank = index
                options.clickable = true

                let position = MapPoint(longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude)
                if let poi = layer.addPoi(option: options, at: position, callback: nil) {
                    poi.show()
                }
                pinMap[pin.id] = pin
            }
        }

        private func defaultPinImage() -> UIImage {
            let size = CGSize(width: 24, height: 36)
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { context in
                let ctx = context.cgContext
                UIColor.systemRed.setFill()
                let circleRect = CGRect(x: 4, y: 4, width: 16, height: 16)
                ctx.fillEllipse(in: circleRect)
                let trianglePath = UIBezierPath()
                trianglePath.move(to: CGPoint(x: 4, y: 16))
                trianglePath.addLine(to: CGPoint(x: 12, y: 36))
                trianglePath.addLine(to: CGPoint(x: 20, y: 16))
                trianglePath.close()
                trianglePath.fill()
                UIColor.white.setFill()
                let innerCircle = CGRect(x: 8, y: 8, width: 8, height: 8)
                ctx.fillEllipse(in: innerCircle)
            }
        }
    }
}

// MARK: - Constants

private enum MapIdentifier {
    static let viewName = "bangawo_map"
    static let appName = "openmap"
    static let viewInfoName = "map"
    static let polylineLayer = "bangawo_polyline_layer"
    static let polylineStyleSet = "bangawo_polyline_styles"
    static let polylineShape = "bangawo_polylines"
    static let pinLayer = "bangawo_pin_layer"

    static func pinStyle(index: Int) -> String {
        "bangawo_pin_style_\(index)"
    }
}
