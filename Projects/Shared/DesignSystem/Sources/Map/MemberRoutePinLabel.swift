import SwiftUI

/// 경로(route) 표현용 멤버 핀.
///
/// 멤버의 출발지에 표시되며, 목적지까지의 환승 횟수·소요 시간을 캡슐 라벨로,
/// 멤버 이미지를 원형 avatar 로 보여준다. 캡슐 배경과 avatar 테두리는 해당 멤버의
/// 경로(`MapRoute.dotStyle.color`)와 같은 `routeColor` 를 주입받되, 핀은 `pinColor`(500),
/// 경로는 `routeColor`(400) 로 약간 다른 톤을 써 두 요소를 한 쌍으로 묶는다.
///
/// `MapPinLabel` 과 동일하게 SwiftUI 뷰를 `makePin(id:coordinate:)` 으로 스냅샷해
/// `MapPin` 으로 변환한 뒤 `KakaoMap` 에 전달한다.
public struct MemberRoutePinLabel: View {
    private let avatarType: Avatar.AvatarType
    private let routeColor: RouteDotColor
    private let transferCount: Int
    private let durationMinutes: Int

    public init(
        avatarType: Avatar.AvatarType,
        routeColor: RouteDotColor,
        transferCount: Int,
        durationMinutes: Int
    ) {
        self.avatarType = avatarType
        self.routeColor = routeColor
        self.transferCount = transferCount
        self.durationMinutes = durationMinutes
    }

    public var body: some View {
        VStack(alignment: .center, spacing: Metric.spacing) {
            BangawoText(labelText, textStyle: .labelXSmall)
                .foregroundStyle(Colors.white)
                .padding(.horizontal, Metric.labelHorizontalPadding)
                .padding(.vertical, Metric.labelVerticalPadding)
                .background(routeColor.pinColor)
                .clipShape(Capsule())

            Avatar(avatarType: avatarType, size: .s40)
                .overlay(
                    Circle().strokeBorder(routeColor.pinColor, lineWidth: Metric.avatarBorderWidth)
                )
        }
    }

    private var labelText: String {
        "환승 \(transferCount)회 · \(durationText)"
    }

    private var durationText: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60
        return hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분"
    }
}

// MARK: - MapPin 변환

public extension MemberRoutePinLabel {
    /// 라벨을 스냅샷해 심볼 이미지로 갖는 `MapPin` 을 생성한다.
    ///
    /// 좌표에 고정할 기준점은 하단 avatar 의 중심이다. 가로는 중앙(0.5),
    /// 세로는 `전체 높이 − avatar 절반 높이` 를 전체 높이로 나눈 비율로 계산한다.
    @MainActor
    func makePin(id: String = UUID().uuidString, coordinate: MapCoordinate) -> MapPin {
        let image = snapshot(scale: Metric.pinSymbolScale)
        let anchorY = image.size.height > 0
            ? (image.size.height - Metric.avatarLength / 2) / image.size.height
            : 0.5
        return MapPin(
            id: id,
            coordinate: coordinate,
            iconImage: image,
            iconAnchor: CGPoint(x: 0.5, y: anchorY),
            focusesOnTap: false
        )
    }
}

// MARK: - Constants

private enum Metric {
    static let spacing: CGFloat = 4
    static let avatarLength: CGFloat = 40
    static let avatarBorderWidth: CGFloat = 2.4
    static let labelHorizontalPadding: CGFloat = 8
    static let labelVerticalPadding: CGFloat = 6

    /// 마커 스냅샷 래스터 배율. Kakao SDK 가 POI 심볼을 @2x 자산으로 가정하므로 2 로 고정한다.
    static let pinSymbolScale: CGFloat = 2
}
