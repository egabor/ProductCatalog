//
//  ProductDetailsViewModel.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import Resolver

class ProductDetailsViewModel: ObservableObject {

    enum ExportWarning: Error {

        case emptyName
    }

    var productId: Int?
    @Published var imagePath: String = ""
    @Published var name: String = ""
    @Published var barcode: String = ""
    @Published var category: ProductCategory?

    var warningMessage: String = ""
    @Published var shouldShowWarningAlert: Bool = false

    @Injected private var productService: ProductService

    init(product: Product? = nil) {
        if let product = product {
            importData(product)
        }
    }

    private func validateForWarnings() throws {
        guard name.isEmpty == false else { throw ExportWarning.emptyName }
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
        } catch {
            print("\(error)")
            warningMessage = error.localizedDescription
            shouldShowWarningAlert = true
        }
    }

    func performExportAnyway() {

        do {
            let productToSave = try export(skipWarnings: true)
            guard let savedProduct = try? productService.save(product: productToSave) else { return }
            importData(savedProduct)
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
