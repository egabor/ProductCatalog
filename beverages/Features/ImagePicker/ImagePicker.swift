//
//  ImagePicker.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var isPresented
    var sourceType: UIImagePickerController.SourceType
    var didSelectImage: ((UIImage?) -> Void)

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
#if targetEnvironment(simulator)
        imagePicker.sourceType = .photoLibrary
#else
        imagePicker.sourceType = self.sourceType
#endif
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(didSelectImage: didSelectImage)
    }
}

extension ImagePicker {

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

        var didSelectImage: ((UIImage?) -> Void)

        init(didSelectImage: @escaping ((UIImage?) -> Void)) {
            self.didSelectImage = didSelectImage
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {

                guard let image = info[.originalImage] as? UIImage else { print("error while returning the image") ; return }
                didSelectImage(image)
        }
    }
}
