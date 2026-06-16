@preconcurrency import KakaoMapsSDK
import SwiftUI

import Utill

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
    var onCenterChanged: ((MapViewport) -> Void)?

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
        coordinator.onCenterChanged = onCenterChanged

        if isVisible {
            // 컨테이너 크기가 확정되기 전(bounds .zero)에 activateEngine을 호출하면
            // 카카오 엔진의 입력(터치) 영역이 0으로 초기화되어, 이후 컨테이너가 커져도
            // 탭 이벤트가 도달하지 않는다. 유효 크기가 잡힌 뒤에 엔진을 활성화한다.
            guard uiView.bounds.size != .zero else { return }

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
            onPinTapped: onPinTapped,
            onCenterChanged: onCenterChanged
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
        var onCenterChanged: ((MapViewport) -> Void)?

        private let initialCenter: MapCoordinate
        private let initialZoomLevel: Int

        private var currentRoutes: [MapRoute] = []
        private var currentPins: [MapPin] = []
        private var currentFocus: MapCoordinate?
        private var pinMap: [String: MapPin] = [:]

        // LodPoi 탭 핸들러 등록 시 반환되는 DisposableEventHandler.
        // 보관하지 않으면 dispose 되어 탭 이벤트가 끊길 수 있어 방어적으로 retain 한다.
        private var poiTapHandlers: [any DisposableEventHandler] = []

        init(
            routes: [MapRoute],
            pins: [MapPin],
            initialCenter: MapCoordinate,
            initialZoomLevel: Int,
            focusedCoordinate: MapCoordinate?,
            onPinTapped: ((MapPin) -> Void)?,
            onCenterChanged: ((MapViewport) -> Void)?
        ) {
            self.pendingRoutes = routes
            self.pendingPins = pins
            self.pendingFocus = focusedCoordinate
            self.initialCenter = initialCenter
            self.initialZoomLevel = initialZoomLevel
            self.onPinTapped = onPinTapped
            self.onCenterChanged = onCenterChanged
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
                Log.error("getView failed - could not cast to KakaoMap")
                return
            }
            mapView.eventDelegate = self
            // 전역 POI 클릭 게이트를 활성화한다. 비활성 상태면 개별 POI 의
            // clickable 설정과 무관하게 탭 이벤트가 전달되지 않는다.
            mapView.poiClickable = true
            isMapReady = true
            applyOverlays()
            applyFocus()
        }

        func addViewFailed(_ viewName: String, viewInfoName: String) {
            Log.error("addView failed - viewName: \(viewName), viewInfoName: \(viewInfoName)")
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
            Log.error("Authentication failed - code: \(errorCode), desc: \(desc)")
        }

        // MARK: - POI Tap

        // LOD POI 탭은 개별 POI 의 addPoiTappedEventHandler 로만 전달된다.
        // poiItem.itemID 가 생성 시 부여한 poiID(= pin.id)이므로 pinMap 으로 매칭한다.
        private func handlePoiTapped(_ param: PoiInteractionEventParam) {
            guard let pin = pinMap[param.poiItem.itemID] else { return }

            // 멤버 핀(focusesOnTap == false)을 제외한 핀은 탭 시 해당 좌표로 카메라를 포커싱한다.
            if pin.focusesOnTap {
                focusCamera(on: pin.coordinate)
            }

            onPinTapped?(pin)
        }

        // MARK: - KakaoMapEventDelegate

        // 사용자가 드래그(패닝/롱탭 후 드래그)로 지도를 이동한 뒤 카메라가 멈추면
        // 변경된 중심 좌표를 전달한다.
        // animateCamera로 인한 프로그래매틱 이동(applyFocus)은 by 값으로 제외한다.
        func cameraDidStopped(kakaoMap: KakaoMapsSDK.KakaoMap, by: MoveBy) {
            guard by == .pan || by == .longTapAndDrag else { return }

            let viewRect = kakaoMap.viewRect
            let centerPoint = CGPoint(x: viewRect.midX, y: viewRect.midY)
            let center = kakaoMap.getPosition(centerPoint).wgsCoord

            onCenterChanged?(
                MapViewport(
                    center: MapCoordinate(latitude: center.latitude, longitude: center.longitude),
                    zoomLevel: kakaoMap.zoomLevel
                )
            )
        }

        // MARK: - Overlay Management

        func applyOverlays() {
            guard isMapReady,
                  let mapView = controller?.getView(MapIdentifier.viewName) as? KakaoMapsSDK.KakaoMap
            else { return }

            if pendingRoutes != currentRoutes {
                applySolidRoutes(pendingRoutes.filter { $0.dotStyle == nil }, on: mapView)
                applyDottedRoutes(pendingRoutes.filter { $0.dotStyle != nil }, on: mapView)
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

            moveCamera(to: focus, on: mapView)
            currentFocus = focus
        }

        // 핀 탭 시 해당 좌표로 카메라를 이동한다. 이후 외부 focus 갱신이 같은 좌표면
        // 중복 애니메이션이 일어나지 않도록 currentFocus 도 함께 갱신한다.
        private func focusCamera(on coordinate: MapCoordinate) {
            guard
                isMapReady,
                let mapView = controller?.getView(MapIdentifier.viewName) as? KakaoMapsSDK.KakaoMap
            else { return }

            moveCamera(to: coordinate, on: mapView)
            currentFocus = coordinate
        }

        // 현재 줌 레벨을 유지하며 target 좌표로 카메라를 애니메이션 이동한다.
        private func moveCamera(to coordinate: MapCoordinate, on mapView: KakaoMapsSDK.KakaoMap) {
            let target = MapPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
            let cameraUpdate = CameraUpdate.make(target: target, mapView: mapView)
            mapView.animateCamera(
                cameraUpdate: cameraUpdate,
                options: CameraAnimationOptions(autoElevation: false, consecutive: false, durationInMillis: 300)
            )
        }

        private func applySolidRoutes(_ routes: [MapRoute], on mapView: KakaoMapsSDK.KakaoMap) {
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

        // 점선 경로를 RouteManager 로 그린다. 삼각형 dot 이미지를 RoutePattern.symbol 로 넣어
        // 경로 진행 방향을 따라 회전 배치되게 한다(본선 텍스처는 투명, dot 만 노출).
        // distance(점 간격) = dot 진행방향 길이 + dotStyle.spacing 으로 둔다.
        private func applyDottedRoutes(_ routes: [MapRoute], on mapView: KakaoMapsSDK.KakaoMap) {
            let routeManager = mapView.getRouteManager()
            routeManager.removeRouteLayer(layerID: MapIdentifier.dottedRouteLayer)

            guard !routes.isEmpty else { return }

            let styleSetID = MapIdentifier.dottedRouteStyleSet
            let styleSet = RouteStyleSet(styleID: styleSetID)

            for route in routes {
                guard let dotStyle = route.dotStyle else { continue }

                // applyDottedRoutes 는 updateUIView·SDK delegate 등 항상 메인에서 호출되므로
                // @MainActor 인 이미지 렌더를 assumeIsolated 로 동기 실행한다.
                let dot = MainActor.assumeIsolated {
                    RouteDotMarker(color: dotStyle.color).makeImage()
                }

                // dot 이미지를 본선 패턴으로 반복 배치한다. 패턴은 경로 진행 방향을 따라
                // 회전 배치되므로 ▲ dot 이 진행 방향을 가리킨다.
                // distance(점 간격) = dot 진행축 길이 + dotStyle.spacing.
                let pattern = RoutePattern(
                    pattern: dot,
                    distance: Float(dotStyle.spacing),
                    symbol: nil,
                    pinStart: false,
                    pinEnd: false
                )
                styleSet.addPattern(pattern)

                // 본선은 보이지 않게 한다. color: .clear 는 SDK 가 본선을 컬링해 pattern 까지
                // 사라지므로, 거의 투명한 알파로 두어 컬링은 피하되 연결선은 보이지 않게 한다.
                let patternIndex = styleSet.patterns.count - 1
                let perLevel = PerLevelRouteStyle(
                    width: Constant.dottedRouteWidth,
                    color: dotStyle.color.routeUIColor.withAlphaComponent(Constant.dottedRouteLineAlpha),
                    strokeWidth: 0,
                    strokeColor: .clear,
                    level: 0,
                    patternIndex: patternIndex
                )
                styleSet.addStyle(RouteStyle(styles: [perLevel]))
            }

            routeManager.addRouteStyleSet(styleSet)

            guard let layer = routeManager.addRouteLayer(
                layerID: MapIdentifier.dottedRouteLayer,
                zOrder: 2
            ) else {
                Log.error("addRouteLayer returned nil")
                return
            }

            for (index, route) in routes.enumerated() {
                let points = route.coordinates.map {
                    MapPoint(longitude: $0.longitude, latitude: $0.latitude)
                }
                let options = RouteOptions(routeID: route.id, styleID: styleSetID, zOrder: 0)
                options.segments = [RouteSegment(points: points, styleIndex: UInt(index))]

                if let drawn = layer.addRoute(option: options) {
                    drawn.show()
                } else {
                    Log.error("addRoute returned nil - routeID: \(route.id)")
                }
            }
        }

        // 핀을 LOD 라벨 레이어에 그린다. 화면상 가까운 핀이 겹칠 경우
        // LOD 반경(radius)·경쟁(competition) 규칙에 따라 우선순위가 낮은 핀은 숨겨진다.
        // 스타일 등록(createPoiStyles)과 POI 추가(createPois)를 분리한다.
        private func applyPins(_ pins: [MapPin], on mapView: KakaoMapsSDK.KakaoMap) {
            let labelManager = mapView.getLabelManager()
            labelManager.removeLodLabelLayer(layerID: MapIdentifier.pinLayer)
            labelManager.removeLabelLayer(layerID: MapIdentifier.pinLayer)
            poiTapHandlers.forEach { $0.dispose() }
            poiTapHandlers.removeAll()
            pinMap.removeAll()

            guard !pins.isEmpty else { return }

            createPoiStyles(pins, on: labelManager)

            // competitionType .same + orderType .rank: 같은 레이어 핀끼리 rank로 경쟁하고,
            // radius 안에서 겹치면 우선순위(rank)가 낮은 핀이 표출되지 않는다.
            let layerOptions = LodLabelLayerOptions(
                layerID: MapIdentifier.pinLayer,
                competitionType: .same,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 10001,
                radius: Constant.lodRadius
            )
            guard let layer = labelManager.addLodLabelLayer(option: layerOptions) else { return }
            layer.setClickable(true)

            createPois(pins, on: layer)
        }

        // 핀별 PoiOptions 와 위치 배열을 함께 구성한다. 배치 추가(addLodPois)는
        // 다중 옵션·다중 위치 변형을 사용하므로 옵션 배열과 위치 배열을 index 쌍으로 맞춘다.
        // 핀마다 styleID/rank/poiID 가 달라 단일 옵션 변형은 사용할 수 없다.
        private func makePoiOptions(_ pins: [MapPin]) -> ([PoiOptions], [MapPoint]) {
            var optionsList: [PoiOptions] = []
            var positions: [MapPoint] = []
            for (index, pin) in pins.enumerated() {
                let options = PoiOptions(styleID: MapIdentifier.pinStyle(index: index), poiID: pin.id)
                options.rank = index
                options.clickable = true
                optionsList.append(options)
                positions.append(MapPoint(longitude: pin.coordinate.longitude, latitude: pin.coordinate.latitude))
                pinMap[pin.id] = pin
            }
            return (optionsList, positions)
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

        // 등록된 스타일을 참조해 좌표마다 LodPoi를 배치 추가하고 탭 매칭용 pinMap을 구성한다.
        // rank는 입력 순서대로 부여한다(겹침 시 앞선 핀이 우선 표출).
        //
        // LodPoi 는 LOD 사전처리로 인해 실제 객체가 addLodPois 의 콜백 시점에 확정된다.
        // 동기 반환 핸들이 아닌 콜백으로 전달된 LodPoi 에 탭 핸들러를 등록해야
        // 클릭 디스패처에 정상 반영되므로, 배치 콜백 안에서 입력 순서(index)대로 매칭한다.
        private func createPois(_ pins: [MapPin], on layer: LodLabelLayer) {
            let (optionsList, positions) = makePoiOptions(pins)

            _ = layer.addLodPois(options: optionsList, at: positions) { [weak self] lodPois in
                guard let self, let lodPois, lodPois.count == pins.count else { return }

                for (index, lodPoi) in lodPois.enumerated() {
                    let pin = pins[index]
                    self.pinMap[lodPoi.itemID] = pin
                    let handler = lodPoi.addPoiTappedEventHandler(target: self, handler: Coordinator.handlePoiTapped)
                    self.poiTapHandlers.append(handler)
                    lodPoi.show()
                }
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
    static let dottedRouteLayer = "bangawo_dotted_route_layer"
    static let dottedRouteStyleSet = "bangawo_dotted_route_styles"
    static let pinLayer = "bangawo_pin_layer"

    static func pinStyle(index: Int) -> String {
        "bangawo_pin_style_\(index)"
    }
}

private enum Constant {
    /// LOD 겹침 판정 반경(화면 point). 이 반경 안에서 겹치는 핀은
    /// 우선순위(rank)가 낮은 쪽이 표출되지 않는다. 값이 클수록 더 적극적으로 숨긴다.
    static let lodRadius: Float = 40

    /// dot symbol 의 진행방향(apex 축) 길이(point). `RouteDotMarker` 의 height(9) 와 맞춘다.
    /// `distance`(점 간격) = 이 값 + `dotStyle.spacing` 으로 계산한다.
    static let dotLength: CGFloat = 9

    /// 점선 본선(route body) 폭(point). pattern(▲)은 이 폭에 맞춰 렌더되므로
    /// dot 크기(`RouteDotMarker` width 10) 만큼 확보한다.
    static let dottedRouteWidth: UInt = 10

    /// 점선 본선(연결선) 알파. `.clear`(알파 0)는 SDK 가 본선을 컬링해 pattern 까지 사라지므로,
    /// 컬링은 피하되 연결선은 보이지 않도록 거의 0에 가까운 값을 사용한다.
    static let dottedRouteLineAlpha: CGFloat = 0.01
}
