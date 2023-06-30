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
            imagePath: product.imagePath,
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
            productId: row[Expression<Int    >("productId")],
            imagePath: row[Expression<String?>("imagePath")],
            name:      row[Expression<String?>("name")],
            barcode:   row[Expression<String?>("barcode")],
            category:  row[Expression<String?>("category")]
        )
    }
}
