//
//  PlaceRow.swift
//  HomeFeature
//

import DesignSystem
import Entity
import SwiftUI
import UIKit

/// 장소 리스트에 들어가는 범용 단일 장소 row입니다.
///
/// 장소명/거리/주소/태그/썸네일 본문은 공통이고, 우측(trailing) 요소는 사용처에 따라 주입합니다.
/// 예: 장소보기 탭의 "담기" 버튼, 담은 장소 탭의 "N명" 담은 인원 라벨.
///
/// 현재는 서버 장소 모델이 확정되기 전 단계라 본문 값이 더미로 구성되어 있습니다.
/// 주소 영역을 누르면 도로명/지번 주소를 보여주는 툴팁이 열리고, 툴팁은 row 위계보다 높은 레이어에 표시됩니다.
struct PlaceRow<Trailing: View>: View {
    @State private var isTooltipPresented = false
    @State private var isTooltipLayerElevated = false

    private let placeName: String
    private let category: PlaceCategory?
    private let displayAddress: String
    private let tooltipAnimationDuration = 0.2
    private let trailing: Trailing

    /// 더미 데이터를 사용하는 기본 init. 서버 모델 확정 전 mock 용도.
    init(@ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.init(
            placeName: "이름",
            category: nil,
            displayAddress: "서울 강남구 역삼동",
            trailing: trailing
        )
    }

    /// 장소 row에 필요한 표시 데이터를 직접 전달하는 init.
    init(
        placeName: String,
        category: PlaceCategory?,
        displayAddress: String,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.placeName = placeName
        self.category = category
        self.displayAddress = displayAddress
        self.trailing = trailing()
    }

    /// `RecommendedPlace` 실데이터를 표시하는 init.
    init(place: RecommendedPlace, @ViewBuilder trailing: () -> Trailing = { EmptyView() }) {
        self.init(
            placeName: place.name,
            category: place.categoryLabel,
            displayAddress: place.address,
            trailing: trailing
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: Spacing.spacing300) {
                PlaceThumbnail(category: category)

                VStack(alignment: .leading, spacing: Spacing.spacing200) {
                    Text(placeName)
                        .pretendardCustomFont(textStyle: .bodyLargeEmphasized)
                        .foregroundStyle(Color.gray800)

                    HStack(spacing: Spacing.spacing225) {
                        Text("18km")
                            .pretendardCustomFont(textStyle: .bodyMedium)
                            .foregroundStyle(Color.gray600)

                        Button {
                            toggleTooltip()
                        } label: {
                            HStack(spacing: Spacing.spacing100) {
                                Text(displayAddress)
                                    .pretendardCustomFont(textStyle: .bodyMedium)
                                    .foregroundStyle(Color.gray700)

                                Image(assetName: "ic_arrow_small_down_16")
                                    .renderingMode(.template)
                                    .foregroundStyle(Colors.gray500)
                                    .frame(width: 16, height: 16)
                                    .rotationEffect(.degrees(isTooltipPresented ? 180 : 0))
                                    .animation(.easeInOut(duration: tooltipAnimationDuration), value: isTooltipPresented)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    .zIndex(1)

                    HStack(spacing: Spacing.spacing200) {
                        PlaceTagChip(tag: .reservable)
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .parkingAvailable)
                    }
                    .zIndex(0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .zIndex(1)

                trailing
            }
            .overlay(alignment: .bottomLeading) {
                if isTooltipPresented {
                    PlaceAddressTooltip()
                        .offset(y: Spacing.spacing600)
                        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
                }
            }
        }
        // 툴팁이 열린 row 전체를 형제 row보다 위에 올려, 아래 row 텍스트가 툴팁 위로 노출되지 않게 합니다.
        .zIndex(isTooltipLayerElevated ? 1 : 0)
        .padding(.horizontal, Spacing.spacing400)
        .padding(.vertical, Spacing.spacing300)
    }
}

// MARK: - Tooltip State

private extension PlaceRow {
    /// 주소 툴팁을 열고 닫습니다.
    ///
    /// 닫힐 때 바로 zIndex를 내리면 사라지는 애니메이션이 아래 row 뒤로 묻힐 수 있습니다.
    /// 그래서 표시 상태(`isTooltipPresented`)와 레이어 상태(`isTooltipLayerElevated`)를 분리하고,
    /// 닫힘 애니메이션이 끝난 뒤에만 row 레이어를 원래 위치로 되돌립니다.
    func toggleTooltip() {
        if isTooltipPresented {
            withAnimation(.easeInOut(duration: tooltipAnimationDuration)) {
                isTooltipPresented = false
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + tooltipAnimationDuration) {
                if !isTooltipPresented {
                    isTooltipLayerElevated = false
                }
            }
        } else {
            isTooltipLayerElevated = true
            withAnimation(.easeInOut(duration: tooltipAnimationDuration)) {
                isTooltipPresented = true
            }
        }
    }
}

// MARK: - Address Tooltip

private struct PlaceAddressTooltip: View {
    /// 화면 좌우에서 각각 20pt 떨어진 폭으로 툴팁을 맞춥니다.
    private let horizontalMargin: CGFloat = 20
    private let roadAddress = "서울 강남구 테헤란로 123"
    private let lotAddress = "서울 강남구 역삼동 123-45"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            PlaceAddressRow(title: "도로명", address: roadAddress)
            PlaceAddressRow(title: "지번", address: lotAddress)
        }
        .padding(.horizontal, Spacing.spacing250)
        .padding(.vertical, Spacing.spacing200)
        .frame(width: tooltipWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                .fill(Colors.gray00)
                .shadow(
                    color: BoxShadow.boxShadow200.color,
                    radius: BoxShadow.boxShadow200.blur,
                    x: BoxShadow.boxShadow200.offsetX,
                    y: BoxShadow.boxShadow200.offsetY
                )
        )
    }
}

private extension PlaceAddressTooltip {
    /// `UIScreen.main`은 iOS 26에서 deprecated이므로 현재 연결된 window scene의 screen을 사용합니다.
    var tooltipWidth: CGFloat {
        let screenWidth = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.screen.bounds.width }
            .first ?? 0

