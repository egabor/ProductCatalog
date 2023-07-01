//
//  DBProduct+Parsing.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import SQLite

// MARK: - Product Parsing

extension DBProduct {

    static func from(_ product: Product) -> DBProduct {
        .init(
            productId: product.productId,
            imageData: product.imageData,
            name: product.name,
            barcode: product.barcode,
            category: product.category?.rawValue
        )
    }
}

// MARK: - SQLite Row Parsing

extension DBProduct {

    static func from(_ row: Row) -> DBProduct {
        .init(
            productId: row[Expression<Int    >(CodingKeys.productId.rawValue)],
            imageData: row[Expression<Data?  >(CodingKeys.imageData.rawValue)],
            name:      row[Expression<String?>(CodingKeys.name.rawValue)],
            barcode:   row[Expression<String?>(CodingKeys.barcode.rawValue)],
            category:  row[Expression<String?>(CodingKeys.category.rawValue)]
        )
    }
}
