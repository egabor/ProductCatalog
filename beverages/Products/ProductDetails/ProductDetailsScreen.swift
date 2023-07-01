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
                            label: { Image(systemName: "xmark") } // TODO: move to constants
                        )
                    }
                }
            }
            .fullScreenCover(
                item: $viewModel.imagePickerMediaSource,
                content: imageSelector
            )
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
                    productImageRow
                },
                header: {
                    Text("Image") // TODO: localize
                }
            )

            Section(
                content: {
                    productNameTextField
                },
                header: {
                    Text("Name") // TODO: localize
                }
            )

            Section(
                content: {
                    barcodeInput
                },
                header: {
                    Text("Barcode") // TODO: localize
                }
            )

            Section(
                content: {
                    categorySelector
                },
                header: {
                    Text("Category") // TODO: localize
                }
            )
        }
    }

    var productImageRow: some View {
        VStack {
            if let image = viewModel.productImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250, maxHeight: 250, alignment: .center) // TODO: move to config
            }
//            else if let image = UIImage(contentsOfFile: viewModel.imagePath) {
//                Image(uiImage: image)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: 250, maxHeight: 250, alignment: .center) // TODO: move to config
//            }
            HStack {
                Menu(
                    content: {
                        ForEach(viewModel.mediaSourceTypes) { sourceType in
                            Button(
                                action: { viewModel.selectImage(for: sourceType) },
                                label: { Text(sourceType.displayValue) }
                            )
                        }
                    },
                    label: {
                        Text("Select Image") // TODO: localize
                            .frame(maxWidth: .infinity) // TODO: move to config
                    }
                )
                // TODO: Clear button
            }
        }
    }

    var productNameTextField: some View {
        TextField(
            "Name", // TODO: localize
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
                label: { Text("Scan") } // TODO: localize
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
                        Text("Select Category") // TODO: localize
                    }
                }
            }
        )
    }

    @ViewBuilder
    func imageSelector(_ sourceType: ImagePickerMediaSourceType?) -> some View {
        if let sourceType = sourceType {
            ImagePicker(
                sourceType: sourceType.sourceType,
                didSelectImage: viewModel.didSelectImage
            )
            .ignoresSafeArea()
        }
    }
}

struct ProductDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsScreen()
    }
}
