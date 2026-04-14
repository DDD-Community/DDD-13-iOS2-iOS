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

// MARK: - MapRoute

public struct MapRoute: Sendable, Equatable, Identifiable {
    public let id: String
    public let coordinates: [MapCoordinate]
    public let lineColor: UIColor
    public let lineWidth: UInt
    public let strokeColor: UIColor
    public let strokeWidth: UInt

    public init(
        id: String = UUID().uuidString,
        coordinates: [MapCoordinate],
        lineColor: UIColor = .systemBlue,
        lineWidth: UInt = 4,
        strokeColor: UIColor = .clear,
        strokeWidth: UInt = 0
    ) {
        self.id = id
        self.coordinates = coordinates
        self.lineColor = lineColor
        self.lineWidth = lineWidth
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
    }
}

// MARK: - MapPin

public struct MapPin: Sendable, Equatable, Identifiable {
    public let id: String
    public let coordinate: MapCoordinate
    public let title: String
    public let iconImage: UIImage?

    public init(
        id: String = UUID().uuidString,
        coordinate: MapCoordinate,
        title: String = "",
        iconImage: UIImage? = nil
    ) {
        self.id = id
        self.coordinate = coordinate
        self.title = title
        self.iconImage = iconImage
    }

    public static func == (lhs: MapPin, rhs: MapPin) -> Bool {
        lhs.id == rhs.id
            && lhs.coordinate == rhs.coordinate
            && lhs.title == rhs.title
            && lhs.iconImage === rhs.iconImage
    }
}
