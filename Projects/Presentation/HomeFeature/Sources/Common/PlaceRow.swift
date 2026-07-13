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
/// 특정 장소 모델에 종속되지 않도록, 표시에 필요한 데이터는 전부 init에서 입력받습니다.
/// 도로명/지번 주소가 주어지면 주소 영역을 눌러 툴팁을 열 수 있고, 툴팁은 row 위계보다 높은 레이어에 표시됩니다.
struct PlaceRow<Trailing: View>: View {
    @State private var isTooltipPresented = false
    @State private var isTooltipLayerElevated = false

    private let placeName: String
    private let category: PlaceCategory?
    private let displayAddress: String
    private let reservable: Bool
    private let parkingAvailable: Bool
    private let vibes: [String]
    private let roadAddress: String?
    private let lotAddress: String?
    private let distance: String?
    private let tooltipAnimationDuration = 0.2
    private let trailing: Trailing
    /// row 전체 영역 탭 핸들러. `nil`이면 row 자체는 탭에 반응하지 않는다.
    private let onTap: (() -> Void)?

    /// 장소 row에 필요한 표시 데이터를 직접 전달하는 단일 init.
    init(
        placeName: String,
        category: PlaceCategory?,
        displayAddress: String,
        reservable: Bool = false,
        parkingAvailable: Bool = false,
        vibes: [String] = [],
        roadAddress: String?,
        lotAddress: String?,
        distance: String?,
        onTap: (() -> Void)? = nil,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.placeName = placeName
        self.category = category
        self.displayAddress = displayAddress
        self.reservable = reservable
        self.parkingAvailable = parkingAvailable
        self.vibes = vibes
        self.roadAddress = roadAddress
        self.lotAddress = lotAddress
        self.distance = distance
        self.onTap = onTap
        self.trailing = trailing()
    }

    /// 도로명/지번 주소 중 하나라도 있으면 주소를 눌러 툴팁을 열 수 있습니다.
    private var hasAddressTooltip: Bool {
        roadAddress != nil || lotAddress != nil
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
                        if let distance {
                            Text(distance)
                                .pretendardCustomFont(textStyle: .bodyMedium)
                                .foregroundStyle(Color.gray600)
                        }

                        PlaceAddressLabel(
                            displayAddress: displayAddress,
                            hasTooltip: hasAddressTooltip,
                            isTooltipPresented: isTooltipPresented,
                            animationDuration: tooltipAnimationDuration,
                            onTap: { toggleTooltip() }
                        )
                    }
                    .zIndex(1)

                    PlaceTagList(
                        reservable: reservable,
                        parkingAvailable: parkingAvailable,
                        vibes: vibes
                    )
                    .zIndex(0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .zIndex(1)

                trailing
            }
            .overlay(alignment: .bottomLeading) {
                if hasAddressTooltip, isTooltipPresented {
                    PlaceAddressTooltip(roadAddress: roadAddress, lotAddress: lotAddress)
                        .offset(y: Spacing.spacing600)
                        .transition(.opacity.combined(with: .scale(scale: 0.96, anchor: .top)))
                }
            }
        }
        // 툴팁이 열린 row 전체를 형제 row보다 위에 올려, 아래 row 텍스트가 툴팁 위로 노출되지 않게 합니다.
        .zIndex(isTooltipLayerElevated ? 1 : 0)
        .padding(.horizontal, Spacing.spacing400)
        .padding(.vertical, Spacing.spacing300)
        // 내부 주소/trailing 버튼은 innermost 우선 디스패치로 유지되고, 빈 영역 탭만 onTap으로 전달됩니다.
        .contentShape(Rectangle())
        .modifier(RowTapModifier(onTap: onTap))
    }
}

// MARK: - Address Label

/// 도로명/지번 주소가 있으면 툴팁을 여는 버튼, 없으면 평문 주소로 표시합니다.
private struct PlaceAddressLabel: View {
    let displayAddress: String
    let hasTooltip: Bool
    let isTooltipPresented: Bool
    let animationDuration: Double
    let onTap: () -> Void

