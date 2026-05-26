import Foundation

enum ExpenseCategory: String, CaseIterable, Codable, Identifiable {
    case food = "Food"
    case travel = "Travel"
    case shopping = "Shopping"
    case bills = "Bills"
    case health = "Health"
    case other = "Other"

    var id: String { rawValue }
}
