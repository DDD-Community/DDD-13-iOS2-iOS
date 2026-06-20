//
//  LocationVoteSelection.swift
//  Presentation
//

import Foundation

/// 장소 투표 화면의 로컬 선택/재투표 인터랙션 상태와 전이 규칙.
/// store/TCA 에 의존하지 않으며, 서버 파생값(`myVotedIds`)은 주입받아 단위 테스트가 가능하다.
struct LocationVoteSelection: Equatable {
    private(set) var placeIds: Set<Int> = []
    private(set) var isRevoting = false

    var hasSelection: Bool { !placeIds.isEmpty }

    func contains(_ id: Int) -> Bool {
        placeIds.contains(id)
    }

    /// 서버 `isMyVote` 기준으로 선택 상태를 초기화한다(`onChange` 동기화).
    mutating func sync(myVotedIds: Set<Int>) {
        placeIds = myVotedIds
    }

    mutating func toggle(_ id: Int) {
        if placeIds.contains(id) {
            placeIds.remove(id)
        } else {
            placeIds.insert(id)
        }
    }

    /// 다시 투표하기 진입 시 기존 투표를 선택 상태로 pre-fill 하고 재선택 모드로 전환한다.
    mutating func startRevote(myVotedIds: Set<Int>) {
        placeIds = myVotedIds
        isRevoting = true
    }

    enum SubmitDecision: Equatable {
        case skip
        case submit([Int])
    }

    /// 재투표인데 선택이 이전 투표와 동일하면 API 호출 없이 완료 화면으로 복귀한다.
    mutating func resolveSubmit(myVotedIds: Set<Int>) -> SubmitDecision {
        guard hasSelection else { return .skip }

        if isRevoting && placeIds == myVotedIds {
            isRevoting = false
            return .skip
        }

        isRevoting = false
        return .submit(placeIds.sorted())
    }
}
