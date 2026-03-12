import SwiftUI

struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(expense.title)
                Text(expense.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text("₹\(expense.amount, specifier: "%.2f")")
        }
    }
}
