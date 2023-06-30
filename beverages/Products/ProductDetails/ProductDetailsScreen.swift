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
            .fullScreenCover(isPresented: $viewModel.shouldShowBarcodeScanner) {
                NavigationView {
                    ScannerScreen(
                        recognizedItems: $viewModel.recognizedVisionItems,
                        recognizedDataType: .barcode(symbologies: [.ean8, .ean13])
                    )
                    .ignoresSafeArea()
                    .toolbar {
                        Button(
                            action: viewModel.hideBarcodeScanner,
                            label: { Image(systemName: "xmark") }
                        )
                    }
                }
            }
            .onReceive(viewModel.$barcode) { barcode in
                guard barcode.isEmpty == false else { return }
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.prepare()
                feedbackGenerator.notificationOccurred(.success)
                viewModel.hideBarcodeScanner()
            }
    }

    var content: some View {
        form
            .scrollDismissesKeyboard(.immediately)
    }

    var form: some View {
        Form {
            Section(
                content: {
                    productNameTextField
                },
                header: {
                    Text("Name")
                }
            )

            Section(
                content: {
                    barcodeInput
                },
                header: {
                    Text("Barcode")
                }
            )

            Section(
                content: {
                    categorySelector
                },
                header: {
                    Text("Category")
                }
            )
        }
    }

    var productNameTextField: some View {
        TextField(
            "Name",
            text: $viewModel.name
        )
        .disableAutocorrection(true)
    }

    var barcodeInput: some View {
        HStack {
            Text(viewModel.barcode)
            Spacer()
            Button(
                action: viewModel.showBarcodeScanner,
                label: { Text("Scan") }
            )
        }
    }

    var categorySelector: some View {
        Menu(
            content: {
                ForEach(viewModel.categories) { category in
                    Button(
                        action: { viewModel.category = category },
                        label: { Text(category.displayValue) }
                    )
                }
            },
            label: {
                HStack {
                    Spacer()
                    if let category = viewModel.category {
                        Text(category.displayValue)
                    } else {
                        Text("Select Category")
                    }
                }
            }
        )
    }
}

struct ProductDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsScreen()
    }
}
