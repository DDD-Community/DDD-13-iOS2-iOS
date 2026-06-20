//
//  HomeTab.swift
//  Presentation
//

import SwiftUI

import ComposableArchitecture

import DesignSystem

/// 모임 상세 "홈" 탭.
/// 상단 `TopPage`부터 멤버 리스트(`MemberList`)까지 전체가 세로 스크롤된다.
struct HomeTab: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TopPage(
                    d3Asset: .groupDetail,
                    title: store.group.name,
                    description: store.group.themeTagDisplay,
                    buttonTitle: "약속 정하기",
                    buttonVariant: .solid,
                    buttonSize: .small,
                    showLowerArea: false,
                    buttonAction: { store.send(.decideMeetingTapped) }
                )

                MemberList(store: store)
                    .padding(.horizontal, Spacing.spacing400)
            }
        }
    }
}

// MARK: - Member List

/// 홈 탭의 멤버 리스트 영역.
/// 멤버가 있으면 "나"/"팀원" 카드를, 없으면 친구 초대 버튼을 노출한다.
private struct MemberList: View {
    let store: StoreOf<GroupDetailFeature>

    var body: some View {
        VStack(spacing: Spacing.spacing250) {
            if store.hasMembers {
                // TODO: 카드뷰 디자인 확정 시 실제 멤버 카드로 교체
                PlaceholderMemberCard()
                ForEach(store.group.members) { _ in
                    PlaceholderMemberCard()
                }
            } else {
                InviteFriendButton {
                    store.send(.inviteFriendTapped)
                }
            }
        }
    }
}

// MARK: - Placeholder Member Card

private struct PlaceholderMemberCard: View {
    var body: some View {
        RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
            .fill(
                RadialGradient(
                    colors: [Colors.grayAlpha50, Colors.grayAlpha200],
                    center: .center,
                    startRadius: 0,
                    endRadius: Metric.cardGradientRadius
                )
            )
            .frame(maxWidth: .infinity)
            .frame(height: Metric.cardHeight)
    }
}

// MARK: - Invite Friend Button

private struct InviteFriendButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.spacing250) {
                Image.Asset.icPlus24
                    .resizable()
                    .frame(width: Sizing.sizing200, height: Sizing.sizing200)

                BangawoText("친구 초대하기", textStyle: .bodyLarge)
                    .foregroundStyle(Colors.gray800)
            }
            .padding(Spacing.spacing200)
            .padding(Spacing.spacing200)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .fill(Colors.gray50)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .stroke(Colors.gray200, lineWidth: BorderWidth.borderWidth150)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Constants

private enum Metric {
    static let cardHeight: CGFloat = 88
    static let cardGradientRadius: CGFloat = 160
}
