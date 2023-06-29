//
//  ProductListScreen.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import SwiftUI

struct ProductListScreen: View {

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .navigationTitle("Products") // TODO: Localize
            .toolbar(content: addNewProductButton)
    }

    func addNewProductButton() -> some View {
        NavigationLink {
            ProductDetailsScreen()
        } label: {
            Image(systemName: "plus") // TODO: Move to constant
        }
    }
}

struct ProductListScreen_Previews: PreviewProvider {
    static var previews: some View {
        ProductListScreen()
    }
}
