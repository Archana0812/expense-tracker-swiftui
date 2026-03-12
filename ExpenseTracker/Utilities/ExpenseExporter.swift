import Foundation
import UIKit

struct ExpenseExporter {

    // ✅ CSV Export
    static func exportCSV(expenses: [Expense]) -> URL? {
        var csv = "Title,Amount,Category,Date\n"

        let formatter = DateFormatter()
        formatter.dateStyle = .short

        for e in expenses {
            csv += "\(e.title),\(e.amount),\(e.category.rawValue),\(formatter.string(from: e.date))\n"
        }

        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("Expenses.csv")

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("CSV export failed:", error)
            return nil
        }
    }

    static func exportPDF(total: Double) -> URL? {

            let pdfRenderer = UIGraphicsPDFRenderer(
                bounds: CGRect(x: 0, y: 0, width: 300, height: 200)
            )

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("MonthlySummary.pdf")

            do {
                try pdfRenderer.writePDF(to: url) { context in
                    context.beginPage()

                    let text = "Monthly Expense Total\n₹\(total)"
                    text.draw(
                        at: CGPoint(x: 40, y: 80),
                        withAttributes: [
                            .font: UIFont.systemFont(ofSize: 18)
                        ]
                    )
                }
                return url

            } catch {
                print("❌ PDF export failed:", error)
                return nil
            }
        }
}
