//
//  NearbyPlaceRow.swift
//  HomeFeature
//

import DesignSystem
import Entity
import SwiftUI
import UIKit

// 역근처 장소 리스트 뷰에 들어갈 UI

struct NearbyPlaceRow: View {
    // TODO: data 서버 모델로 변경 필요
    @State private var isTooltipPresented = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: Spacing.spacing300) {
                NearbyPlaceThumbnail()
                VStack(alignment: .leading, spacing: Spacing.spacing200) {
                    Text("이름")
                    HStack(spacing: Spacing.spacing225) {
                        Text("18km")
                            .pretendardCustomFont(textStyle: .bodyMedium)
                            .foregroundStyle(Color.gray600)
                        HStack(spacing: Spacing.spacing100) {
                            Text("서울 강남구 역삼동")
                                .pretendardCustomFont(textStyle: .bodyMedium)
                                .foregroundStyle(Color.gray700)

                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isTooltipPresented.toggle()
                                }
                            } label: {
                                Image(assetName: "ic_arrow_small_down_16")
                                    .renderingMode(.template)
                                    .foregroundStyle(Colors.gray500)
                                    .frame(width: 16, height: 16)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("주소 안내 보기")
                        }
                        .overlay(alignment: .bottomLeading) {
                            if isTooltipPresented {
                                NearbyPlaceAddressTooltip()
                                    .offset(y: 32)
                                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                            }
                        }
                        .zIndex(1)
                    }
                    .zIndex(1)

                    HStack(spacing: Spacing.spacing200) {
                        PlaceTagChip(tag: .reservable)
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .parkingAvailable)

                    }
                    .zIndex(0)
                }
            }
        }
    }
}

private struct NearbyPlaceAddressTooltip: View {
    private let roadAddress = "서울 강남구 테헤란로 123"
    private let lotAddress = "서울 강남구 역삼동 123-45"

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.spacing200) {
            addressTooltipRow(title: "도로명", address: roadAddress)
            addressTooltipRow(title: "지번", address: lotAddress)
        }
        .padding(.horizontal, Spacing.spacing250)
        .padding(.vertical, Spacing.spacing200)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.borderRadius200)
                .fill(Colors.gray100)
        )
    }
}

private extension NearbyPlaceAddressTooltip {
    func addressTooltipRow(title: String, address: String) -> some View {
        HStack(spacing: Spacing.spacing150) {
            Text(title)
                .pretendardCustomFont(textStyle: .labelSmallEmphasized)
                .foregroundStyle(Colors.gray800)

            Text(address)
                .pretendardCustomFont(textStyle: .labelSmall)
                .foregroundStyle(Colors.gray700)

            Button {
                UIPasteboard.general.string = address
            } label: {
                HStack(spacing: Spacing.spacing50) {
                    Image(assetName: "ic_copy_16")
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                }
                .foregroundStyle(Colors.gray600)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(title) 주소 복사")
        }
    }
}

private struct NearbyPlaceThumbnail: View {
    private let imageURL = URL(string: "https://picsum.photos/seed/bangawo-place/160")

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .empty, .failure:
                Circle()
                    .fill(Colors.gray100)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(Colors.gray500)
                    )
            @unknown default:
                Circle()
                    .fill(Colors.gray100)
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
    }
}

/// 장소 태그 칩 UI
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
    NearbyPlaceRow()
}
