//
//  ProductCatalogApp.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

@main
struct ProductCatalogApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ProductListScreen()
            }
            .onAppear {
                do {
                    try SQLiteHelper.copyDatabaseIfNeeded()
                } catch {
                    print(error)
                }
            }
        }
    }
}
