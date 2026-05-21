//
//  View+StationSearchSheet.swift
//  Presentation
//

import SwiftUI
import ComposableArchitecture

public extension View {
    func stationSearchSheet(
        item: Binding<Store<StationSearchSheetFeature.State, StationSearchSheetFeature.Action>?>
    ) -> some View {
        fullScreenCover(item: item) { sheetStore in
            StationSearchSheet(store: sheetStore)
        }
    }
}
