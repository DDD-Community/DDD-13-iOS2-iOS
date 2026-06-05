//
//  MapBottomSheet.swift
//  HomeFeature
//

import SwiftUI
import DesignSystem

// MARK: - Metric

private enum MapBottomSheetMetric {
    /// 사용자가 잡고 드래그할 수 있는 핸들 바의 실제 너비입니다.
    static let handleBarWidth: CGFloat = 36
    /// 핸들 바 자체의 높이입니다.
    static let handleBarHeight: CGFloat = 4
    /// 핸들 바 주변 터치 영역 높이입니다. collapsed 상태에서는 이 영역만 노출됩니다.
    static let handleAreaHeight: CGFloat = 44
    /// 접힌 상태에서 화면에 보이는 시트 높이입니다.
    static let collapsedHeight: CGFloat = 44
    /// 중간 detent는 전체 화면 높이의 45%를 노출합니다.
    // TODO: 디테일 한 부분은 추후 수정 필요
    static let mediumHeightRatio: CGFloat = 0.45
    /// 큰 detent는 전체 화면 높이의 90%를 노출합니다.
    static let largeHeightRatio: CGFloat = 0.9
    /// 드래그 종료 시 다음/이전 detent로 넘어가기 위한 최소 이동 거리입니다.
    static let snapThreshold: CGFloat = 60
}

/// 지도 위에 올라가는 커스텀 바텀시트 컨테이너입니다.
///
/// `MapBottomSheet`는 시트의 높이, 드래그, 배경, 스크롤 영역만 담당합니다.
/// 내부에 들어가는 실제 UI는 `content`로 주입받기 때문에 근처 장소 리스트,
/// 선택된 장소 상세 등 여러 종류의 시트 내용을 같은 컨테이너에 올릴 수 있습니다.
struct MapBottomSheet<Content: View>: View {
    /// 시트가 멈출 수 있는 세 단계입니다.
    private enum Detent {
        /// 핸들 영역만 보이는 접힌 상태입니다.
        case collapsed
        /// 화면의 일부를 덮는 기본 정보 표시 상태입니다.
        case medium
        /// 대부분의 화면을 덮는 확장 상태입니다.
        case large
    }

    private let content: () -> Content

    /// 현재 시트가 머무는 높이 단계입니다.
    @State private var detent: Detent = .collapsed
    /// 드래그 중인 임시 이동 거리입니다. 드래그가 끝나면 detent를 갱신하고 0으로 되돌립니다.
    @State private var dragOffset: CGFloat = 0

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let mediumHeight = proxy.size.height * MapBottomSheetMetric.mediumHeightRatio
            let largeHeight = proxy.size.height * MapBottomSheetMetric.largeHeightRatio
            let currentOffset = sheetOffset(mediumHeight: mediumHeight, largeHeight: largeHeight)

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
                            withAnimation(.spring(duration: 0.35)) {
                                detent = detent == .collapsed ? .medium : .collapsed
                            }
                        }

                    // 핸들 아래 영역만 스크롤됩니다.
                    // ScrollView의 높이를 현재 보이는 content 영역에 맞춰야 medium 상태에서도 스크롤이 자연스럽게 동작합니다.
                    ScrollView(.vertical, showsIndicators: false) {
                        content()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, Spacing.spacing300)
                            .padding(.bottom, 20)
                    }
                    .frame(height: contentHeight, alignment: .top)
                    .scrollDisabled(detent == .collapsed)
                    .opacity(contentOpacity)
                }
                .frame(maxWidth: .infinity)
                .frame(height: largeHeight, alignment: .top)
                .background(MapBottomSheetBackground())
                .clipShape(MapBottomSheetShape())
                .offset(y: currentOffset)
                .transaction { transaction in
                    // 드래그 중에는 offset이 손가락을 즉시 따라가야 하므로 암시적 애니메이션을 끕니다.
                    if dragOffset != 0 {
                        transaction.animation = nil
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Layout

private extension MapBottomSheet {
    /// collapsed 상태에서는 content가 보이지 않게 숨깁니다.
    /// 사용자가 위로 드래그하기 시작하면 다음 detent로 확정되기 전에도 content가 자연스럽게 나타납니다.
    var contentOpacity: Double {
        detent != .collapsed || dragOffset < 0 ? 1 : 0
    }

    /// large 높이의 시트를 아래로 밀어 현재 detent 높이만큼만 보이게 만드는 offset입니다.
    ///
    /// 예를 들어 medium 상태라면 시트 자체의 frame은 largeHeight지만,
    /// `largeHeight - mediumHeight`만큼 아래로 내려 mediumHeight만 화면에 노출합니다.
    func sheetOffset(mediumHeight: CGFloat, largeHeight: CGFloat) -> CGFloat {
        let baseHeight = height(for: detent, mediumHeight: mediumHeight, largeHeight: largeHeight)
        let visibleHeight = min(max(baseHeight - dragOffset, MapBottomSheetMetric.collapsedHeight), largeHeight)
        return largeHeight - visibleHeight
    }

    /// detent별 목표 노출 높이를 반환합니다.
    private func height(for detent: Detent, mediumHeight: CGFloat, largeHeight: CGFloat) -> CGFloat {
        switch detent {
        case .collapsed:
            return MapBottomSheetMetric.collapsedHeight
        case .medium:
            return mediumHeight
        case .large:
            return largeHeight
        }
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
                dragOffset = value.translation.height
            }
            .onEnded { value in
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

    /// 위로 충분히 드래그했을 때 이동할 다음 단계입니다.
    private var nextDetent: Detent {
        switch detent {
        case .collapsed:
            return .medium
        case .medium, .large:
            return .large
        }
    }

    /// 아래로 충분히 드래그했을 때 이동할 이전 단계입니다.
    private var previousDetent: Detent {
        switch detent {
        case .collapsed, .medium:
            return .collapsed
        case .large:
            return .medium
        }
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
    var body: some View {
        MapBottomSheetShape()
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
    func path(in rect: CGRect) -> Path {
        UnevenRoundedRectangle(
            topLeadingRadius: BorderRadius.borderRadius400,
            topTrailingRadius: BorderRadius.borderRadius400
        )
        .path(in: rect)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Colors.gray200
            .ignoresSafeArea()

        MapBottomSheet {
            VStack(spacing: Spacing.spacing200) {
                NearbyPlaceRow()
            }
            .padding(.horizontal, Spacing.spacing300)
        }
    }
}
