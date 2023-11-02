//
//  Constants.swift
//  CurrencyConverter
//
//  Created by Pavel Boltromyuk on 2.11.23.
//

import Foundation

struct Constants {
    static let apiUrl = URL(string: "http://api.exchangeratesapi.io/v1")
    static let symbolsUrl = apiUrl?.appendingPathComponent("symbols")
    static let rateUrl = apiUrl?.appendingPathComponent("latest")
    
    static let accessKey = "b642e7cb1535cb458d4d0eb702322c88"
}
