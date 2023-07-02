//
//  MainScreen.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 02..
//

import SwiftUI

enum AppState {
    case loading
    case ready
    case error
}

struct MainScreen: View {

    @State private var appState: AppState = .loading

    var body: some View {
        switch appState {
            case .loading:
                Image.hourglass
                    .onAppear {
                        do {
                            try SQLiteHelper.copyDatabaseIfNeeded()
                            appState = .ready
                        } catch {
                            appState = .error
                            print(error)
                        }
                    }
            case .ready:
                NavigationView {
                    ProductListScreen()
                }
            case .error:
                Image.error
        }
    }
}