        return max(screenWidth - (horizontalMargin * 2), 0)
    }
}

// MARK: - Thumbnail

private struct PlaceThumbnail: View {
    let category: PlaceCategory?

    var body: some View {
        icon
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
    }

    private var icon: Image {
        category?.pinIcon ?? Image.Asset.icPin24
    }
}

// MARK: - Place Tag

/// 장소 특성을 보여주는 작은 태그 칩입니다.
private struct PlaceTagChip: View {
    let tag: PlaceTag

    var body: some View {
        Text("# \(tag.rawValue)")
            .pretendardCustomFont(textStyle: .labelXSmall)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Spacing.spacing150)
            .padding(.vertical, Spacing.spacing100)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius150)
                    .fill(backgroundColor)
            )
    }
}

private extension PlaceTagChip {
    var foregroundColor: Color {
        switch tag {
        case .reservable:
            return Colors.green600
        case .quiet:
            return Colors.gray800
        case .goodMood:
            return Colors.gray800
        case .parkingAvailable:
            return Colors.blue600
        case .spaciousSeating:
            return Colors.gray800
        }
    }

    var backgroundColor: Color {
        switch tag {
        case .reservable:
            return Colors.green100
        case .quiet:
            return Colors.gray100
        case .goodMood:
            return Colors.gray100
        case .parkingAvailable:
            return Colors.blue100
        case .spaciousSeating:
            return Colors.gray100
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        PlaceRow()

        PlaceRow {
            BangawoButton("담기", variant: .weak, size: .xsmall) {}
        }

        PlaceRow {
            Text("3명")
                .pretendardCustomFont(textStyle: .labelSmallEmphasized)
                .foregroundStyle(Colors.gray700)
        }
    }
}
