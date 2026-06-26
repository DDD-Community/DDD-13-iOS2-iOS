//
//  TogglePlacePickUseCase.swift
//  UseCase
//

public protocol TogglePlacePickUseCase: Sendable {
    /// 장소 담기/취소를 토글한다. `isCurrentlyPicked`가 true면 담기 취소, false면 담기를 요청한다.
    func execute(meetingId: Int, placeId: Int, isCurrentlyPicked: Bool) async throws
}
