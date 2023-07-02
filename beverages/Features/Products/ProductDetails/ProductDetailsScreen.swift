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
            .navigationTitle(LocalizedStringKey(viewModel.localizedTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isEditing {
                    Button(
                        LocalizedStringKey(viewModel.localizedSaveButtonTitle),
                        action: viewModel.performExport
                    )
                } else {
                    Button(
                        LocalizedStringKey(viewModel.localizedEditButtonTitle),
                        action: viewModel.editProduct
                    )
                }
            }
            .alert(
                LocalizedStringKey(viewModel.localizedWarningAlertTitle),
                isPresented: $viewModel.shouldShowWarningAlert,
                actions: {
                    Button(
                        role: .cancel,
                        action: {},
                        label: { Text(LocalizedStringKey(viewModel.localizedWarningAlertDismissButtonTitle)) }
                    )
                    Button(
                        action: viewModel.performExportAnyway,
                        label: { Text(LocalizedStringKey(viewModel.localizedWarningAlertSaveAnywayButtonTitle)) }
                    )
                },
                message: { Text(LocalizedStringKey(viewModel.warningMessage)) }
            )
            .alert(
                LocalizedStringKey(viewModel.localizedErrorAlertTitle),
                isPresented: $viewModel.shouldShowErrorAlert,
                actions: {
                    Text(LocalizedStringKey(viewModel.localizedErrorAlertDismissButtonTitle))
                },
                message: { Text(LocalizedStringKey(viewModel.errorMessage)) }
            )
            .alert(
                LocalizedStringKey(viewModel.localizedSuccessAlertTitle),
                isPresented: $viewModel.shouldShowSuccessAlert,
                actions: {
                    Text(LocalizedStringKey(viewModel.localizedSuccessAlertDismissButtonTitle))
                },
                message: { Text(LocalizedStringKey(viewModel.successMessage)) }
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
                            label: { Image.xmark }
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

    @ViewBuilder
    var content: some View {
        if viewModel.isEditing {
            editingContent
        } else {
            displayContent
        }
    }

    var displayContent: some View {
        List {
            sections
        }
        .listStyle(.plain)
        .disabled(true)
    }

    var editingContent: some View {
        Form {
            sections
        }
        .scrollDismissesKeyboard(.immediately)
    }

    @ViewBuilder
    var sections: some View {
        Section(
            content: {
                productImageRow
            },
            header: {
                Text(LocalizedStringKey(viewModel.localizedImageSectionTitle))
            }
        )

        Section(
            content: {
                productNameTextField
            },
            header: {
                Text(LocalizedStringKey(viewModel.localizedNameSectionTitle))
            }
        )

        Section(
            content: {
                barcodeInput
            },
            header: {
                Text(LocalizedStringKey(viewModel.localizedBarcodeSectionTitle))
            }
        )

        Section(
            content: {
                categorySelector
            },
            header: {
                Text(LocalizedStringKey(viewModel.localizedCategorySectionTitle))
            }
        )
    }

    var productImageRow: some View {
        VStack {
            if let image = viewModel.productImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 250, maxHeight: 250, alignment: .center) // TODO: move to config
            }
            if viewModel.isEditing {
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
                            Text(LocalizedStringKey(viewModel.localizedSelectImageButtonTitle))
                                .frame(maxWidth: .infinity)
                        }
                    )
                    // TODO: Clear button
                }
            }
        }
    }

    var productNameTextField: some View {
        TextField(
            LocalizedStringKey(viewModel.localizedNameTextFieldPlaceholder),
            text: .init(
                get: { viewModel.name.trimmed },
                set: { viewModel.name = $0.trimmed }
            )
        )
        .disableAutocorrection(true)
    }

    var barcodeInput: some View {
        HStack {
            Text(viewModel.barcode)
            Spacer()
            if viewModel.isEditing {
                Button(
                    action: viewModel.showBarcodeScanner,
                    label: { Text(LocalizedStringKey(viewModel.localizedScanBarcodeButtonTitle)) }
                )
            }
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
                    if let category = viewModel.category {
                        Text(category.displayValue)
                    } else {
                        Text(LocalizedStringKey(viewModel.localizedSelectCategoryButtonTitle))
                    }
                    Spacer()
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
