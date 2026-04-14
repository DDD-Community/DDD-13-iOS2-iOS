@preconcurrency import KakaoMapsSDK
import SwiftUI

struct KakaoMapRepresentable: UIViewRepresentable {
    @Binding var isVisible: Bool
    let routes: [MapRoute]
    let pins: [MapPin]
    let initialCenter: MapCoordinate
    let initialZoomLevel: Int
    var onPinTapped: ((MapPin) -> Void)?

    func makeUIView(context: Context) -> KMViewContainer {
        let container = KMViewContainer()
        context.coordinator.container = container
        context.coordinator.createController(container: container)
        return container
    }

    func updateUIView(_ uiView: KMViewContainer, context: Context) {
        let coordinator = context.coordinator
        coordinator.pendingRoutes = routes
        coordinator.pendingPins = pins
        coordinator.onPinTapped = onPinTapped

        if isVisible {
            // KakaoMapSDK는 KMViewContainer의 bounds 기반으로 렌더 서피스를 생성한다.
            // onAppear 시점에도 Auto Layout + CALayer 커밋이 완료되지 않을 수 있어
            // 0.5초 지연 후 SDK 자체 상태를 확인하여 엔진을 초기화한다.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if coordinator.controller?.isEnginePrepared == false {
                    coordinator.controller?.prepareEngine()
                }

                if coordinator.controller?.isEngineActive == false {
                    coordinator.controller?.activateEngine()
                }
            }

            if coordinator.isMapReady {
                coordinator.applyOverlays()
            }
        } else {
            coordinator.controller?.pauseEngine()
            coordinator.controller?.resetEngine()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            routes: routes,
            pins: pins,
            initialCenter: initialCenter,
            initialZoomLevel: initialZoomLevel,
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
        var onPinTapped: ((MapPin) -> Void)?

        private let initialCenter: MapCoordinate
        private let initialZoomLevel: Int

        private var currentRoutes: [MapRoute] = []
        private var currentPins: [MapPin] = []
        private var pinMap: [String: MapPin] = [:]

        init(
            routes: [MapRoute],
            pins: [MapPin],
            initialCenter: MapCoordinate,
            initialZoomLevel: Int,
            onPinTapped: ((MapPin) -> Void)?
        ) {
            self.pendingRoutes = routes
            self.pendingPins = pins
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
            print("[KakaoMap] addViews called - container frame: \(container?.frame ?? .zero)")
            let defaultPosition = MapPoint(
                longitude: initialCenter.longitude,
                latitude: initialCenter.latitude
            )
            let mapviewInfo = MapviewInfo(
                viewName: "bangawo_map",
                appName: "openmap",
                viewInfoName: "map",
                defaultPosition: defaultPosition,
                defaultLevel: initialZoomLevel,
                enabled: true
            )
            controller?.addView(mapviewInfo)
        }

        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            print("[KakaoMap] addViewSucceeded - viewName: \(viewName), container frame: \(container?.frame ?? .zero)")
            guard let mapView = controller?.getView(viewName) as? KakaoMapsSDK.KakaoMap else {
                print("[KakaoMap] getView failed - could not cast to KakaoMap")
                return
            }
            mapView.eventDelegate = self
            isMapReady = true
            controller?.activateEngine()
            applyOverlays()
        }

        func addViewFailed(_ viewName: String, viewInfoName: String) {
            print("[KakaoMap] addView failed - viewName: \(viewName), viewInfoName: \(viewInfoName)")
            isMapReady = false
        }

        func authenticationSucceeded() {
            print("[KakaoMap] Authentication succeeded")
        }

        func authenticationFailed(_ errorCode: Int, desc: String) {
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
                  let mapView = controller?.getView("bangawo_map") as? KakaoMapsSDK.KakaoMap
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

        private func applyRoutes(_ routes: [MapRoute], on mapView: KakaoMapsSDK.KakaoMap) {
            let shapeManager = mapView.getShapeManager()
            shapeManager.removeShapeLayer(layerID: "bangawo_polyline_layer")

            guard !routes.isEmpty else { return }

            let styleSetID = "bangawo_polyline_styles"

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
                layerID: "bangawo_polyline_layer",
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
                shapeID: "bangawo_polylines",
                styleID: styleSetID,
                zOrder: 0
            )
            shapeOptions.polylines = polylines

            if let shape = layer.addMapPolylineShape(shapeOptions, callback: nil) {
                shape.show()
            }
        }

        private func applyPins(_ pins: [MapPin], on mapView: KakaoMapsSDK.KakaoMap) {
            let labelManager = mapView.getLabelManager()
            labelManager.removeLabelLayer(layerID: "bangawo_pin_layer")
            pinMap.removeAll()

            guard !pins.isEmpty else { return }

            for (index, pin) in pins.enumerated() {
                let styleID = "bangawo_pin_style_\(index)"
                let iconStyle: PoiIconStyle
                if let image = pin.iconImage {
                    iconStyle = PoiIconStyle(symbol: image, anchorPoint: CGPoint(x: 0.5, y: 1.0))
                } else {
                    iconStyle = PoiIconStyle(symbol: defaultPinImage(), anchorPoint: CGPoint(x: 0.5, y: 1.0))
                }
                let perLevel = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
                let poiStyle = PoiStyle(styleID: styleID, styles: [perLevel])
                labelManager.addPoiStyle(poiStyle)
            }

            let layerOptions = LabelLayerOptions(
                layerID: "bangawo_pin_layer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 10001
            )
            guard let layer = labelManager.addLabelLayer(option: layerOptions) else { return }
            layer.setClickable(true)

            for (index, pin) in pins.enumerated() {
                let styleID = "bangawo_pin_style_\(index)"
                let options = PoiOptions(styleID: styleID, poiID: pin.id)
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
