import UIKit

// MARK: - MapCoordinate

public struct MapCoordinate: Sendable, Equatable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - MapViewport

/// 카메라 정지 시점의 지도 화면 상태.
/// 중심 좌표를 기준으로 주변 데이터(지하철역·장소 등)를 조회할 때 사용한다.
public struct MapViewport: Sendable, Equatable {
    public let center: MapCoordinate
    public let zoomLevel: Int

    public init(center: MapCoordinate, zoomLevel: Int) {
        self.center = center
        self.zoomLevel = zoomLevel
    }
}

// MARK: - MapRoute

public struct MapRoute: Sendable, Equatable, Identifiable {
    public let id: String
    public let coordinates: [MapCoordinate]
    public let lineColor: UIColor
    public let lineWidth: UInt
    public let strokeColor: UIColor
    public let strokeWidth: UInt

    /// 점선(dot line) 스타일. `nil` 이면 위 line/stroke 속성으로 실선을 그린다.
    /// 값이 있으면 삼각형 dot 가 진행 방향을 향해 회전 배치된 점선으로 그린다.
    public let dotStyle: RouteDotStyle?

    public init(
        id: String = UUID().uuidString,
        coordinates: [MapCoordinate],
        lineColor: UIColor = .systemBlue,
        lineWidth: UInt = 4,
        strokeColor: UIColor = .clear,
        strokeWidth: UInt = 0,
        dotStyle: RouteDotStyle? = nil
    ) {
        self.id = id
        self.coordinates = coordinates
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.dotStyle = dotStyle
    }
}

// MARK: - RouteDotStyle

/// dot line 의 점 모양·간격 스타일.
public struct RouteDotStyle: Sendable, Equatable {
    public let color: RouteDotColor

    /// 점 사이 간격(point). `RoutePattern.distance` 계산에 사용한다.
    public let spacing: CGFloat

    public init(color: RouteDotColor, spacing: CGFloat = 2) {
        self.color = color
        self.spacing = spacing
    }
}

// MARK: - MapPin

public struct MapPin: Sendable, Equatable, Identifiable {
    public let id: String
    public let coordinate: MapCoordinate
    public let title: String
    public let iconImage: UIImage?

    /// 아이콘 이미지 내에서 좌표에 고정될 기준점(정규화 0~1).
    /// 꼬리 없는 원형 마커는 중앙(0.5, 0.5), SwiftUI 결합 이미지는 아이콘 중심으로 지정한다.
    public let iconAnchor: CGPoint

    /// 핀 탭 시 해당 좌표로 카메라를 포커싱할지 여부.
    /// 멤버 핀처럼 포커싱 대상이 아닌 핀은 `false` 로 둔다.
    public let focusesOnTap: Bool

    public init(
        id: String = UUID().uuidString,
        coordinate: MapCoordinate,
        title: String = "",
        iconImage: UIImage? = nil,
        iconAnchor: CGPoint = CGPoint(x: 0.5, y: 1.0),
        focusesOnTap: Bool = true
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.iconImage = iconImage
        self.iconAnchor = iconAnchor
        self.focusesOnTap = focusesOnTap
    }

    public static func == (lhs: MapPin, rhs: MapPin) -> Bool {
        lhs.id == rhs.id
            && lhs.coordinate == rhs.coordinate
            && lhs.title == rhs.title
            && lhs.iconImage === rhs.iconImage
            && lhs.iconAnchor == rhs.iconAnchor
            && lhs.focusesOnTap == rhs.focusesOnTap
    }
}
