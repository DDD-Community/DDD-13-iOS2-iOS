//
//  NearbyPlaceRow.swift
//  HomeFeature
//

import DesignSystem
import Entity
import SwiftUI

// 역근처 장소 리스트 뷰에 들어갈 UI

struct NearbyPlaceRow: View {
    // TODO: data 서버 모델로 변경 필요
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
                        Text("서울 강남구 역삼동")
                            .pretendardCustomFont(textStyle: .bodyMedium)
                            .foregroundStyle(Color.gray700)
                    }
                    HStack(spacing: Spacing.spacing200) {
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .spaciousSeating)
                        PlaceTagChip(tag: .spaciousSeating)

                    }
                }
            }
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
