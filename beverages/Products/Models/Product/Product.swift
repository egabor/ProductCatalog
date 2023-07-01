//
//  Product.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation

/// Product model for in-app usage
struct Product {

    let productId: Int?
    let imageData: Data?
    let name: String?
    let barcode: String?
    let category: ProductCategory?
}
