//
//  MapBottomSheet.swift
//  HomeFeature
//

import SwiftUI
import ComposableArchitecture
import DesignSystem


// MARK: - Mode
enum MapBottomSheetMode: Equatable {
    case resizable // 크기 조절 가능 모드
    case fixedMedium // 크기 조절 불가 모드
}

// MARK: - Detent

/// 시트가 멈출 수 있는 높이 단계입니다. associated value로 노출 높이를 주입합니다.
enum MapBottomSheetDetent: Equatable {
    /// 고정 높이(pt)로 노출되는 단계입니다.
    case height(CGFloat)
    /// 화면 전체를 덮는 확장 단계입니다.
    case full
}

extension MapBottomSheetDetent {
    /// 기존 동작과 동일한 기본 프리셋입니다.
    static var collapsed: Self { .height(MapBottomSheetMetric.collapsedHeight) }
    static var medium: Self { .height(MapBottomSheetMetric.mediumHeight) }
    static var large: Self { .full }

    /// 컨테이너 높이 기준 실제 노출 높이입니다.
    /// `.height`는 화면을 넘지 않게 클램프하고, `.full`은 화면 전체를 사용합니다.
    func resolvedHeight(in containerHeight: CGFloat) -> CGFloat {
        switch self {
        case let .height(value): return min(value, containerHeight)
        case .full: return containerHeight
        }
    }

    /// collapsed < medium < large 정렬 비교용 가중치입니다. `.full`을 최댓값으로 둡니다.
    var sortValue: CGFloat {
        switch self {
        case let .height(value): return value
        case .full: return .greatestFiniteMagnitude
        }
    }
}

// MARK: - Metric

private enum MapBottomSheetMetric {
    /// 사용자가 잡고 드래그할 수 있는 핸들 바의 실제 너비입니다.
    static let handleBarWidth: CGFloat = 36
    /// 핸들 바 자체의 높이입니다.
    static let handleBarHeight: CGFloat = 4
    /// 핸들 바 주변 터치 영역 높이입니다. collapsed 상태에서는 이 영역만 노출됩니다.
    static let handleAreaHeight: CGFloat = 38
    /// 접힌 상태에서 화면에 보이는 시트 높이입니다.
    static let collapsedHeight: CGFloat = 76
    /// 중간 detent는 324pt 노출합니다.
    // TODO: 디테일 한 부분은 추후 수정 필요
    static let mediumHeight: CGFloat = 324
    /// 고정 모드에서는 376pt를 노출합니다.
    static let fixedMediumHeight: CGFloat = 376
    /// 드래그 종료 시 다음/이전 detent로 넘어가기 위한 최소 이동 거리입니다.
    static let snapThreshold: CGFloat = 60
}

/// 지도 위에 올라가는 커스텀 바텀시트 컨테이너입니다.
///
/// `MapBottomSheet`는 시트의 높이, 드래그, 배경, 스크롤 영역만 담당합니다.
/// 내부에 들어가는 실제 UI는 `content`로 주입받기 때문에 근처 장소 리스트,
/// 선택된 장소 상세 등 여러 종류의 시트 내용을 같은 컨테이너에 올릴 수 있습니다.
struct MapBottomSheet<Content: View>: View {
    private let mode: MapBottomSheetMode // 모드 설정
    /// 시트가 멈출 수 있는 단계 집합입니다. 화면별로 노출 단계와 높이를 주입합니다.
    private let detents: [MapBottomSheetDetent]
    private let content: () -> Content
    /// 시트가 정착한 detent에서 화면을 덮는 높이가 바뀔 때 전달하는 콜백입니다.
    /// 지도 핀 포커싱 시 시트에 가려지지 않도록 보정량을 계산하는 데 사용합니다.
    private var onVisibleHeightChanged: ((CGFloat) -> Void)?

    /// 현재 시트가 머무는 높이 단계입니다.
    @State private var detent: MapBottomSheetDetent
    /// 드래그 중인 임시 이동 거리입니다. 드래그가 끝나면 detent를 갱신하고 0으로 되돌립니다.
    @State private var dragOffset: CGFloat = 0

