import SwiftUI

/// 지도 마커용 라벨 뷰.
///
/// 원형 아이콘 + 제목 텍스트를 세로로 결합한 SwiftUI 뷰로, `makePin(id:coordinate:)`을 통해
/// 스냅샷 이미지를 심볼로 갖는 `MapPin`으로 변환해 `KakaoMap`에 전달한다.
/// 리스트 등 일반 UI에서는 뷰 자체로도 사용할 수 있다.
public struct MapPinLabel: View {
    private let assetName: String
    private let title: String

    public init(assetName: String, title: String) {
        self.assetName = assetName
        self.title = title
    }

    public var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Image(assetName: assetName)
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
                .frame(width: Metric.iconLength, height: Metric.iconLength)

            BangawoText(title, textStyle: .labelXSmall)
                .foregroundStyle(Colors.gray900)
                .modifier(TextStroke(color: Colors.gray200, width: 1))
        }
        // 아이콘 그림자가 스냅샷 bounds(intrinsicContentSize) 밖으로 그려져 잘리지 않도록,
        // 그림자 최대 확산 범위(blur radius + offsetY)만큼 여백을 확보한다.
        .padding(Metric.iconShadowPadding)
    }
}

// MARK: - MapPin 변환

public extension MapPinLabel {
    /// 라벨을 스냅샷해 심볼 이미지로 갖는 `MapPin`을 생성한다.
    ///
    /// 좌표에 고정할 기준점은 아이콘 중심이다. 세로 VStack(center 정렬)이므로 x는 항상
    /// 이미지 가로 중앙(0.5), y는 `상단 패딩 + 아이콘 절반 높이`를 전체 이미지 높이로 나눈 비율이다.
    /// (`image.size`는 래스터 scale과 무관한 point 크기라 비율 계산이 scale에 영향받지 않는다.)
    @MainActor
    func makePin(id: String = UUID().uuidString, coordinate: MapCoordinate) -> MapPin {
        let image = snapshot(scale: Metric.pinSymbolScale)
        let iconCenterY = Metric.iconShadowPadding + Metric.iconLength / 2
        let anchorY = image.size.height > 0 ? iconCenterY / image.size.height : 0.5
        return MapPin(
            id: id,
            coordinate: coordinate,
            title: title,
            iconImage: image,
            iconAnchor: CGPoint(x: 0.5, y: anchorY)
        )
    }
}

// MARK: - TextStroke

private struct TextStroke: ViewModifier {
    let color: Color
    let width: CGFloat
    let radius: CGFloat

    init(
        color: Color,
        width: CGFloat,
        radius: CGFloat = 0
    ) {
        self.color = color
        self.width = width
        self.radius = radius
    }

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: width, y: width)
            .shadow(color: color, radius: radius, x: -width, y: width)
            .shadow(color: color, radius: radius, x: width, y: -width)
            .shadow(color: color, radius: radius, x: -width, y: -width)
    }
}

// MARK: - Constants

private enum Metric {
    static let iconLength: CGFloat = 24
    static let iconBorderWidth: CGFloat = 1.2
    static let iconShadowRadius: CGFloat = 14.4
    static let iconShadowOffsetY: CGFloat = 4.8
    static let iconShadowPadding: CGFloat = iconShadowRadius + iconShadowOffsetY

    /// 마커 스냅샷 래스터 배율.
    /// Kakao SDK는 POI 심볼 비트맵을 @2x 자산으로 가정해 픽셀을 항상 2로 나눠 point 크기를
    /// 계산하므로, 기기 배율(`UIScreen.main.scale`)이 아닌 이 고정값으로 래스터해야
    /// 리스트 아이콘(`iconLength`)과 표시 크기가 일치한다.
    static let pinSymbolScale: CGFloat = 2
}

private enum Constant {
    static let iconShadowColor = Color(
        red: 43 / 255,
        green: 43 / 255,
        blue: 43 / 255,
        opacity: 31 / 255
    )
}
