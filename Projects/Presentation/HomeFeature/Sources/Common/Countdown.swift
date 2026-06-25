//
//  Countdown.swift
//  Presentation
//

import Combine
import Foundation

/// 마감 시각까지 남은 시간을 일/시/분/초로 분해하는 범용 카운트다운 모델.
/// 문자열 파싱과 표시 문구 조립은 호출부 책임이며, 본 모델은 분해/포맷만 담당한다.
enum Countdown {
    /// 1초 주기 공통 클럭. 구독자가 있을 때만 tick을 발행한다.
    /// `.autoconnect()` + `.share()` 조합으로 첫 구독 시 타이머가 켜지고,
    /// 마지막 구독 해제 시 멈춘다(전역 상시 구동 방지).
    static let everySecond: AnyPublisher<Date, Never> =
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .share()
            .eraseToAnyPublisher()

    struct Remaining {
        let days: Int
        let hours: Int
        let minutes: Int
        let seconds: Int
        let isExpired: Bool

        /// "HH:MM:SS" 형식의 시:분:초 텍스트(일 단위는 제외).
        var clockText: String {
            String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }
    }

    /// `now` 기준 `deadline`까지 남은 시간 컴포넌트. 이미 지났으면 모든 값 0, `isExpired = true`.
    static func remaining(until deadline: Date, now: Date) -> Remaining {
        let total = max(0, Int(deadline.timeIntervalSince(now)))

        return Remaining(
            days: total / 86400,
            hours: (total % 86400) / 3600,
            minutes: (total % 3600) / 60,
            seconds: total % 60,
            isExpired: total == 0
        )
    }
}
