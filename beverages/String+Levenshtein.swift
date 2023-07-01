//
//  String+Levenshtein.swift
//  beverages
//
//  Created by Eszenyi Gábor on 2023. 07. 01..
//
//  Source: https://github.com/TheDarkCode/SwiftyLevenshtein/blob/master/Pod/Classes/SwiftyLevenshtein.swift

import Foundation

extension String {

    func getLevenshtein(to string: String) -> Int {
        levenshtein(sourceString: self, target: string)
    }

    private func min3(a: Int, b: Int, c: Int) -> Int {
        return min(min(a, c), min(b, c))
    }

    private struct Array2D {

        var columns: Int
        var rows: Int
        var matrix: [Int]

        init(columns: Int, rows: Int) {

            self.columns = columns
            self.rows = rows
            matrix = Array(repeating: 0, count: columns*rows)
        }

        subscript(column: Int, row: Int) -> Int {

            get {
                matrix[columns * row + column]
            }

            set {
                matrix[columns * row + column] = newValue
            }
        }
    }


    private func levenshtein(sourceString: String, target targetString: String) -> Int {

        let source = Array(sourceString.unicodeScalars)
        let target = Array(targetString.unicodeScalars)

        let (sourceLength, targetLength) = (source.count, target.count)

        var distance = Array2D(columns: sourceLength + 1, rows: targetLength + 1)

        for x in 1...sourceLength {
            distance[x, 0] = x
        }

        for y in 1...targetLength {
            distance[0, y] = y
        }

        for x in 1...sourceLength {
            for y in 1...targetLength {
                if source[x - 1] == target[y - 1] {
                    // no difference
                    distance[x, y] = distance[x - 1, y - 1]
                } else {
                    distance[x, y] = min3(
                        // deletions
                        a: distance[x - 1, y] + 1,
                        // insertions
                        b: distance[x, y - 1] + 1,
                        // substitutions
                        c: distance[x - 1, y - 1] + 1
                    )
                }
            }
        }
        return distance[source.count, target.count]
    }
}
