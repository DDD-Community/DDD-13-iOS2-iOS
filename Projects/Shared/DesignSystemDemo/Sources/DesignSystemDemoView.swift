import SwiftUI

private enum ComponentDemo: String, CaseIterable, Identifiable {
    case button = "Button"
    case actionButton = "ActionButton"
    case asset = "Asset"
    case checkbox = "Checkbox"
    case snackBar = "SnackBar"
    case toast = "Toast"
    case top = "Top"
    case text = "Text"

    var id: String { rawValue }
}

private enum MapDemo: String, CaseIterable, Identifiable {
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
            case .actionButton: ActionButtonDemoView()
            case .asset: AssetDemoView()
            case .checkbox: CheckboxDemoView()
            case .snackBar: SnackBarDemoView()
            case .toast: ToastDemoView()
            case .top: TopHeroDemoView()
            case .text: TextDemoView()
            }
        }
        .navigationDestination(for: MapDemo.self) { component in
            switch component {
            case .kakaoMap: KakaoMapDemoView()
            }
        }
    }
}
