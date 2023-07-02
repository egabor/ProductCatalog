//
//  Resolver+Registry.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 06. 29..
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {

    public static func registerAllServices() {

        registerProductDependencies()

        register { GetLevenshteinDistancesUseCase() }
            .implements(GetLevenshteinDistancesUseCaseProtocol.self)
    }
}
