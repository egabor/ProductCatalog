//
//  ExportError.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation

enum ExportError: Error {

    case emptyName
    case emptyCategory
}

extension ExportError: LocalizedError {

    public var errorDescription: String? {
        switch self {
            case .emptyName:
                return .productDetailsScreenAlertErrorNameIsEmptyMessage
            case .emptyCategory:
                return .productDetailsScreenAlertErrorCategoryIsEmptyMessage
        }
    }
}
