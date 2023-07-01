//
//  ImagePickerMediaSourceType.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation
import UIKit

struct ImagePickerMediaSourceType: Identifiable {

    let id: String
    let sourceType: UIImagePickerController.SourceType
    let displayValueKey: String

    var displayValue: String {
        NSLocalizedString(displayValueKey, comment: "")
    }
}

extension ImagePickerMediaSourceType {

    static let photoLibrary: Self = .init(
        id: "photoLibrary", // TODO: move to constants
        sourceType: .photoLibrary,
        displayValueKey: .imagePickerMediaSourceTypePhotoLibraryTitle
    )

    static let camera: Self = .init(
        id: "camera", // TODO: move to constants
        sourceType: .camera,
        displayValueKey: .imagePickerMediaSourceTypeCameraTitle
    )
}
