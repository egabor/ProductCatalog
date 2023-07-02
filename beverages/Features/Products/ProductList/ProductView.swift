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
                .frame(maxWidth: 50, maxHeight: 50, alignment: .center) // TODO: move to config
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
                .font(.system(size: 12)) // TODO: move to config
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
            .frame(maxWidth: 24, maxHeight: 24) // TODO: move to config
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

//struct ProductRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ProductView( // TODO: provide preview data
//            viewData: .init(
//                id: 0,
//                image: nil,
//                name: nil,
//                mostSimilarProductName: nil,
//                isSelected: {},
//                select: {},
//                deselect: {},
//                getProduct: {}
//            ),
//            isEditing: .constant(false)
//        )
//    }
//}
