import XCTest
@testable import ExpenseTracker

final class ExpenseExporterTests: XCTestCase {

    func testCSVExportCreatesFile() {
        let expenses = [
            Expense(title: "Food", amount: 200, category: .food),
            Expense(title: "Bills", amount: 500, category: .bills)
        ]

        let url = ExpenseExporter.exportCSV(expenses: expenses)

        XCTAssertNotNil(url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url!.path))
    }

    func testCSVExportContent() throws {
        let expenses = [
            Expense(title: "Shopping", amount: 1500, category: .shopping)
        ]

        guard let url = ExpenseExporter.exportCSV(expenses: expenses) else {
            XCTFail("CSV URL is nil")
            return
        }

        let content = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(content.contains("Title,Amount,Category,Date"))
        XCTAssertTrue(content.contains("Shopping"))
        XCTAssertTrue(content.contains("1500"))
        XCTAssertTrue(content.contains("Shopping"))
    }
}
