//
//  KakaoInviteMessageSender.swift
//  HomeFeature
//
//  TODO: 카카오 모듈 격리 이관 예정 파일.
//  현재는 Presentation(HomeFeature) 내부에서 KakaoSDKShare/KakaoSDKTemplate 를 직접 import 해
//  카카오 텍스트 템플릿 메시지를 전송한다. 프로젝트 컨벤션상 카카오 SDK import 는 Data/Service 에
//  격리되어야 하며, 추후 "서드파티 래퍼를 통해서만 카카오 모듈에 접근" 하도록 설계가 정리되면
//  이 객체도 별도 모듈(예: Data/Service 어댑터 또는 Kakao 전용 래퍼 모듈)로 분리될 예정이다.
//

import UIKit

import KakaoSDKShare
import KakaoSDKTemplate

import Utill

/// 카카오톡 텍스트 템플릿으로 모임 초대 메시지를 전송하는 헬퍼.
/// 저장 상태가 없으므로 인스턴스 없이 `static func` 로 호출한다.
enum KakaoInviteMessageSender {
    /// 초대 링크를 담은 카카오톡 텍스트 템플릿 메시지를 전송한다.
    /// 카카오톡이 설치되어 있으면 앱 공유, 없으면 웹 공유로 폴백한다.
    @MainActor
    static func send(
        inviteLink: String,
        groupName: String,
        hostNickname: String
    ) async throws {
        let template = makeTemplate(
            inviteLink: inviteLink,
            groupName: groupName,
            hostNickname: hostNickname
        )

        let sharingUrl = try await sharingUrl(for: template)
        await UIApplication.shared.open(sharingUrl)
    }

    /// 초대 문구·딥링크·버튼으로 구성한 텍스트 템플릿을 만든다.
    private static func makeTemplate(
        inviteLink: String,
        groupName: String,
        hostNickname: String
    ) -> TextTemplate {
        let text = String(format: Constant.messageFormat, groupName, hostNickname)
        let linkUrl = URL(string: inviteLink)
        let link = Link(webUrl: linkUrl, mobileWebUrl: linkUrl)

        return TextTemplate(
            text: text,
            link: link,
            buttonTitle: Constant.buttonTitle
        )
    }

    /// 카카오톡 설치 여부에 따라 앱 공유/웹 공유 URL 을 반환한다.
    @MainActor
    private static func sharingUrl(for template: TextTemplate) async throws -> URL {
        if ShareApi.isKakaoTalkSharingAvailable() {
            return try await withCheckedThrowingContinuation { continuation in
                ShareApi.shared.shareDefault(templatable: template) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let url = result?.url else {
                        continuation.resume(throwing: KakaoInviteShareError.missingSharingUrl)
                        return
                    }

                    continuation.resume(returning: url)
                }
            }
        }

        guard let url = ShareApi.shared.makeDefaultUrl(templatable: template) else {
            throw KakaoInviteShareError.missingSharingUrl
        }

        return url
    }
}

// MARK: - Error

private enum KakaoInviteShareError: Error {
    /// 카카오 공유 URL 을 얻지 못한 경우.
    case missingSharingUrl
}

// MARK: - Constants

private enum Constant {
    /// 초대 메시지 포맷. 1번 인자: 모임 이름, 2번 인자: 호스트 닉네임.
    static let messageFormat = "🎉 '%@' 모임 초대장이 도착했어요!\n%@님과 언제, 어디서 만날지 함께 정해봐요."
    /// 초대 딥링크로 이동하는 버튼 타이틀.
    static let buttonTitle = "지금 참여하기"
}
