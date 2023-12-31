//
//  Resolver+Product.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 30..
//

import Foundation
import Resolver

extension Resolver {

    static func registerProductDependencies() {

        register { ProductService() }
            .implements(ProductServiceProtocol.self)
            .scope(.application)
    }
}
