//
//  ProductDetailsScreen.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

struct ProductDetailsScreen: View {

    @StateObject private var viewModel: ProductDetailsViewModel = .init()

    init(product: Product? = nil) {
        _viewModel = .init(wrappedValue: .init(product: product))
    }

    var body: some View {
        content
            .navigationTitle(viewModel.localizedTitle)
            .toolbar {
                Button(
                    viewModel.localizedSaveButtonTitle,
                    action: viewModel.performExport
                )
            }
            .alert(
                viewModel.localizedWarningAlertTitle,
                isPresented: $viewModel.shouldShowWarningAlert,
                actions: {
                    Button(
                        role: .cancel,
                        action: {},
                        label: { Text(viewModel.localizedWarningAlertDismissButtonTitle) }
                    )
                    Button(
                        action: viewModel.performExportAnyway,
                        label: { Text(viewModel.localizedWarningAlertSaveAnywayButtonTitle) }
                    )
                },
                message: { Text(viewModel.warningMessage) }
            )
    }

    var content: some View {
        form
            .scrollDismissesKeyboard(.immediately)
    }

    var form: some View {
        Text("Hi!")
    }
}

struct ProductDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsScreen()
    }
}
