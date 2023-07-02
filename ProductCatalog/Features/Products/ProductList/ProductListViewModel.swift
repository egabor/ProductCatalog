//
//  ProductListViewModel.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation
import Resolver
import Combine

class ProductListViewModel: ObservableObject {

    private var products: [Product] = []
    @Published var productSections: [ProductSectionViewData] = []
    @Published var isEditing: Bool = false
    @Published var selection = Set<Int>()

    var isSelectionEmpty: Bool {
        selection.isEmpty
    }

    var isProductListEmpty: Bool {
        productSections.isEmpty
    }
    var levenshteinDistances: [(pair: StringPair, distance: Int)] = []

    @Injected private var productService: ProductServiceProtocol
    @Injected private var getLevenshteinDistances: GetLevenshteinDistancesUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()

    init() {

        load()
        setupSubscriptions()
    }

    func load() {

        products = productService.loadAll()
        calculateLevenshteinDistance(for: products)

        productSections = ProductCategory.allCases.compactMap { category in
            let filteredProducts = products.filter { $0.category == category }
            guard !filteredProducts.isEmpty else { return nil }
            return createProductSection(from: category, products: filteredProducts)
        }

        if productSections.isEmpty {
            isEditing = false
        }
    }

    private func setupSubscriptions() {

        productService.dataSetUpdate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }

    private func calculateLevenshteinDistance(for products: [Product]) {

        let names = Set(products.map { $0.name }).sorted()
        levenshteinDistances = getLevenshteinDistances(for: names)
    }

    private func mostSimilarProductName(for name: String) -> String? {
        levenshteinDistances.first { $0.pair.contains(name) }?.pair.pair(of: name)
    }

    func deleteSelected() {

        try? productService.deleteProducts(by: selection.map { $0 })
        selection.removeAll()
    }

    func getProduct(for productId: Int) -> Product? {
        products.first(where: { $0.productId == productId })
    }

    func toggleEditMode() {

        isEditing.toggle()
        selection.removeAll()
    }

    private func createProductSection(from category: ProductCategory, products: [Product]) -> ProductSectionViewData {
        .init(
            order: category.order,
            headerTitle: category.displayValue,
            products: products
                .sorted(by: compareProducts)
                .map(createProductViewData)
        )
    }

    private func compareProducts(productA: Product, productB: Product) -> Bool {
        productA.name.localizedCaseInsensitiveCompare(productB.name) == .orderedAscending
    }

    private func createProductViewData(from product: Product) -> ProductViewData {

        let productId: Int = product.productId! // productId always be there at this point
        return ProductViewData(
            id: productId,
            image: product.image,
            name: product.name,
            mostSimilarProductName: mostSimilarProductName(for: product.name),
            isSelected: { [weak self] in self?.selection.contains(productId) ?? false },
            select: { [weak self] in self?.selection.insert(productId) },
            deselect: { [weak self] in self?.selection.remove(productId) },
            getProduct: { [weak self] in self?.getProduct(for: productId) }
        )
    }
}

// MARK: - Localized Strings

extension ProductListViewModel {

    var localizedTitle: String {
        .productListScreenTitle
    }

    var localizedEditButtonTitle: String {

        if isEditing {
            return .productListScreenDoneButtonTitle
        }
        return .productListScreenEditButtonTitle
    }

    var localizedDeleteButtonTitle: String {

        if selection.isEmpty {
            return NSLocalizedString(.productListScreenDeleteButtonTitle, comment: "")
        } else {
            return String(format: NSLocalizedString(.productListScreenDeleteWithCountButtonTitle, comment: ""), selection.count)
        }
    }

    var localizedEmptyListTitle: String {
        .productListScreenEmptyListTitle
    }
}
