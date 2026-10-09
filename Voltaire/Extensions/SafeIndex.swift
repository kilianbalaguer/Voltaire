//
//  SafeIndex.swift
//  Picasso
//
//  Created by Kilian Balaguer on 10/7/26.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
    /// Safely get an item from a Collection. Returns `nil` when the collection does not contain the given index.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
