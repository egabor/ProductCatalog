//
//  DBProduct.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation

/// Product model for database representation
struct DBProduct {

    let productId: Int?
    let imageData: Data?
    let name: String?
    let barcode: String?
    let category: String?
}

extension DBProduct {

    enum CodingKeys: String, CodingKey {

        case productId
        case imageData
        case name
        case barcode
        case category
    }
}
