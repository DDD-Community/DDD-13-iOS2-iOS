//
//  PermissionAlertConfig.swift
//  Presentation
//
//  권한 거절 시 노출할 알럿 메시지 + 설정 이동 헬퍼
//

import Foundation
import UIKit

public struct PermissionAlertConfig: Equatable, Sendable {
    public let title: String
    public let message: String

    public static let camera = PermissionAlertConfig(
        title: "카메라 권한이 필요합니다",
        message: "프로필 사진 촬영을 위해 카메라 접근이 필요합니다. 설정에서 권한을 허용해 주세요"
    )

    public static let photoLibrary = PermissionAlertConfig(
        title: "사진 권한이 필요합니다",
        message: "프로필 사진 선택을 위해 사진 접근이 필요합니다. 설정에서 권한을 허용해 주세요"
    )
}

enum SystemSettingsOpener {
    static func open() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        Task { @MainActor in
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}
