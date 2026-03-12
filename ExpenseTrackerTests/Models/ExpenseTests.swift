import XCTest
@testable import ExpenseTracker
@MainActor
final class ExpenseTests: XCTestCase {

    func testExpenseInitialization() {
        let date = Date()
        let expense = Expense(
            title: "Lunch",
            amount: 250,
            date: date,
            category: .food
        )

        XCTAssertNotNil(expense.id)
        XCTAssertEqual(expense.title, "Lunch")
        XCTAssertEqual(expense.amount, 250)
        XCTAssertEqual(expense.date, date)
        XCTAssertEqual(expense.category, .food)
    }

    func testExpenseIsCodable() throws {
        let expense = Expense(
            title: "Travel",
            amount: 1000,
            category: .travel
        )

        let data = try JSONEncoder().encode(expense)
        let decoded = try JSONDecoder().decode(Expense.self, from: data)

        XCTAssertEqual(decoded.title, expense.title)
        XCTAssertEqual(decoded.amount, expense.amount)
        XCTAssertEqual(decoded.category, expense.category)
    }
}
