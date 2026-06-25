//
//  MyAttendanceStatusEditSheetContent.swift
//  HomeFeature
//

import SwiftUI

import DesignSystem
import Entity

struct MyAttendanceStatusEditSheetContent: View {
    let selectedStatus: AttendanceStatus?
    let onSelect: (AttendanceStatus) -> Void

    var body: some View {
        VStack(spacing: Spacing.spacing200) {
            ForEach(Constant.statusOptions, id: \.rawValue) { status in
                AttendanceStatusOptionRow(
                    status: status,
                    isSelected: selectedStatus == status,
                    onTap: { onSelect(status) }
                )
            }
        }
        .padding(.horizontal, Metric.horizontalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private enum Metric {
        static let horizontalPadding: CGFloat = -Spacing.spacing250
    }
}

// MARK: - AttendanceStatusOptionRow

private struct AttendanceStatusOptionRow: View {
    let status: AttendanceStatus
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: Spacing.spacing250) {
                status.icon
                    .resizable()
                    .frame(width: Metric.iconLength, height: Metric.iconLength)
                    .background(
                        Circle()
                            .fill(status.iconBackgroundColor)
                            .frame(width: Metric.iconBackgroundLength, height: Metric.iconBackgroundLength)
                    )
                    .frame(width: Metric.iconBackgroundLength, height: Metric.iconBackgroundLength)

                BangawoText(status.displayLabel, textStyle: .bodyLargeEmphasized)
                    .foregroundStyle(Colors.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)

                checkboxIcon
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: Metric.checkboxLength, height: Metric.checkboxLength)
                    .foregroundStyle(isSelected ? Colors.gray800 : Colors.gray500)
            }
            .padding(Metric.contentPadding)
            .background(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
                    .fill(isSelected ? Colors.grayAlpha100 : Color.clear)
            )
            .contentShape(
                RoundedRectangle(cornerRadius: BorderRadius.borderRadius300)
            )
        }
        .buttonStyle(.plain)
    }

    private enum Metric {
        static let iconLength: CGFloat = 24
        static let iconBackgroundLength: CGFloat = 32
        static let checkboxLength: CGFloat = 24
        static let contentPadding: CGFloat = 16
    }

    private var checkboxIcon: Image {
        isSelected ? Image.Asset.icCheckboxGhostEnabledMd : Image.Asset.icCheckboxGhostDisabledMd
    }
}

private extension AttendanceStatus {
    var icon: Image {
        switch self {
        case .join: return Image.Asset.icDotGreen24
        case .late: return Image.Asset.icDotOrange24
        case .absent: return Image.Asset.icDotRed24
        case .unknown: return Image.Asset.icDotGray16
        }
    }

    var iconBackgroundColor: Color {
        switch self {
        case .join: return Colors.green200
        case .late: return Colors.orange200
        case .absent: return Colors.red200
        case .unknown: return Colors.gray200
        }
    }
}

// MARK: - Constant

private enum Constant {
    static let statusOptions: [AttendanceStatus] = [.join, .absent, .late]
}
