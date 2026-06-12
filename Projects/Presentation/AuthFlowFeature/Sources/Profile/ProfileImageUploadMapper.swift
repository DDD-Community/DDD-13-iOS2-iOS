//
//  ProfileImageUploadMapper.swift
//  AuthFlowFeature
//

import Entity
import Foundation
import DesignSystem
import UIKit
// 이미지를 바이너리 데이터로 매핑 해주는 클래스
enum ProfileImageUploadMapper {
    static func makeUploadableImage(from profileImage: ProfileImage) throws -> UploadableImage? {
        switch profileImage {
        case .none:
            return nil

        case let .data(data): // 앨범에서 선택
            return try makeJPEGUploadableImage(from: data)

        case let .preset(preset): // 프리셋 이미지 선택
            return try makePresetUploadableImage(preset)
        }
    }

    private static func makeJPEGUploadableImage(from data: Data) throws -> UploadableImage {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.8)
        else {
            throw ProfileImageUploadMapperError.invalidImageData
        }

        return UploadableImage(
            data: jpegData,
            contentType: "image/jpeg"
        )
    }

    private static func makePresetUploadableImage(_ index: Int) throws -> UploadableImage {
          let preset = try profilePreset(for: index)

          guard let image = UIImage(assetName: preset.assetName),
                let jpegData = image.jpegData(compressionQuality: 0.8)
          else {
              throw ProfileImageUploadMapperError.invalidPresetImage
          }

          return UploadableImage(
              data: jpegData,
              contentType: "image/jpeg"
          )
      }

      private static func profilePreset(for index: Int) throws -> ProfilePreset {
          let presets = ProfilePreset.allCases

          guard presets.indices.contains(index) else {
              throw ProfileImageUploadMapperError.invalidPresetIndex
          }

          return presets[index]
      }
}

enum ProfileImageUploadMapperError: Error {
    case invalidImageData
    case invalidPresetImage
    case invalidPresetIndex
}
