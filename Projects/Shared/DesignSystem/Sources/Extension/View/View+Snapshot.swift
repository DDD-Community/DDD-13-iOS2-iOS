//
//  View+Snapshot.swift
//  DesignSystem
//

import SwiftUI

@MainActor
public extension View {
    /// SwiftUI 뷰를 현재 화면 scale로 렌더한 UIImage로 변환한다.
    ///
    /// KakaoMap POI symbol처럼 `UIImage`만 받는 API에 SwiftUI 뷰를 마커로 쓰기 위해 사용한다.
    /// `ImageRenderer`와 달리 `UIHostingController` 위에서 실제 뷰 계층을
    /// `drawHierarchy(in:afterScreenUpdates:)`로 그리므로, 텍스트 보더·블렌딩 같은
    /// 복합 modifier가 더 안정적으로 반영된다.
    ///
    /// - Parameter scale: 래스터 배율. Kakao SDK의 `PoiIconStyle`은 `UIImage.scale`을 무시하고
    ///   비트맵 픽셀 dimension을 기준으로 표시 크기를 계산하므로(심볼을 @2x 자산으로 가정),
    ///   기기 배율 대신 SDK 기준 밀도에 맞춘 고정값을 전달해 의도한 point 크기와 일치시킨다.
    ///   기본값은 화면 배율(일반 캡처 용도, Retina 선명도).
    func snapshot(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let controller = UIHostingController(rootView: edgesIgnoringSafeArea(.all))
        guard let view = controller.view else { return UIImage() }

        let targetSize = view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .clear

        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}
