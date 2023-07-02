//
//  ProductCategory.swift
//  ProductCatalog
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
        NSLocalizedString(displayValueKey, comment: "")
    }

    var displayValueKey: String {
        switch self {
            case .general:
                return .productCategoryGeneralTitle
            case .sparkling:
                return .productCategorySparklingTitle
            case .coffee:
                return .productCategoryCoffeeTitle
            case .juice:
                return .productCategoryJuiceTitle
            case .sports:
                return .productCategorySportsTitle
            case .vitaminWater:
                return .productCategoryVitaminWaterTitle
            case .energy:
                return .productCategoryEnergyTitle
            case .tea:
                return .productCategoryTeaTitle
            case .water:
                return .productCategoryWaterTitle
            case .flavoredWater:
                return .productCategoryFlavoredWaterTitle
            case .sparklingWater:
                return .productCategorySparklingWaterTitle
        }
    }

    var order: Int {
        switch self {
            case .general:
                return 0
            case .sparkling:
                return 1
            case .coffee:
                return 2
            case .juice:
                return 3
            case .sports:
                return 4
            case .vitaminWater:
                return 5
            case .energy:
                return 6
            case .tea:
                return 7
            case .water:
                return 8
            case .flavoredWater:
                return 9
            case .sparklingWater:
                return 10
        }
    }
}
