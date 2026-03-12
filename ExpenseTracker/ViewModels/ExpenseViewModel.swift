import Combine
import Foundation
import SwiftUI

@MainActor
final class ExpenseViewModel: ObservableObject {

    // MARK: - Properties
    @Published var expenses: [Expense] = []

    private let storageKey = "expenses_key"

    // MARK: - Init
    init() {
        loadExpenses()
    }

    // MARK: - CRUD Operations
    func addExpense(
        title: String,
        amount: Double,
        category: ExpenseCategory = .others,
        date: Date = Date()
    ) {
        let newExpense = Expense(
            title: title,
            amount: amount,
            date: date,
            category: category
        )
        expenses.append(newExpense)
        saveExpenses()
    }

    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
        saveExpenses()
    }

    // MARK: - Calculations

    /// Total of all expenses
    func totalAmount() -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }

    /// Monthly total for selected date
    func monthlyTotal(for date: Date) -> Double {
        let calendar = Calendar.current

        return expenses.filter {
            calendar.isDate($0.date, equalTo: date, toGranularity: .month)
        }
        .reduce(0) { $0 + $1.amount }
    }

    /// Total by category (for charts)
    func totalByCategory(_ category: ExpenseCategory) -> Double {
        expenses
            .filter { $0.category == category }
            .reduce(0) { $0 + $1.amount }
    }

    /// Expenses for selected month
    func expenses(for date: Date) -> [Expense] {
        let calendar = Calendar.current

        return expenses.filter {
            calendar.isDate($0.date, equalTo: date, toGranularity: .month)
        }
    }

    // MARK: - Persistence (UserDefaults)
    @MainActor
    private func saveExpenses() {
        do {
            let encoded = try JSONEncoder().encode(expenses)
            UserDefaults.standard.set(encoded, forKey: storageKey)
        } catch {
            print("❌ Failed to save expenses:", error)
        }
    }
    
    @MainActor
    private func loadExpenses() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }

        do {
            expenses = try JSONDecoder().decode([Expense].self, from: data)
        } catch {
            print("❌ Failed to load expenses:", error)
        }
    }
}
