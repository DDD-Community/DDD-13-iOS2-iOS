//
//  MyDeparturePlaceEditSheetContent.swift
//  HomeFeature
//

import SwiftUI

import ComposableArchitecture
import DesignSystem

struct MyDeparturePlaceEditSheetContent: View {
    let store: StoreOf<HomeTabFeature>
    
    var body: some View{
        VStack(spacing: 0) {
            HStack(spacing: Spacing.spacing200) {
                BangawoText("출발지 입력", textStyle: .titleLarge)
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
