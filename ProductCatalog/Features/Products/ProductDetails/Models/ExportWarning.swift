//
//  ExportWarning.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation

enum ExportWarning: Error {

    case emptyBarcode
}

extension ExportWarning: LocalizedError {

    public var errorDescription: String? {
        switch self {
            case .emptyBarcode:
                return .productDetailsScreenAlertWarningBarcodeIsEmptyMessage
        }
    }
}
