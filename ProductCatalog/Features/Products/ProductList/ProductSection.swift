//
//  ProductSection.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 02..
//

import SwiftUI

struct ProductSection: View {

    let viewData: ProductSectionViewData
    @Binding var isEditing: Bool

    // MARK: - LEVEL 0 Views: Body & Content Wrapper (Main Containers)

    var body: some View {
        content
    }

    var content: some View {
        Section(
            content: sectionContent,
            header: sectionHeader
        )
    }

    // MARK: - LEVEL 1 Views: Main UI Elements

    func sectionHeader() -> some View {
        Text(viewData.headerTitle)
    }

    func sectionContent() -> some View {
        ForEach(
            viewData.products,
            content: rowContent
        )
    }

    // MARK: - LEVEL 2 Views: Helpers & Other Subcomponents

    func rowContent(_ viewData: ProductViewData) -> some View {
        ProductView(
            viewData: viewData,
            isEditing: $isEditing
        )
    }
}
