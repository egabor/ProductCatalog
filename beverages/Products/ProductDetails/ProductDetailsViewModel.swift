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

class ProductDetailsViewModel: ObservableObject {

    enum ExportError: Error { // TODO: localize errors

        case emptyCategory
        case emptyImage
        case emptyName
    }

    enum ExportWarning: Error { // TODO: localize warning

        case emptyBarcode
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

    var errorMessage: String = ""
    @Published var shouldShowErrorAlert: Bool = false

    var successMessage: String = ""
    @Published var shouldShowSuccessAlert: Bool = false

    @Published var shouldShowBarcodeScanner: Bool = false
    @Published var recognizedVisionItems: [RecognizedItem] = []
    @Published var isEditing: Bool = false

    @Injected private var productService: ProductService

    init(product: Product? = nil) {
        if let product = product {
            importData(product)
        } else {
            isEditing = true
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

    private func validateForErrors() throws {

        if productImage == nil { throw ExportError.emptyImage }
        if name.isEmpty { throw ExportError.emptyName }
        if category == nil { throw ExportError.emptyCategory }
    }

    private func validateForWarnings() throws {
        guard barcode.isEmpty == false else { throw ExportWarning.emptyBarcode }
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

    func showSuccessAlert(with message: String) {

        successMessage = message
        shouldShowSuccessAlert = true
    }

    func editProduct() {
        isEditing = true
    }
}

extension ProductDetailsViewModel {

    // MARK: - Import

    private func importData(_ product: Product) {

        productId = product.productId
        productImage = product.image
        name = product.name
        barcode = product.barcode ?? ""
        category = product.category
    }

    // MARK: - Export

    private func export(skipWarnings: Bool = false) throws -> Product {

        try validateForErrors()

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

    private func save(skipWarnings: Bool = false) throws {
        let productToSave = try export(skipWarnings: true) // collect the data from the form
        guard let savedProduct = try? productService.save(product: productToSave) else { return } // save and load back the Product from the DB
        importData(savedProduct)
        showSuccessAlert(with: localizedSaveSuccessAlertMessage)
        isEditing = false
    }

    func performExport() {

        do {
            try save(skipWarnings: false)
        } catch let warning as ExportWarning {
            handle(warning)
        } catch let error as ExportError {
            handle(error)
        } catch {
            handle(error)
        }
    }

    func performExportAnyway() {

        do {
            try save(skipWarnings: true)
        } catch _ as ExportWarning {
            // Nothing to handle here. Warning ignored by the user.
        } catch let error as ExportError {
            handle(error)
        } catch {
            handle(error)
        }
    }
}

// MARK: - Exception Handlers

extension ProductDetailsViewModel {

    private func handle(_ warning: ExportWarning) {

        print("\(warning)")
        warningMessage = warning.localizedDescription
        shouldShowWarningAlert = true
    }

    private func handle(_ error: ExportError) {

        print("\(error)")
        errorMessage = error.localizedDescription
        shouldShowErrorAlert = true
    }

    private func handle(_ error: Error) {
        print("Unhandled error: \(error)")
    }
}

// MARK: - Localized Strings

extension ProductDetailsViewModel {

    var localizedTitle: String {
        guard productId != nil else { return "New Product" } // TODO: Localize
        guard isEditing else { return "Product Details" } // TODO: Localize
        return "Edit Product" // TODO: Localize
    }

    var localizedEditButtonTitle: String {
        "Edit" // TODO: Localize
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

    var localizedErrorAlertTitle: String {
        "Error" // TODO: Localize
    }

    var localizedErrorAlertDismissButtonTitle: String {
        "Dismiss" // TODO: Localize
    }

    var localizedSuccessAlertTitle: String {
        "Success" // TODO: Localize
    }

    var localizedSaveSuccessAlertMessage: String {
        "Product saved." // TODO: Localize
    }

    var localizedSuccessAlertDismissButtonTitle: String {
        "Dismiss" // TODO: Localize
    }
}
