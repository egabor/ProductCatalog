//
//  ProductDetailsViewModel.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import Resolver
import VisionKit
import Combine

struct ImagePickerMediaSourceType: Identifiable {

    let id: String
    let sourceType: UIImagePickerController.SourceType
    let displayValue: String
}

extension ImagePickerMediaSourceType {

    static let photoLibrary: Self = .init(
        id: "photoLibrary",
        sourceType: .photoLibrary,
        displayValue: "Photo Library"
    )

    static let camera: Self = .init(
        id: "camera",
        sourceType: .camera,
        displayValue: "Camera"
    )
}

class ProductDetailsViewModel: ObservableObject {

    enum ExportWarning: Error {

        case emptyName
    }

    var productId: Int?
    var mediaSourceTypes: [ImagePickerMediaSourceType] = [.photoLibrary, .camera]
    @Published var imagePickerMediaSource: ImagePickerMediaSourceType?
    @Published var productImage: UIImage?

    @Published var name: String = ""
    @Published var barcode: String = ""
    @Published var category: ProductCategory?
    var categories: [ProductCategory] = ProductCategory.allCases

    var warningMessage: String = ""
    @Published var shouldShowWarningAlert: Bool = false

    @Published var shouldShowBarcodeScanner: Bool = false
    @Published var recognizedVisionItems: [RecognizedItem] = []

    @Injected private var productService: ProductService

    init(product: Product? = nil) {
        if let product = product {
            importData(product)
        }

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        $recognizedVisionItems
            .compactMap { items in
                items.compactMap { item in
                    switch item {
                        case .barcode(let barcode):
                            return barcode.payloadStringValue ?? ""
                        default:
                            return nil
                    }
                }
            }
            .compactMap { $0.first }
            .assign(to: &$barcode)
    }

    private func validateForWarnings() throws {
        guard name.isEmpty == false else { throw ExportWarning.emptyName }
    }

    func showBarcodeScanner() {
        shouldShowBarcodeScanner = true
    }

    func hideBarcodeScanner() {
        shouldShowBarcodeScanner = false
    }

    func selectImage(for sourceType: ImagePickerMediaSourceType) {
        imagePickerMediaSource = sourceType
    }

    func didSelectImage(_ image: UIImage?) {
        imagePickerMediaSource = nil
        productImage = image
    }
}

extension ProductDetailsViewModel {

    // MARK: - Import

    private func importData(_ product: Product) {

        productId = product.productId
        if let imageData = product.imageData {
            productImage = UIImage(data: imageData)
        } else {
            productImage = nil
        }
        name = product.name ?? ""
        category = product.category
    }

    // MARK: - Export

    private func export(skipWarnings: Bool = false) throws -> Product {

        if skipWarnings == false {
            try validateForWarnings()
        }
        return .init(
            productId: productId,
            imageData: productImage?.jpegData(compressionQuality: 0.6),
            name: name,
            barcode: barcode,
            category: category
        )
    }

    func performExport() {

        do {
            let productToSave = try export() // collect the data from the form
            let savedProduct = try productService.save(product: productToSave) // save and load back the Product from the DB
            importData(savedProduct)
        } catch let error as ExportWarning {
            print("\(error)")
            warningMessage = error.localizedDescription
            shouldShowWarningAlert = true
        } catch {
            print("\(error)")
        }
    }

    func performExportAnyway() {

        do {
            let productToSave = try export(skipWarnings: true)
            guard let savedProduct = try? productService.save(product: productToSave) else { return }
            importData(savedProduct)
        } catch let error as ExportWarning {
            print("\(error)")
        } catch {
            print("\(error)")
        }
    }
}

// MARK: - Localized Strings

extension ProductDetailsViewModel {

    var localizedTitle: String {
        guard productId != nil else { return "New Product" } // TODO: Localize
        return "Edit Product" // TODO: Localize
    }

    var localizedSaveButtonTitle: String {
        "Save" // TODO: Localize
    }

    var localizedWarningAlertTitle: String {
        "Warning" // TODO: Localize
    }

    var localizedWarningAlertDismissButtonTitle: String {
        "Dismiss" // TODO: Localize
    }

    var localizedWarningAlertSaveAnywayButtonTitle: String {
        "Save anyway" // TODO: Localize
    }
}
