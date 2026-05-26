//
//  CurrencyHelper.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import Foundation
struct CurrencyHelper {
    static func symbol(_ code: String) -> String {
        Locale
            .availableIdentifiers
            .compactMap { Locale(identifier: $0) }
            .first { $0.currency?.identifier == code }?
            .currencySymbol ?? "₹"
    }
}
