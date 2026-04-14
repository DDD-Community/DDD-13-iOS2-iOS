import SwiftUI

enum DemoComponent: String, CaseIterable, Identifiable {
    case kakaoMap = "KakaoMap"

    var id: String { rawValue }
}

struct DesignSystemDemoView: View {
    var body: some View {
        List(DemoComponent.allCases) { component in
            NavigationLink(component.rawValue, value: component)
        }
        .navigationTitle("DesignSystem")
        .navigationDestination(for: DemoComponent.self) { component in
            switch component {
            case .kakaoMap:
                KakaoMapDemoView()
            }
        }
    }
}
