//
//  Symbols.swift
//  CurrencyConverter
//
//  Created by Pavel Boltromyuk on 2.11.23.
//

import Foundation

struct Symbols: Decodable {
    let success: Bool
    let symbols: [String: String]
}
