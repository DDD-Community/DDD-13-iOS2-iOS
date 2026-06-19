//
//  GroupFilter.swift
//  Entity
//

public enum GroupFilter: String, CaseIterable, Equatable, Sendable {
    case all = "전체"
    case inProgress = "진행중"
    case confirmed = "확정"
    case ended = "종료"
}