    var body: some View {
        if hasTooltip {
            Button {
                onTap()
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
                        .animation(.easeInOut(duration: animationDuration), value: isTooltipPresented)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        } else {
            Text(displayAddress)
                .pretendardCustomFont(textStyle: .bodyMedium)
                .foregroundStyle(Color.gray700)
        }
    }
}

// MARK: - Row Tap

/// `onTap`이 있을 때만 전체 row 탭 제스처를 붙입니다. `nil`이면 제스처를 달지 않아 기존 동작을 보존합니다.
private struct RowTapModifier: ViewModifier {
    let onTap: (() -> Void)?

    func body(content: Content) -> some View {
        if let onTap {
            content.onTapGesture { onTap() }
        } else {
            content
        }
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
    let roadAddress: String?
    let lotAddress: String?

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            if let roadAddress {
                PlaceAddressRow(title: "도로명", address: roadAddress)
            }

            if let lotAddress {
                PlaceAddressRow(title: "지번", address: lotAddress)
            }
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

/// 편의정보/분위기 태그를 가로 스크롤로 모두 보여주는 리스트입니다.
private struct PlaceTagList: View {
    let reservable: Bool
    let parkingAvailable: Bool
    let vibes: [String]

    var body: some View {
        if !chips.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.spacing200) {
                    ForEach(chips) { chip in
                        PlaceTagChip(item: chip)
                    }
                }
            }
        }
    }
}

private extension PlaceTagList {
    /// 편의정보(예약/주차)를 앞에, 서버 vibe 형용사를 뒤에 붙인 표시용 칩 목록.
    var chips: [PlaceTagChipItem] {
        var result: [PlaceTagChipItem] = []

        if reservable {
            result.append(PlaceTagChipItem(style: .reservable, label: "예약가능"))
        }

        if parkingAvailable {
            result.append(PlaceTagChipItem(style: .parkingAvailable, label: "주차가능"))
        }

        result.append(contentsOf: vibes.map { PlaceTagChipItem(style: .vibe, label: $0) })

        return result
    }
}

/// 표시할 태그 칩 하나의 데이터. 색상은 `style`, 텍스트는 `label`로 결정합니다.
private struct PlaceTagChipItem: Identifiable {
    enum Style {
        case reservable
        case parkingAvailable
        case vibe
    }

    let id = UUID()
    let style: Style
    let label: String
}

/// 장소 특성을 보여주는 작은 태그 칩입니다.
private struct PlaceTagChip: View {
    let item: PlaceTagChipItem

    var body: some View {
        Text("# \(item.label)")
            .pretendardCustomFont(textStyle: .labelXSmall)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, Spacing.spacing150)
            .padding(.vertical, Spacing.spacing100)
            .background(
                Capsule()
                    .fill(backgroundColor)
            )
    }
}

private extension PlaceTagChip {
    var foregroundColor: Color {
        switch item.style {
        case .reservable:
            return Colors.green600
        case .parkingAvailable:
            return Colors.blue600
        case .vibe:
            return Colors.gray800
        }
    }

    var backgroundColor: Color {
        switch item.style {
        case .reservable:
            return Colors.green100
        case .parkingAvailable:
            return Colors.blue100
        case .vibe:
            return Colors.gray100
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        PlaceRow(
            placeName: "이름",
            category: nil,
            displayAddress: "서울 강남구 테헤란로 123",
            reservable: true,
            parkingAvailable: true,
            vibes: ["아늑한", "조용한"],
            roadAddress: "서울 강남구 테헤란로 123",
            lotAddress: "서울 강남구 역삼동 123-45",
            distance: "18km"
        )

        PlaceRow(
            placeName: "감성카페",
            category: .cafe,
            displayAddress: "서울 강남구 도산대로 1",
            reservable: true,
            roadAddress: nil,
            lotAddress: nil,
            distance: nil
        ) {
            BangawoButton("담기", variant: .weak, size: .xsmall) {}
        }

        PlaceRow(
            placeName: "남산다이닝",
            category: .koreaFood,
            displayAddress: "서울 용산구 소월로 322",
            roadAddress: nil,
            lotAddress: nil,
            distance: nil
        ) {
            Text("3명")
                .pretendardCustomFont(textStyle: .labelSmallEmphasized)
                .foregroundStyle(Colors.gray700)
        }
    }
}
