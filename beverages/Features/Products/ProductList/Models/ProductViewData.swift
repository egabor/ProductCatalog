//
//  ProductViewData.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation
import UIKit.UIImage

struct ProductViewData: Identifiable, Hashable {

    let id: Int
    let image: UIImage?
    let name: String?
    let mostSimilarProductName: String?
}
