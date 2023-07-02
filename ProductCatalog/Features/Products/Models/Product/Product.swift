//
//  Product.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation
import UIKit.UIImage

/// Product model for in-app usage
struct Product {

    let productId: Int?
    let imageData: Data?
    let name: String
    let barcode: String?
    let category: ProductCategory?

    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}
