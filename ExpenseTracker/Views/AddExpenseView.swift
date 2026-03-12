import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var category: ExpenseCategory = .food

    var body: some View {
        NavigationStack {
            Form {
                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                TextField("Expense Title", text: $title)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Expense")
            .toolbar {
                Button("Save") {
                    guard !title.isEmpty,
                        let value = Double(amount),
                        value > 0
                    else { return }

                    viewModel.addExpense(title: title, amount: value)
                    dismiss()
                }
            }
        }
    }
}
