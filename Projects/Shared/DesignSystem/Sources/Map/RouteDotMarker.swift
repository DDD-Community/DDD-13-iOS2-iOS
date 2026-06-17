import SwiftUI

/// 점선 경로(dot line)용 삼각형 dot 마커.
///
/// KakaoMap `RoutePattern` 의 symbol 이미지로 쓰기 위해 `makeImage()` 로 스냅샷한다.
/// symbol 은 경로 진행 방향에 따라 이미지 중심을 기준으로 회전 배치되므로, 여백 없이
/// 순수 dot 만 렌더한다(점 사이 간격은 `RoutePattern.distance` 로 제어한다).
/// 둥근 모서리 삼각형(▲) 위에 1px 테두리를 얹은 형태로, 채움 색은 초기화 시 주입한다.
public struct RouteDotMarker: View {
    private let color: RouteDotColor

    public init(color: RouteDotColor) {
        self.color = color
    }

    public var body: some View {
        let shape = RoundedTriangle(cornerRadius: Metric.cornerRadius, inset: Metric.borderWidth / 2)

        shape
            .fill(color.routeColor)
            .overlay(shape.stroke(Colors.gray00, lineWidth: Metric.borderWidth))
            .frame(width: Metric.width, height: Metric.height)
    }
}

// MARK: - 이미지화

public extension RouteDotMarker {
    /// 마커를 렌더해 `UIImage` 로 변환한다. `RoutePattern(pattern:)` 에 그대로 전달할 수 있다.
    ///
    /// 여백 없는 순수 10×9 dot 이미지라 회전 중심이 이미지 중앙에 오며, apex(▲)가 위쪽을
    /// 가리킨다. 점 사이 간격은 `RoutePattern.distance` 로 제어한다.
    @MainActor
    func makeImage(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        snapshot(scale: scale)
    }
}

// MARK: - RouteDotColor

/// 멤버 핀과 경로(route)에 묶어서 매칭되는 색 후보군.
///
/// 한 멤버에게 하나의 case 가 할당되면, 멤버 핀은 `pinColor`(500), 경로는
/// `routeColor`(400) 로 약간씩 다른 톤을 사용해 두 요소를 시각적으로 한 쌍으로 묶는다.
public enum RouteDotColor: CaseIterable, Equatable, Sendable {
    case green
    case orange
    case blue
    case red
    case purple

    /// 멤버 핀(MemberRoutePinLabel) 캡슐 배경·avatar 테두리 색 (500).
    var pinColor: Color {
        switch self {
        case .green: return Colors.green500
        case .orange: return Colors.orange500
        case .blue: return Colors.blue500
        case .red: return Colors.red500
        case .purple: return Colors.purple500
        }
    }

    /// 경로(route dot) 채움 색 (400).
    var routeColor: Color {
        switch self {
        case .green: return Colors.green400
        case .orange: return Colors.orange400
        case .blue: return Colors.blue400
        case .red: return Colors.red400
        case .purple: return Colors.purple400
        }
    }

    /// 경로 본선(route body) 에 쓰는 `routeColor` 의 UIColor 변환값.
    var routeUIColor: UIColor {
        UIColor(routeColor)
    }
}

// MARK: - RoundedTriangle

/// 세 꼭짓점이 `cornerRadius` 로 둥글려진 삼각형(▲).
/// 테두리(stroke)가 frame 밖으로 잘리지 않도록 `inset` 만큼 안쪽에 그린다.
private struct RoundedTriangle: Shape {
    let cornerRadius: CGFloat
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let bounds = rect.insetBy(dx: inset, dy: inset)
        let top = CGPoint(x: bounds.midX, y: bounds.minY)
        let bottomRight = CGPoint(x: bounds.maxX, y: bounds.maxY)
        let bottomLeft = CGPoint(x: bounds.minX, y: bounds.maxY)

        var path = Path()
        path.move(to: CGPoint(x: (top.x + bottomRight.x) / 2, y: (top.y + bottomRight.y) / 2))
        path.addArc(tangent1End: bottomRight, tangent2End: bottomLeft, radius: cornerRadius)
        path.addArc(tangent1End: bottomLeft, tangent2End: top, radius: cornerRadius)
        path.addArc(tangent1End: top, tangent2End: bottomRight, radius: cornerRadius)
        path.closeSubpath()
        return path
    }
}

// MARK: - Constants

private enum Metric {
    static let width: CGFloat = 10
    static let height: CGFloat = 9
    static let cornerRadius: CGFloat = 1.05
    static let borderWidth: CGFloat = 1
}

// MARK: - Preview

#Preview("RouteDotMarker") {
    // dot 이 10×9 로 매우 작아 실제 크기로는 확인이 어렵다.
    // 색 후보군별로 실제 크기 · 확대(×8) · 점선 반복 배치를 함께 보여준다.
    VStack(alignment: .leading, spacing: 20) {
        ForEach(RouteDotColor.allCases, id: \.self) { color in
            HStack(spacing: 24) {
                RouteDotMarker(color: color)

                RouteDotMarker(color: color)
                    .scaleEffect(8)
                    .frame(width: 80, height: 72)

                // 점선 경로처럼 진행 방향(▶)을 향해 회전 반복 배치한 모습
                HStack(spacing: 4) {
                    ForEach(0 ..< 6, id: \.self) { _ in
                        RouteDotMarker(color: color)
                            .scaleEffect(2)
                            .frame(width: 20, height: 18)
                            .rotationEffect(.degrees(90))
                    }
                }
            }
        }
    }
    .padding(40)
    .background(Colors.gray00)
}
