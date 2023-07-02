//
//  GetLevenshteinDistancesUseCase.swift
//  ProductCatalog
//
//  Created by Eszenyi Gábor on 2023. 07. 02..
//

import Foundation

protocol GetLevenshteinDistancesUseCaseProtocol {

    func callAsFunction(for strings: [String]) -> [(pair: StringPair, distance: Int)]
}

class GetLevenshteinDistancesUseCase: GetLevenshteinDistancesUseCaseProtocol {
    
    func callAsFunction(for strings: [String]) -> [(pair: StringPair, distance: Int)] {

        var distances: [(pair: StringPair, distance: Int)] = []
        guard 2 <= strings.count else { return [] }
        for i in 0 ..< strings.count - 1 {
            for j in i + 1 ..< strings.count {
                if i == j { continue }
                let stringA = strings[i]
                let stringB = strings[j]
                let key: StringPair = .init(valueA: stringA, valueB: stringB)
                let value: Int = stringA.getLevenshtein(to: stringB)
                distances.append((key, value))
            }
        }
        distances = distances.sorted(by: { (lValue, rValue) -> Bool in
            lValue.1 < rValue.1
        })
        return distances
    }
}