    init(
        mode: MapBottomSheetMode = .resizable,
        detents: [MapBottomSheetDetent] = [.collapsed, .medium, .large],
        initialDetent: MapBottomSheetDetent = .collapsed,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.mode = mode
        self.detents = detents
        self.content = content
        self._detent = State(initialValue: initialDetent)
    }

    var body: some View {
        GeometryReader { proxy in
            let largeHeight = proxy.size.height
            let effectiveDetent: MapBottomSheetDetent = mode == .fixedMedium
                ? .height(MapBottomSheetMetric.fixedMediumHeight)
                : detent
            let currentOffset = sheetOffset(for: effectiveDetent, largeHeight: largeHeight)
            let topCornerRadius = effectiveDetent == .full ? 0 : BorderRadius.borderRadius400

            // 시트는 항상 largeHeight 크기로 배치한 뒤 offset으로 아래로 밀어냅니다.
            // 따라서 실제로 화면에 보이는 높이는 largeHeight - currentOffset입니다.
            let visibleHeight = largeHeight - currentOffset
            let contentHeight = max(visibleHeight - MapBottomSheetMetric.handleAreaHeight, 0)

            VStack {
                Spacer(minLength: 0)

                VStack(spacing: 0) {
                    MapBottomSheetHandleBar()
                        .contentShape(Rectangle())
                        .gesture(dragGesture)
                        .onTapGesture {
                            guard mode == .resizable else { return }

                            let sorted = sortedDetents
                            withAnimation(.spring(duration: 0.35)) {
                                detent = detent == sorted.first
                                    ? (sorted.dropFirst().first ?? detent)
                                    : (sorted.first ?? detent)
                            }
                        }

                    // 핸들 아래 영역만 스크롤됩니다.
                    // ScrollView의 높이를 현재 보이는 content 영역에 맞춰야 medium 상태에서도 스크롤이 자연스럽게 동작합니다.
                    ScrollView(.vertical, showsIndicators: false) {
                        content()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 20)
                    }
                    .frame(height: contentHeight, alignment: .top)
                    .scrollDisabled(effectiveDetent == .collapsed)
                }
                .frame(maxWidth: .infinity)
                .frame(height: largeHeight, alignment: .top)
                .background(MapBottomSheetBackground(topCornerRadius: topCornerRadius))
                .clipShape(MapBottomSheetShape(topCornerRadius: topCornerRadius))
                .offset(y: currentOffset)
                .transaction { transaction in
                    // 드래그 중에는 offset이 손가락을 즉시 따라가야 하므로 암시적 애니메이션을 끕니다.
                    if dragOffset != 0 {
                        transaction.animation = nil
                    }
                }
            }
            .onAppear {
                onVisibleHeightChanged?(focusInset(for: effectiveDetent, largeHeight: largeHeight))
            }
            .onChange(of: effectiveDetent) { _, newDetent in
                onVisibleHeightChanged?(focusInset(for: newDetent, largeHeight: largeHeight))
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Modifier

extension MapBottomSheet {
    /// 시트가 화면을 덮는 높이(정착 시점 기준)가 바뀔 때 호출됩니다.
    /// `.height` 단계는 해당 노출 높이를, `.full` 은 0(지도 전체가 가려져 보정 무의미)을 전달합니다.
    func onVisibleHeightChanged(_ handler: @escaping (CGFloat) -> Void) -> MapBottomSheet {
        var copy = self
        copy.onVisibleHeightChanged = handler
        return copy
    }
}

// MARK: - Layout

private extension MapBottomSheet {
    /// large 높이의 시트를 아래로 밀어 현재 detent 높이만큼만 보이게 만드는 offset입니다.
    ///
    /// 예를 들어 medium 상태라면 시트 자체의 frame은 largeHeight지만,
    /// `largeHeight - mediumHeight`만큼 아래로 내려 mediumHeight만 화면에 노출합니다.
    private func sheetOffset(for detent: MapBottomSheetDetent, largeHeight: CGFloat) -> CGFloat {
        let baseHeight = detent.resolvedHeight(in: largeHeight)
        let visibleHeight = min(max(baseHeight - dragOffset, MapBottomSheetMetric.collapsedHeight), largeHeight)
        return largeHeight - visibleHeight
    }

    /// 지도 핀 포커싱 보정에 사용할 "시트가 가리는 높이"를 반환합니다.
    /// `.full` 은 지도 전체가 가려져 보정이 무의미하므로 0을 반환합니다.
    private func focusInset(for detent: MapBottomSheetDetent, largeHeight: CGFloat) -> CGFloat {
        detent == .full ? 0 : detent.resolvedHeight(in: largeHeight)
    }
}

// MARK: - Gesture

private extension MapBottomSheet {
    /// 핸들 영역에서만 동작하는 드래그 제스처입니다.
    ///
    /// global 좌표계를 사용하면 offset으로 움직이는 시트 내부 local 좌표 변화의 영향을 덜 받아
    /// 드래그 중 손가락 이동량을 안정적으로 계산할 수 있습니다.
    var dragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                guard mode == .resizable else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                guard mode == .resizable else { return }

                withAnimation(.spring(duration: 0.35)) {
                    if value.translation.height < -MapBottomSheetMetric.snapThreshold {
                        detent = nextDetent
                    } else if value.translation.height > MapBottomSheetMetric.snapThreshold {
                        detent = previousDetent
                    }
                    dragOffset = 0
                }
            }
    }

    /// 주입된 detent 집합을 노출 높이 오름차순으로 정렬한 목록입니다.
    private var sortedDetents: [MapBottomSheetDetent] {
        detents.sorted { $0.sortValue < $1.sortValue }
    }

    /// 위로 충분히 드래그했을 때 이동할 다음 단계입니다.
    private var nextDetent: MapBottomSheetDetent {
        let sorted = sortedDetents
        guard let index = sorted.firstIndex(of: detent), index + 1 < sorted.count else { return detent }

        return sorted[index + 1]
    }

    /// 아래로 충분히 드래그했을 때 이동할 이전 단계입니다.
    private var previousDetent: MapBottomSheetDetent {
        let sorted = sortedDetents
        guard let index = sorted.firstIndex(of: detent), index > 0 else { return detent }

        return sorted[index - 1]
    }
}

// MARK: - Subviews

private struct MapBottomSheetHandleBar: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: MapBottomSheetMetric.handleBarHeight / 2)
                .fill(Colors.gray300)
                .frame(
                    width: MapBottomSheetMetric.handleBarWidth,
                    height: MapBottomSheetMetric.handleBarHeight
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: MapBottomSheetMetric.handleAreaHeight)
    }
}

