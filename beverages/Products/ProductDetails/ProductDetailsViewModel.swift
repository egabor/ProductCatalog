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

    enum ExportWarning: Error {

        case emptyName
    }

    var productId: Int?
    @Published var imagePath: String = ""
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
}

extension ProductDetailsViewModel {

    // MARK: - Import

    private func importData(_ product: Product) {

        productId = product.productId
        imagePath = product.imagePath ?? ""
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
            imagePath: imagePath,
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
