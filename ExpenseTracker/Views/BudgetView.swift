//
//  BudgetView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct BudgetView: View {
    @State private var amount = ""
    let budgetVM = BudgetViewModel()
    let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""

    var body: some View {
        Form {
            TextField("Monthly Budget", text: $amount)
                .keyboardType(.decimalPad)

            Button("Save") {
                budgetVM.saveBudget(
                    userId: userId,
                    amount: Double(amount) ?? 0
                )
            }
        }
        .navigationTitle("Budget")
    }
}
