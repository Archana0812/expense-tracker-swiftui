import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    let title: String
    let amount: Double
    let date: Date
    let category: ExpenseCategory

    init(title: String, amount: Double, date: Date = Date(), category: ExpenseCategory) {
        self.id = UUID()
        self.title = title
        self.amount = amount
        self.date = date
        self.category = category
    }
}
