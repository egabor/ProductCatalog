//
//  ProductService.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import Combine

class ProductService {

    var dataSetUpdate: PassthroughSubject<Void, Never> = .init()

    /// Saves the data to the DB then retrieves the saved record and returns it.
    func save(product: Product) throws -> Product {
        let productToSave = DBProduct.from(product)
        let savedProduct = try productToSave.save()
        dataSetUpdate.send(())
        return Product.from(savedProduct)
    }

    // TODO: revise (out of use currently)
    func deleteProduct(by id: Int) throws {
        try DBProduct.delete(by: id)
        dataSetUpdate.send(())
    }

    func deleteProducts(by ids: [Int]) throws {
        try ids.forEach { id in
            try DBProduct.delete(by: id)
        }
        dataSetUpdate.send(())
    }

    func loadAll() -> [Product] {
        DBProduct.fetchAll().map { Product.from($0) }
    }
}
