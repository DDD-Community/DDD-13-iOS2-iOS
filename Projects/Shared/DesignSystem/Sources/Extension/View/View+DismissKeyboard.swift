//
//  View+DismissKeyboard.swift
//  DesignSystem
//

import SwiftUI

public extension View {
    /// 빈 영역을 탭하면 first responder를 해제해 키보드를 내린다.
    ///
    /// `simultaneousGesture`로 탭을 가로채므로, 전체 화면(앱 루트)에 한 번 걸면
    /// KakaoMap POI 탭처럼 별도 tap 처리에 의존하는 화면의 제스처까지 같이 삼킨다.
    /// 따라서 앱 전역이 아니라 **TextField가 있는 화면의 최상위 뷰에만** 개별로 적용한다.
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}
