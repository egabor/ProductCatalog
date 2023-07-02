//
//  ImagePickerMediaSourceType.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation
import UIKit

struct ImagePickerMediaSourceType: Identifiable {

    enum SourceTypeIdentifier: String, Identifiable {

        case photoLibrary
        case camera

        var id: String { rawValue }
    }

    let id: SourceTypeIdentifier
    let sourceType: UIImagePickerController.SourceType
    let displayValueKey: String

    var displayValue: String {
        NSLocalizedString(displayValueKey, comment: "")
    }
}

extension ImagePickerMediaSourceType {

    static let photoLibrary: Self = .init(
        id: .photoLibrary,
        sourceType: .photoLibrary,
        displayValueKey: .imagePickerMediaSourceTypePhotoLibraryTitle
    )

    static let camera: Self = .init(
        id: .camera,
        sourceType: .camera,
        displayValueKey: .imagePickerMediaSourceTypeCameraTitle
    )
}
