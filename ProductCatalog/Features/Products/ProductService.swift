//
//  ProductService.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import Combine

protocol ProductServiceProtocol {

    var dataSetUpdate: PassthroughSubject<Void, Never> { get set }

    func save(product: Product) throws -> Product
    func deleteProducts(by ids: [Int]) throws
    func loadAll() -> [Product]
}

class ProductService: ProductServiceProtocol {

    var dataSetUpdate: PassthroughSubject<Void, Never> = .init()

    /// Saves the data to the DB then retrieves the saved record and returns it.
    func save(product: Product) throws -> Product {

        let productToSave = DBProduct.from(product)
        let savedProduct = try productToSave.save()
        dataSetUpdate.send(())
        return Product.from(savedProduct)
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
