//
//  StringPair.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//

import Foundation

struct StringPair: Equatable, Hashable {

    let valueA: String
    let valueB: String

    static func ==(lhs: StringPair, rhs: StringPair) -> Bool {
        (lhs.valueA == rhs.valueB && lhs.valueB == rhs.valueA) ||
        (lhs.valueA == rhs.valueA && lhs.valueA == rhs.valueA)
    }

    func hash(into hasher: inout Hasher) {

        var set = Set<String>()
        set.insert(valueA)
        set.insert(valueB)
        hasher.combine(set)
    }

    func contains(_ value: String) -> Bool {

        if valueA == value || valueB == value {
            return true
        }
        return false
    }

    func pair(of value: String) -> String? {

        if value == valueA {
            return valueB
        } else if value == valueB {
            return valueA
        }
        return nil
    }
}
