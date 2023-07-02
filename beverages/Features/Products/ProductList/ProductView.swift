//
//  ProductView.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 02..
//

import SwiftUI

struct ProductView: View {

    let viewData: ProductViewData
    @Binding var isEditing: Bool
    var configuration: Configuration = .init()

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
    }

    @ViewBuilder
    var content: some View {
        if isEditing {
            editingContent
        } else {
            navigationContent
        }
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    var navigationContent: some View {
        NavigationLink(
            destination: productDetailsScreen,
            label: productRowContent
        )
    }

    var editingContent: some View {
        Button(
            action: editingSelection,
            label: editingProductRowContent
        )
    }

    func productRowContent() -> some View {
        HStack {
            productImage
            VStack(alignment: .leading) {
                productName
                mostSimilarProductName
            }
        }
    }

    // MARK: - LEVEL 2 Views: Helpers & Other Subcomponents

    @ViewBuilder
    var productImage: some View {
        if let image = viewData.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(configuration.productImageCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: configuration.productImageCornerRadius)
                        .stroke(Color.white, lineWidth: 0)
                )
                .frame(
                    maxWidth: configuration.maximumImageWidth,
                    maxHeight: configuration.maximumImageHeight,
                    alignment: .center
                )
        }
    }

    @ViewBuilder
    var productName: some View {
        if let name = viewData.name {
            Text(name)
        }
    }

    @ViewBuilder
    var mostSimilarProductName: some View {
        if let mostSimilarProductName = viewData.mostSimilarProductName {
            Text(mostSimilarProductName)
                .monospaced(true)
                .font(.system(size: configuration.similarProductNameFontSize))
        }
    }

    func editingProductRowContent() -> some View {
        HStack {
            selectionIndicator
            productRowContent()
        }
    }

    var selectionImage: Image {
        if viewData.isSelected() {
            return .circleWithInset
        } else {
            return .circle
        }
    }

    var selectionIndicator: some View {
        selectionImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                width: configuration.selectionIndicatorSize,
                height: configuration.selectionIndicatorSize
            )
            .foregroundColor(.accentColor)
    }

    func editingSelection() {
        if viewData.isSelected() {
            viewData.deselect()
        } else {
            viewData.select()
        }
    }

    @ViewBuilder
    func productDetailsScreen() -> some View {
        if let product = viewData.getProduct() {
            ProductDetailsScreen(product: product)
        }
    }
}

extension ProductView {

    struct Configuration {

        var maximumImageWidth: CGFloat = 50.0
        var maximumImageHeight: CGFloat = 50.0
        var productImageCornerRadius: CGFloat = 6.0

        var selectionIndicatorSize: CGFloat = 24.0
        var similarProductNameFontSize: CGFloat = 12
    }
}
