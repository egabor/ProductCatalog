//
//  String+Trimmed.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation

extension String {

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
