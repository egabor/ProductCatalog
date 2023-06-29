//
//  Product.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation

struct Product: Identifiable {
    let productId: Int
    let imagePath: String?
    let name: String?
    let barCode: String?
    let category: ProductCategory?

    var id: Int { productId }
}