private struct MapBottomSheetBackground: View {
    let topCornerRadius: CGFloat

    var body: some View {
        MapBottomSheetShape(topCornerRadius: topCornerRadius)
            .fill(Colors.gray00)
            .shadow(
                color: BoxShadow.boxShadow400.color,
                radius: BoxShadow.boxShadow400.blur,
                x: BoxShadow.boxShadow400.offsetX,
                y: BoxShadow.boxShadow400.offsetY
            )
    }
}

private struct MapBottomSheetShape: Shape {
    let topCornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            topLeadingRadius: topCornerRadius,
            topTrailingRadius: topCornerRadius
        )
        .path(in: rect)
    }
}

/*
나중에 지도 붙이면 이런식으로 사용하면 좋을듯
 MapBottomSheet(
mode: store.selectedPlace == nil ? .resizable : .fixedMedium
) {
if store.selectedPlace == nil {
    NearbyPlaceListSheet(...)
} else {
    SelectedPlaceDetailSheet(...)
}
}
*/

#Preview {
    ZStack(alignment: .bottom) {
        Colors.gray200
            .ignoresSafeArea()

        MapBottomSheet(mode: .fixedMedium) {
            VStack(spacing: Spacing.spacing100) {
                SelectedPlaceDetailSheet(
                    store: Store(initialState: .mock) {
                        SelectedPlaceDetailSheetFeature()
                    }
                )
            }
            .padding(.horizontal, Spacing.spacing300)
        }
    }
}
