import XCTest
@testable import ExpenseTracker

@MainActor
final class ExpenseViewModelTests: XCTestCase {

    var viewModel: ExpenseViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ExpenseViewModel()
        viewModel.expenses = [] // clean state
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testAddExpense() {
        viewModel.addExpense(
            title: "Food",
            amount: 200,
            category: .food
        )

        XCTAssertEqual(viewModel.expenses.count, 1)
        XCTAssertEqual(viewModel.expenses.first?.title, "Food")
    }

    func testDeleteExpense() {
        viewModel.addExpense(title: "Travel", amount: 500, category: .travel)

        viewModel.deleteExpense(at: IndexSet(integer: 0))

        XCTAssertTrue(viewModel.expenses.isEmpty)
    }

    func testMonthlyTotal() {
        let date = Date()

        viewModel.addExpense(
            title: "Shopping",
            amount: 1000,
            category: .shopping,
            date: date
        )

        let total = viewModel.monthlyTotal(for: date)
        XCTAssertEqual(total, 1000)
    }

    func testTotalByCategory() {
        viewModel.addExpense(title: "Food", amount: 200, category: .food)
        viewModel.addExpense(title: "Food", amount: 300, category: .food)

        let total = viewModel.totalByCategory(.food)
        XCTAssertEqual(total, 500)
    }
}
