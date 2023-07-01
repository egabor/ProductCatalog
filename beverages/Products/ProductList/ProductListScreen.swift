//
//  ProductListScreen.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

struct ProductListScreen: View {

    @StateObject private var viewModel: ProductListViewModel = .init()

    var body: some View {
        content
            .navigationTitle(LocalizedStringKey(viewModel.localizedTitle))
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    addNewProductButton
                }
            }
            .toolbar {
                if viewModel.isEditMode {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button(
                            role: .destructive,
                            action: viewModel.deleteSelected,
                            label: {
                                Text(viewModel.localizedDeleteButtonTitle)
                            }
                        )
                        .disabled(viewModel.selection.isEmpty)
                    }
                }
            }
            .onChange(of: viewModel.isEditMode) { _ in
                viewModel.selection.removeAll()
            }
    }

    var content: some View {
        list
    }

    var addNewProductButton: some View {
        NavigationLink {
            ProductDetailsScreen()
        } label: {
            Image(systemName: ImageConstants.plus)
        }
        .disabled(viewModel.isEditMode)
    }

    @ViewBuilder
    var list: some View {
        if viewModel.isProductListEmpty {
            emptyList
        } else {
            productList
        }
    }

    var emptyList: some View {
        Text(LocalizedStringKey(viewModel.localizedEmptyListTitle))
    }

    var productList: some View {
        List(viewModel.productSections) { productSection($0) }
            .listStyle(.plain)
            .toolbar {
                Button(
                    action: viewModel.toggleEditMode,
                    label: { Text(LocalizedStringKey(viewModel.localizedEditButtonTitle)) }
                )
            }
    }

    func productSection(_ viewData: ProductSectionViewData) -> some View {
        Section(content: {
            ForEach(viewData.products) { productRow($0) }
        }, header: {
            Text(viewData.headerTitle)
        })
    }

    @ViewBuilder
    func productRow(_ viewData: ProductViewData) -> some View {
        if viewModel.isEditMode {
            Button(
                action: {
                        if viewModel.selection.contains(viewData) {
                            viewModel.selection.remove(viewData)
                        } else {
                            viewModel.selection.insert(viewData)
                        }
                },
                label: {
                    HStack {
                        Image(systemName: viewModel.selection.contains(viewData) ? ImageConstants.circleWithInset : ImageConstants.circle)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 24, maxHeight: 24)
                            .foregroundColor(.accentColor)
                        productRowLabel(viewData)
                    }
                }
            )
        } else {
            NavigationLink(
                destination: { ProductDetailsScreen(product: viewModel.product(for: viewData.id)) },
                label: { productRowLabel(viewData) }
            )
        }
    }

    func productRowLabel(_ viewData: ProductViewData) -> some View {
        HStack {
            if let image = viewData.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 50, maxHeight: 50, alignment: .center) // TODO: move to config
            }
            VStack(alignment: .leading) {
                if let name = viewData.name {
                    Text(name)
                }
                if let mostSimilarProductName = viewData.mostSimilarProductName {
                    Text(mostSimilarProductName)
                        .monospaced(true)
                        .font(.system(size: 12))
                }
            }
        }
    }
}

struct ProductListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductListScreen()
    }
}
