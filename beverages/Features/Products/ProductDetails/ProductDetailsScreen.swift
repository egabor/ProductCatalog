//
//  ProductDetailsScreen.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

struct ProductDetailsScreen: View {

    @StateObject private var viewModel: ProductDetailsViewModel = .init(product: nil)
    var configuration: Configuration = .init()

    init() {}

    init(product: Product?, configuration: Configuration = .init()) {
        _viewModel = .init(wrappedValue: .init(product: product))
        self.configuration = configuration
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
            .onReceive(viewModel.didScanBarcode) { _ in
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.prepare()
                feedbackGenerator.notificationOccurred(.success)
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

    @ViewBuilder
    var sections: some View {
        productImageSection
        productNameSection
        productBarcodeSection
        categorySection
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

// MARK: - Sections

extension ProductDetailsScreen {

    // MARK: - Product Image

    var productImageSection: some View {
        Section(
            content: productImageSectionContent,
            header: productImageSectionHeader
        )
    }

    func productImageSectionHeader() -> some View {
        Text(LocalizedStringKey(viewModel.localizedImageSectionTitle))
    }

    func productImageSectionContent() -> some View {
        VStack {
            productImage
            selectProductImageButton
        }
    }

    @ViewBuilder
    var productImage: some View {
        if let image = viewModel.productImage {
            HStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(configuration.productImageCornerRadius)
                    .overlay(
                        RoundedRectangle(cornerRadius: configuration.productImageCornerRadius)
                            .stroke(Color.white, lineWidth: 0)
                    )
                    .shadow(radius: configuration.productImageShadowRadius)
                    .frame(
                        maxWidth: configuration.maximumImageWidth,
                        maxHeight: configuration.maximumImageHeight,
                        alignment: .center
                    )
                Spacer()
            }
        }
    }

    @ViewBuilder
    var selectProductImageButton: some View {
        if viewModel.isEditing {
            HStack {
                Menu(
                    content: sourceTypeMenuItems,
                    label: sourceTypePickerLabel
                )
            }
        }
    }

    func sourceTypeMenuItems() -> some View {
        ForEach(viewModel.mediaSourceTypes) { sourceType in
            Button(
                action: { viewModel.selectImage(for: sourceType) },
                label: { Text(sourceType.displayValue) }
            )
        }
    }

    func sourceTypePickerLabel() -> some View {
        Text(LocalizedStringKey(viewModel.localizedSelectImageButtonTitle))
            .frame(maxWidth: .infinity)
    }

    // MARK: - Product Name

    var productNameSection: some View {
        Section(
            content: productNameSectionContent,
            header: productNameSectionHeader
        )
    }

    func productNameSectionHeader() -> some View {
        Text(LocalizedStringKey(viewModel.localizedNameSectionTitle))
    }

    func productNameSectionContent() -> some View {
        TextField(
            LocalizedStringKey(viewModel.localizedNameTextFieldPlaceholder),
            text: $viewModel.name
        )
        .disableAutocorrection(true)
    }


    // MARK: - Product Barcode

    var productBarcodeSection: some View {
        Section(
            content: productBarcodeSectionContent,
            header: productBarcodeSectionHeader
        )
    }

    func productBarcodeSectionHeader() -> some View {
        Text(LocalizedStringKey(viewModel.localizedBarcodeSectionTitle))
    }

    func productBarcodeSectionContent() -> some View {
        HStack {
            Text(viewModel.barcode)
            Spacer()
            scanBarcodeButton
        }
    }

    @ViewBuilder
    var scanBarcodeButton: some View {
        if viewModel.isEditing {
            Button(
                action: viewModel.showBarcodeScanner,
                label: { Text(LocalizedStringKey(viewModel.localizedScanBarcodeButtonTitle)) }
            )
        }
    }

    // MARK: - Product Category

    var categorySection: some View {
        Section(
            content: productCategorySectionContent,
            header: productCategorySectionHeader
        )
    }

    func productCategorySectionHeader() -> some View {
        Text(LocalizedStringKey(viewModel.localizedCategorySectionTitle))
    }

    func productCategorySectionContent() -> some View {
        Menu(
            content: categoryMenuItems,
            label: categoryPickerLabel
        )
    }

    func categoryMenuItems() -> some View {
        ForEach(viewModel.categories) { category in
            Button(
                action: { viewModel.category = category },
                label: { Text(category.displayValue) }
            )
        }
    }

    func categoryPickerLabel() -> some View {
        HStack {
            if let category = viewModel.category {
                Text(category.displayValue)
            } else {
                Text(LocalizedStringKey(viewModel.localizedSelectCategoryButtonTitle))
            }
            Spacer()
        }
    }
}

extension ProductDetailsScreen {

    struct Configuration {

        var maximumImageWidth: CGFloat = 250.0
        var maximumImageHeight: CGFloat = 250.0
        var productImageCornerRadius: CGFloat = 8.0
        var productImageShadowRadius: CGFloat = 2.0
    }
}
