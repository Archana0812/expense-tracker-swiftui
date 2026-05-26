import FirebaseFirestore
import SwiftUI
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    private let db = FirebaseManager.shared.db

    func fetchExpenses(userId: String) {
        db.collection("users")
            .document(userId)
            .collection("expenses")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, _ in
                self.expenses = snapshot?.documents.compactMap {
                    try? $0.data(as: Expense.self)
                } ?? []
            }
    }

    func addExpense(_ expense: Expense, userId: String) {
        try? db.collection("users")
            .document(userId)
            .collection("expenses")
            .document(expense.id)
            .setData(from: expense)
    }

    func updateExpense(_ expense: Expense, userId: String) {
        try? db.collection("users")
            .document(userId)
            .collection("expenses")
            .document(expense.id)
            .setData(from: expense, merge: true)
    }

    func deleteExpense(_ expense: Expense, userId: String) {
        db.collection("users")
            .document(userId)
            .collection("expenses")
            .document(expense.id)
            .delete()
    }
}
