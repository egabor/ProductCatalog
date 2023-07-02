//
//  Product+Parsing.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation

// MARK: - DBProduct Parsing

extension Product {

    static func from(_ dbProduct: DBProduct) -> Product {
        .init(
            productId: dbProduct.productId,
            imageData: dbProduct.imageData,
            name: dbProduct.name ?? "",
            barcode: dbProduct.barcode,
            category: .init(rawValue: dbProduct.category)
        )
    }
}
