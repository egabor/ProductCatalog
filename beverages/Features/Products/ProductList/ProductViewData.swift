//
//  ProductViewData.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation
import UIKit.UIImage

struct ProductViewData: Identifiable {

    let id: Int
    let image: UIImage?
    let name: String?
    let mostSimilarProductName: String?

    let isSelected: () -> Bool
    let select: () -> Void
    let deselect: () -> Void
    let getProduct: () -> Product?
}

extension ProductViewData: Equatable {

    static func == (lhs: ProductViewData, rhs: ProductViewData) -> Bool {
        lhs.id == rhs.id &&
        lhs.image == rhs.image &&
        lhs.name == rhs.name &&
        lhs.mostSimilarProductName == rhs.mostSimilarProductName
    }
}

extension ProductViewData: Hashable {

    func hash(into hasher: inout Hasher) {

        hasher.combine(id)
        hasher.combine(image)
        hasher.combine(name)
        hasher.combine(mostSimilarProductName)
    }
}
