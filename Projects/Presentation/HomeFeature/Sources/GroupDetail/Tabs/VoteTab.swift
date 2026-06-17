//
//  VoteTab.swift
//  Presentation
//

import SwiftUI

import DesignSystem

/// 모임 상세 "투표" 탭.
// TODO: 투표 기능 구현 시 실제 화면으로 교체
struct VoteTab: View {
    var body: some View {
        BangawoText("투표 (임시)", textStyle: .bodyMedium)
            .foregroundStyle(Colors.gray600)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
