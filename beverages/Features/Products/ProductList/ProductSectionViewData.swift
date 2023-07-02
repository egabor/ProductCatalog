//
//  ProductSectionViewData.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation

struct ProductSectionViewData: Identifiable, Hashable {

    let order: Int
    let headerTitle: String
    let products: [ProductViewData]

    var id: Int { order }
}
