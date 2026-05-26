import Foundation

struct Expense: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var amount: Double
    var category: ExpenseCategory
    var date: Date
}
