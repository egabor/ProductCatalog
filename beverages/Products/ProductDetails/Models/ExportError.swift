//
//  ExportError.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation

enum ExportError: Error {

    case emptyImage
    case emptyName
    case emptyCategory
}

extension ExportError: LocalizedError {

    public var errorDescription: String? {
        switch self {
            case .emptyImage:
                return .productDetailsScreenAlertErrorImageIsEmptyMessage
            case .emptyName:
                return .productDetailsScreenAlertErrorNameIsEmptyMessage
            case .emptyCategory:
                return .productDetailsScreenAlertErrorCategoryIsEmptyMessage
        }
    }
}
