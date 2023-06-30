//
//  ProductCategory.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation

enum ProductCategory: String {

    case general
    case sparkling
    case coffee
    case juice
    case sports
    case vitaminWater
    case energy
    case tea
    case water
    case flavoredWater
    case sparklingWater
    case unknown
}

extension ProductCategory {

    init?(rawValue: String?) {
        guard let rawValue = rawValue else { return nil }
        guard let value: ProductCategory = .init(rawValue: rawValue) else {
            print("Cannot parse String to ProductCategory: \(rawValue)")
            self = .unknown
            return
        }
        self = value
    }
}
