//
//  SQLiteHelper.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation

enum SQLiteHelperError: Error {
    case invalidBundlePath
    case invalidDirectory
    case noDatabaseFile
    case invalidDocumentsURL
}

class SQLiteHelper {

    /// Copy an empty database file from bundle resources to documents folder if not exists
    static func copyDatabaseIfNeeded() throws {
        let databaseExtension = "db"
        guard let resourcePath = Bundle.main.resourcePath else { throw SQLiteHelperError.invalidBundlePath }
        guard let resourceContents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) else { throw SQLiteHelperError.invalidDirectory }
        guard let databaseFileName = resourceContents.first(where: { $0.contains(databaseExtension) }) else { throw SQLiteHelperError.noDatabaseFile }
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { throw SQLiteHelperError.invalidDocumentsURL }
        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(databaseFileName)
        let destinationURL = documentsURL.appendingPathComponent(databaseFileName)
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
    }
}

