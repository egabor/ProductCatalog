//
//  DBProduct+SQLite.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import SQLite

extension DBProduct {

    enum SQLiteError: Error {

        case missingId
        case missingRowId
        case general
        case savedButFailedToFetch
    }
}

extension DBProduct {

    private static var db: Connection? {

        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Invalid directory")
            return nil
        }
        let databasePath = documentsDirectory.appendingPathComponent("\(Constants.databaseFileName).\(Constants.databaseFileExtension)")
        return try? Connection(databasePath.absoluteString)
    }

    static var productsTable: Table {
        .init("Products")
    }

    private var setters: [Setter] {

        var setters = [Setter]()
        if let productId = productId {
            setters.append(Expression<Int>(CodingKeys.productId.rawValue) <- productId)
        }
        setters.append(Expression<Data?  >(CodingKeys.imageData.rawValue) <- imageData)
        setters.append(Expression<String?>(CodingKeys.name.rawValue)      <- name)
        setters.append(Expression<String?>(CodingKeys.barcode.rawValue)   <- barcode)
        setters.append(Expression<String?>(CodingKeys.category.rawValue)  <- category)
        return setters
    }

    private var upsert: Insert {
        Self.productsTable.upsert(setters, onConflictOf: Expression<Int>(CodingKeys.productId.rawValue))
    }
}

// MARK: - Database Operations

extension DBProduct {

    func save() throws -> DBProduct {

        let rowId = try Self.db?.run(upsert)
        if let productId = productId {
            return try Self.fetch(by: productId)
        } else {
            guard let insertedRowIdInt64 = rowId else { throw SQLiteError.missingRowId }
            let insertedRowId = Int(insertedRowIdInt64)
            return try Self.fetch(by: insertedRowId)
        }
    }

    static func delete(by id: Int) throws {

        let rowToDelete = Self.productsTable.filter(Expression<Int>(CodingKeys.productId.rawValue) == id)
        _ = try Self.db?.run(rowToDelete.delete())
    }

    static func fetchAll() -> [DBProduct] {

        guard let db = db else { return [] }
        guard let unmappedResults: AnySequence<Row> = try? db.prepare(productsTable) else { return [] }
        let results = unmappedResults.map { Self.from($0) }
        return results
    }

    static func fetch(by id: Int) throws -> DBProduct {

        guard let row: Row = Array<Row>(try db?.prepare(productsTable.filter(Expression<Int>(CodingKeys.productId.rawValue) == id)).map { $0 } ?? []).first else {
            throw SQLiteError.general
        }
        let fetchedData = Self.from(row)
        return fetchedData
    }
}
