//
//  TermClause.swift
//  Presentation
//
//  약관 동의 항목 정의. 추후 서버/URL 교체에 대비해 데이터로 관리
//

import Foundation

public struct TermClause: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let body: String
    public let isRequired: Bool

    public init(id: String, title: String, body: String, isRequired: Bool = true) {
        self.id = id
        self.title = title
        self.body = body
        self.isRequired = isRequired
    }

    public var displayTitle: String {
        guard isRequired, !title.hasPrefix("(필수)") else { return "(선택) \(title)" } // 필수 약관인지 확인
        return "(필수) \(title)"
    }
}

public extension TermClause {
    static let allRequired: [TermClause] = [
        TermClause(
            id: "service",
            title: "(필수) 서비스 이용 약관",
            body: "본 약관은 Bangawo 서비스 이용과 관련된 권리와 의무를 정합니다.\n\n[임시 placeholder]\n실제 약관 본문은 추후 교체됩니다."
        ),
        TermClause(
            id: "privacy",
            title: "(필수) 개인정보 수집 및 이용 동의",
            body: "본 약관은 Bangawo가 수집하는 개인정보 항목과 이용 목적을 정합니다.\n\n[임시 placeholder]\n실제 약관 본문은 추후 교체됩니다."
        ),
        TermClause(
            id: "location",
            title: "(필수) 위치정보 수집 이용 동의",
            body: "본 약관은 Bangawo가 출발지 검색을 위해 수집하는 위치 정보를 정합니다.\n\n[임시 placeholder]\n실제 약관 본문은 추후 교체됩니다."
        )
    ]
}
