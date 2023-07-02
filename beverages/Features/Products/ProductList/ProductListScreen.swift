//
//  ProductListScreen.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

struct ProductListScreen: View {

    @StateObject private var viewModel: ProductListViewModel = .init()

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
            .navigationTitle(LocalizedStringKey(viewModel.localizedTitle))
            .toolbar(content: addProductToolbarItem)
            .toolbar(content: deleteSelectedProductsToolbarItem)
            .onChange(of: viewModel.isEditing) { _ in
                viewModel.selection.removeAll()
            }
    }

    @ViewBuilder
    var content: some View {
        if viewModel.isProductListEmpty {
            emptyList
        } else {
            productList
        }
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    func addProductToolbarItem() -> some ToolbarContent {
        ToolbarItem(
            placement: .navigationBarLeading,
            content: addProductButton
        )
    }

    @ToolbarContentBuilder
    func deleteSelectedProductsToolbarItem() -> some ToolbarContent {
        if viewModel.isEditing {
            ToolbarItemGroup(
                placement: .bottomBar,
                content: deleteSelectedProductsButton
            )
        }
    }

    var emptyList: some View {
        Text(LocalizedStringKey(viewModel.localizedEmptyListTitle))
    }

    var productList: some View {
        List(
            viewModel.productSections,
            rowContent: productListContent
        )
        .listStyle(.plain)
        .toolbar(content: editListToolbarItem)
    }

    // MARK: - LEVEL 2 Views: Helpers & Other Subcomponents

    func addProductButton() -> some View {
        NavigationLink(
            destination: ProductDetailsScreen.init,
            label: { Image.plus }
        )
    }

    func deleteSelectedProductsButton() -> some View {
        Button(
            role: .destructive,
            action: viewModel.deleteSelected,
            label: { Text(viewModel.localizedDeleteButtonTitle) }
        )
        .disabled(viewModel.isSelectionEmpty)
    }

    func productListContent(_ viewData: ProductSectionViewData) -> some View {
        ProductSection(
            viewData: viewData,
            isEditing: $viewModel.isEditing
        )
    }

    func editListToolbarItem() -> some ToolbarContent {
        ToolbarItem(
            placement: .navigationBarTrailing,
            content: editListButton
        )
    }

    func editListButton() -> some View {
        Button(
            action: viewModel.toggleEditMode,
            label: { Text(LocalizedStringKey(viewModel.localizedEditButtonTitle)) }
        )
    }
}

struct ProductListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductListScreen()
    }
}
