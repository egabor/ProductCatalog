//
//  ProductCategory.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation

enum ProductCategory: String, CaseIterable, Identifiable {

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

    var id: String { rawValue }
}

extension ProductCategory {

    init?(rawValue: String?) {

        guard let rawValue = rawValue else { return nil }
        guard let value: ProductCategory = .init(rawValue: rawValue) else {
            print("Cannot parse String to ProductCategory: \(rawValue)")
            return nil
        }
        self = value
    }

    var displayValue: String {
        switch self {
            case .general:
                return "00 - General"
            case .sparkling:
                return "01 - Sparkling"
            case .coffee:
                return "02 - Coffee"
            case .juice:
                return "03 - Juice"
            case .sports:
                return "04 - Sports"
            case .vitaminWater:
                return "05 - Vitamin Water"
            case .energy:
                return "06 - Energy"
            case .tea:
                return "07 - Tea"
            case .water:
                return "08 - Water"
            case .flavoredWater:
                return "09 - Flavored Water"
            case .sparklingWater:
                return "10 - Sparkling Water"
        }
    }
}
