//
//  View+Snapshot.swift
//  DesignSystem
//

import SwiftUI

@MainActor
public extension View {
    /// SwiftUI 뷰를 지정 scale로 렌더한 UIImage로 변환한다.
    ///
    /// KakaoMap POI symbol·RoutePattern처럼 `UIImage`만 받는 API에 SwiftUI 뷰를 마커로 쓰기 위해 사용한다.
    /// SwiftUI 네이티브 `ImageRenderer`로 뷰 트리를 직접 렌더하므로 윈도우 부착·렌더 패스 타이밍에
    /// 의존하지 않아, 작은 vector 콘텐츠도 안정적으로 비트맵화된다.
    ///
    /// - Parameter scale: 래스터 배율. Kakao SDK의 `PoiIconStyle`은 `UIImage.scale`을 무시하고
    ///   비트맵 픽셀 dimension을 기준으로 표시 크기를 계산하므로(심볼을 @2x 자산으로 가정),
    ///   기기 배율 대신 SDK 기준 밀도에 맞춘 고정값을 전달해 의도한 point 크기와 일치시킨다.
    ///   기본값은 화면 배율(일반 캡처 용도, Retina 선명도).
    func snapshot(scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale
        return renderer.uiImage ?? UIImage()
    }
}
