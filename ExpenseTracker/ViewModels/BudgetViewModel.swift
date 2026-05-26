//
//  BudgetViewModel.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import Combine
import FirebaseFirestore
import SwiftUI

class BudgetViewModel: ObservableObject {
    @Published var budget: Double = 0
    private let db = FirebaseManager.shared.db

    func saveBudget(userId: String, amount: Double) {
        db.collection("users")
            .document(userId)
            .setData(["budget": amount], merge: true)
    }

    func fetchBudget(userId: String) {
        db.collection("users")
            .document(userId)
            .addSnapshotListener { snap, _ in
                self.budget = snap?.data()?["budget"] as? Double ?? 0
            }
    }
}
