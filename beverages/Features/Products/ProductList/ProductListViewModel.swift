//
//  ProductListViewModel.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation
import Resolver
import Combine

class ProductListViewModel: ObservableObject {

    private var products: [Product] = []
    @Published var productSections: [ProductSectionViewData] = []
    @Published var isEditMode: Bool = false
    @Published var selection = Set<ProductViewData>()

    var levenshteinDistances: [(pair: StringPair, distance: Int)] = []

    @Injected private var productService: ProductService

    var isProductListEmpty: Bool {
        productSections.isEmpty
    }

    private var cancellables = Set<AnyCancellable>()

    init() {
        load()
        setupSubscriptions()
    }

    func load() {
        products = productService.loadAll()
        productSections = []
        calculateLevenshteinDistance(for: products)

        ProductCategory.allCases.forEach { category in
            let filteredProducts = products.filter { $0.category == category }
            if filteredProducts.isEmpty == false {
                productSections.append(
                    .init(
                        order: category.order,
                        headerTitle: category.displayValue,
                        products: filteredProducts
                            .sorted { (productA, productB) -> Bool in
                                productA.name.localizedCaseInsensitiveCompare(productB.name) == .orderedAscending
                            }
                            .map { product in
                                .init(
                                    id: product.productId!, // productId always be there at this point
                                    image: product.image,
                                    name: product.name,
                                    mostSimilarProductName: mostSimilarProductName(for: product.name)
                                )
                            }
                    )
                )
            }
        }
    }

    private func calculateLevenshteinDistance(for products: [Product]) {
        levenshteinDistances = []
        let names = Set(products.map { $0.name }).sorted()
        for i in 0 ..< names.count - 1 {
            for j in i + 1 ..< names.count {
                if i == j { continue }
                let nameA = names[i]
                let nameB = names[j]
                let key: StringPair = .init(valueA: nameA, valueB: nameB)
                let value: Int = nameA.getLevenshtein(to: nameB)
                levenshteinDistances.append((key, value))
            }
        }
        levenshteinDistances = levenshteinDistances.sorted(by: { (lValue, rValue) -> Bool in
            lValue.1 < rValue.1
        })
    }

    private func mostSimilarProductName(for name: String) -> String? {
        levenshteinDistances.first { $0.pair.contains(name) }?.pair.pair(of: name)
    }

    func deleteSelected() {
        try? productService.deleteProducts(by: selection.map { $0.id })
        selection.removeAll()
    }

    func product(for productId: Int) -> Product? {
        products.first(where: { $0.productId == productId })
    }

    func toggleEditMode() {
        isEditMode.toggle()
    }

    private func setupSubscriptions() {
        productService.dataSetUpdate
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }
}

// MARK: - Localized Strings

extension ProductListViewModel {

    var localizedTitle: String {
        .productListScreenTitle
    }

    var localizedEditButtonTitle: String {
        if isEditMode {
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