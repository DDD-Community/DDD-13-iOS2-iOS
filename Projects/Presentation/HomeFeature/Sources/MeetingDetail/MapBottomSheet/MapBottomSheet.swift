//
//  MapBottomSheet.swift
//  HomeFeature
//

import SwiftUI
import DesignSystem

private enum MapBottomSheetMetric {
    static let handleBarWidth: CGFloat = 36
    static let handleBarHeight: CGFloat = 4
    static let handleAreaHeight: CGFloat = 44
    static let collapsedHeight: CGFloat = 44
    static let mediumHeightRatio: CGFloat = 0.45
    static let largeHeightRatio: CGFloat = 0.9
    static let snapThreshold: CGFloat = 60
}

struct MapBottomSheet<Content: View>: View {
    // 시트가 멈출 수 있는 세 단계 높이입니다.
    private enum Detent {
        case collapsed // 접혀져 있을 때
        case medium // 중간 높이
        case large // 제일 큰 높이
    }

    private let content: () -> Content

    @State private var detent: Detent = .collapsed
    // 드래그 중인 거리입니다. onEnded에서 detent 변경과 함께 0으로 되돌립니다.
    @State private var dragOffset: CGFloat = 0

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let mediumHeight = proxy.size.height * MapBottomSheetMetric.mediumHeightRatio
            let largeHeight = proxy.size.height * MapBottomSheetMetric.largeHeightRatio
            let currentOffset = sheetOffset(mediumHeight: mediumHeight, largeHeight: largeHeight)

            VStack {
                Spacer(minLength: 0)

                // 실제 높이는 large로 고정하고 offset만 바꿔 드래그 중 레이아웃 흔들림을 줄입니다.
                VStack(spacing: 0) {
                    MapBottomSheetHandleBar()
                        .contentShape(Rectangle())
                        .gesture(dragGesture)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.35)) {
                                detent = detent == .collapsed ? .medium : .collapsed
                            }
                        }


                    content()
                        .padding(.top, Spacing.spacing300)
                        .opacity(contentOpacity)
                }
                .frame(maxWidth: .infinity)
                .frame(height: largeHeight, alignment: .top)
                .background(MapBottomSheetBackground())
                .clipShape(MapBottomSheetShape())
                .offset(y: currentOffset)
                .transaction { transaction in
                    if dragOffset != 0 {
                        transaction.animation = nil
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private extension MapBottomSheet {
    var contentOpacity: Double {
        detent != .collapsed || dragOffset < 0 ? 1 : 0
    }

    // large 높이의 시트를 아래로 밀어 현재 detent 높이만큼만 보이게 합니다.
    func sheetOffset(mediumHeight: CGFloat, largeHeight: CGFloat) -> CGFloat {
        let baseHeight = height(for: detent, mediumHeight: mediumHeight, largeHeight: largeHeight)
        let visibleHeight = min(max(baseHeight - dragOffset, MapBottomSheetMetric.collapsedHeight), largeHeight)
        return largeHeight - visibleHeight
    }

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

    var dragGesture: some Gesture {
        // global 좌표계를 사용해 offset으로 이동 중인 손잡이의 local 좌표 흔들림을 피합니다.
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

    private var nextDetent: Detent {
        switch detent {
        case .collapsed:
            return .medium
        case .medium, .large:
            return .large
        }
    }

    private var previousDetent: Detent {
        switch detent {
        case .collapsed, .medium:
            return .collapsed
        case .large:
            return .medium
        }
    }
}

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
