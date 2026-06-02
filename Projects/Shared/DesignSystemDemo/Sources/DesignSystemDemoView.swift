import SwiftUI

private enum ComponentDemo: String, CaseIterable, Identifiable {
    case button = "Button"
    case textButton = "TextButton"
    case actionButton = "ActionButton"
    case asset = "Asset"
    case avatar = "Avatar"
    case bottomSheet = "BottomSheet"
    case checkbox = "Checkbox"
    case fab = "FAB"
    case menu = "Menu"
    case navigation = "Navigation"
    case snackBar = "SnackBar"
    case tab = "Tab"
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
            case .textButton: TextButtonDemoView()
            case .actionButton: ActionButtonDemoView()
            case .asset: AssetDemoView()
            case .avatar: AvatarDemoView()
            case .bottomSheet: BottomSheetDemoView()
            case .checkbox: CheckboxDemoView()
            case .fab: FABDemoView()
            case .menu: MenuDemoView()
            case .navigation: NavigationDemoView()
            case .snackBar: SnackBarDemoView()
            case .tab: TabDemoView()
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
