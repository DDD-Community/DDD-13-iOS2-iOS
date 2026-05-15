import SwiftUI

enum ComponentDemo: String, CaseIterable, Identifiable {
    case button = "Button"

    var id: String { rawValue }
}

enum MapDemo: String, CaseIterable, Identifiable {
    case kakaoMap = "KakaoMap"

    var id: String { rawValue }
}

struct DesignSystemDemoView: View {
    var body: some View {
        List {
            Section("Components") {
                ForEach(ComponentDemo.allCases) { component in
                    NavigationLink(component.rawValue, value: component)
                }
            }
            Section("Map") {
                ForEach(MapDemo.allCases) { component in
                    NavigationLink(component.rawValue, value: component)
                }
            }
        }
        .navigationTitle("DesignSystem")
        .navigationDestination(for: ComponentDemo.self) { component in
            switch component {
            case .button: BangawoButtonDemoView()
            }
        }
        .navigationDestination(for: MapDemo.self) { component in
            switch component {
            case .kakaoMap: KakaoMapDemoView()
            }
        }
    }
}
