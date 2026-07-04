//
//  KakaoShareService.swift
//  Service
//

import UIKit

import KakaoSDKShare
import KakaoSDKTemplate

import Entity

/// 카카오톡 텍스트 템플릿으로 모임 초대 메시지를 전송하는 서비스입니다.
///
/// Presentation 계층이 `KakaoSDKShare`/`KakaoSDKTemplate`에 직접 의존하지 않도록
/// 템플릿 구성, 공유 URL 생성, 카카오톡 실행을 Service 계층 안에 숨깁니다.
public protocol KakaoShareServiceInterface: Sendable {
    /// 초대 링크를 담은 카카오톡 텍스트 템플릿 메시지를 전송합니다.
    /// 카카오톡이 설치되어 있으면 앱 공유, 없으면 웹 공유로 폴백합니다.
    @MainActor
    func shareInvitation(_ invitation: GroupInvitation) async throws
}

public final class KakaoShareService: KakaoShareServiceInterface {
    public init() {}

    @MainActor
    public func shareInvitation(_ invitation: GroupInvitation) async throws {
        let template = makeTemplate(invitation)
        let sharingUrl = try await sharingUrl(for: template)
        await UIApplication.shared.open(sharingUrl)
    }

    /// 초대 문구·딥링크·버튼으로 구성한 텍스트 템플릿을 만듭니다.
    private func makeTemplate(_ invitation: GroupInvitation) -> TextTemplate {
        let text = String(format: Constant.messageFormat, invitation.groupName, invitation.hostNickname)
        let linkUrl = URL(string: invitation.inviteLink)
        let link = Link(webUrl: linkUrl, mobileWebUrl: linkUrl)

        return TextTemplate(
            text: text,
            link: link,
            buttonTitle: Constant.buttonTitle
        )
    }

    /// 카카오톡 설치 여부에 따라 앱 공유/웹 공유 URL을 반환합니다.
    @MainActor
    private func sharingUrl(for template: TextTemplate) async throws -> URL {
        if ShareApi.isKakaoTalkSharingAvailable() {
            return try await withCheckedThrowingContinuation { continuation in
                ShareApi.shared.shareDefault(templatable: template) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let url = result?.url else {
                        continuation.resume(throwing: KakaoShareServiceError.missingSharingUrl)
                        return
                    }

                    continuation.resume(returning: url)
                }
            }
        }

        guard let url = ShareApi.shared.makeDefaultUrl(templatable: template) else {
            throw KakaoShareServiceError.missingSharingUrl
        }

        return url
    }
}

// MARK: - Error

private enum KakaoShareServiceError: Error {
    /// 카카오 공유 URL을 얻지 못한 경우.
    case missingSharingUrl
}

// MARK: - Constants

private enum Constant {
    /// 초대 메시지 포맷. 1번 인자: 모임 이름, 2번 인자: 호스트 닉네임.
    static let messageFormat = "🎉 '%@' 모임 초대장이 도착했어요!\n%@님과 언제, 어디서 만날지 함께 정해봐요."
    /// 초대 딥링크로 이동하는 버튼 타이틀.
    static let buttonTitle = "지금 참여하기"
}
