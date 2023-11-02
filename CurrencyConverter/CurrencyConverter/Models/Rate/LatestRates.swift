//
//  LatestRates.swift
//  CurrencyConverter
//
//  Created by Pavel Boltromyuk on 2.11.23.
//

import Foundation

struct LatestRates: Decodable {
    let success: Bool
    let rates: [String: Float]
}
