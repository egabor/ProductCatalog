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
    let displayValue: String
}

extension ImagePickerMediaSourceType {

    static let photoLibrary: Self = .init(
        id: "photoLibrary", // TODO: move to constants
        sourceType: .photoLibrary,
        displayValue: "Photo Library" // TODO: localize
    )

    static let camera: Self = .init(
        id: "camera", // TODO: move to constants
        sourceType: .camera,
        displayValue: "Camera" // TODO: localize
    )
}
