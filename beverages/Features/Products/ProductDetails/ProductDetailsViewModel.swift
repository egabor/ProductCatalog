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

    var didScanBarcode: PassthroughSubject<Void, Never> = .init()

    @Injected private var productService: ProductService

    private var cancellables = Set<AnyCancellable>()

    init(product: Product? = nil) {
        if let product = product {
            importData(product)
        } else {
            isEditing = true
        }

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        let scannedBarcode = $recognizedVisionItems
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

        scannedBarcode
            .assign(to: &$barcode)

        scannedBarcode
            .sink(receiveValue: { [weak self] _ in
                self?.didScanBarcode.send(())
            })
            .store(in: &cancellables)
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
            name: name.trimmed,
            barcode: barcode,
            category: category
        )
    }

    private func save(skipWarnings: Bool = false) throws {
        let productToSave = try export(skipWarnings: skipWarnings) // collect the data from the form
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
        guard productId != nil else { return .productDetailsScreenCreateTitle }
        guard isEditing else { return .productDetailsScreenTitle }
        return .productDetailsScreenEditTitle
    }

    var localizedEditButtonTitle: String {
        .productDetailsScreenEditButtonTitle
    }

    var localizedSaveButtonTitle: String {
        .productDetailsScreenSaveButtonTitle
    }

    var localizedWarningAlertTitle: String {
        .productDetailsScreenAlertWarningTitle
    }

    var localizedWarningAlertDismissButtonTitle: String {
        .productDetailsScreenAlertWarningDismissButtonTitle
    }

    var localizedWarningAlertSaveAnywayButtonTitle: String {
        .productDetailsScreenAlertWarningSaveAnywayButtonTitle
    }

    var localizedErrorAlertTitle: String {
        .productDetailsScreenAlertErrorTitle
    }

    var localizedErrorAlertDismissButtonTitle: String {
        .productDetailsScreenAlertErrorDismissButtonTitle
    }

    var localizedSuccessAlertTitle: String {
        .productDetailsScreenAlertSuccessTitle
    }

    var localizedSaveSuccessAlertMessage: String {
        .productDetailsScreenAlertProductSavedMessage
    }

    var localizedSuccessAlertDismissButtonTitle: String {
        .productDetailsScreenAlertSuccessDismissButtonTitle
    }

    var localizedImageSectionTitle: String {
        .productDetailsScreenSectionImageTitle
    }

    var localizedSelectImageButtonTitle: String {
        .productDetailsScreenSelectImageButtonTitle
    }

    var localizedNameSectionTitle: String {
        .productDetailsScreenSectionNameTitle
    }

    var localizedNameTextFieldPlaceholder: String {
        .productDetailsScreenNameTextFieldPlaceholder
    }

    var localizedBarcodeSectionTitle: String {
        .productDetailsScreenSectionBarcodeTitle
    }

    var localizedScanBarcodeButtonTitle: String {
        .productDetailsScreenScanBarcodeButtonTitle
    }

    var localizedCategorySectionTitle: String {
        .productDetailsScreenSectionCategoryTitle
    }

    var localizedSelectCategoryButtonTitle: String {
        .productDetailsScreenSelectCategoryButtonTitle
    }

    var localizedBarcodeScannerScreenTitle: String {
        .barcodeScannerScreenTitle
    }
}
