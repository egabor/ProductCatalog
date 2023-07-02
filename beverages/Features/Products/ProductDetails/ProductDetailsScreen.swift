//
//  ProductDetailsScreen.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

struct ProductDetailsScreen: View {

    @StateObject private var viewModel: ProductDetailsViewModel = .init()

    init() {
        _viewModel = .init(wrappedValue: .init(product: nil))
    }

    init(product: Product) {
        _viewModel = .init(wrappedValue: .init(product: product))
    }

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
            .navigationTitle(LocalizedStringKey(viewModel.localizedTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: editSaveProductToolbarItem)
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
            .fullScreenCover(
                isPresented: $viewModel.shouldShowBarcodeScanner,
                content: barcodeScannerScreen
            )
            .fullScreenCover(
                item: $viewModel.imagePickerMediaSource,
                content: imageSelector
            )
            .onReceive(viewModel.$barcode) { barcode in // TODO: move to viewmodel
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

    // MARK: - LEVEL 1 Views: Main UI Elements

    func editSaveProductToolbarItem() -> some ToolbarContent {
        ToolbarItem(
            placement: .navigationBarTrailing,
            content: editSaveProductButton
        )
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

    // MARK: - LEVEL 2 Views: Helpers & Other Subcomponents

    @ViewBuilder
    func editSaveProductButton() -> some View {
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
            text: $viewModel.name
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

    func barcodeScannerScreen() -> some View {
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
            .navigationTitle(LocalizedStringKey(viewModel.localizedBarcodeScannerScreenTitle))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProductDetailsScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailsScreen()
    }
}
