import SwiftUI
import FirebaseAuth

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var amount: String
    @State private var category: ExpenseCategory
    @State private var date: Date

    private let expense: Expense
    private let expenseVM = ExpenseViewModel()
    private let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""

    init(expense: Expense) {
        self.expense = expense
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
        _category = State(initialValue: expense.category)
        _date = State(initialValue: expense.date)
    }

    var body: some View {
        Form {
            Section("Expense Info") {
                TextField("Title", text: $title)

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)

                Picker("Category", selection: $category) {
                    ForEach(ExpenseCategory.allCases) { cat in
                        Text(cat.rawValue).tag(cat)
                    }
                }

                DatePicker("Date", selection: $date, displayedComponents: .date)
            }

            Button(action: saveExpense) {
                Text("Update Expense")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .navigationTitle("Edit Expense")
    }

    private func saveExpense() {
        let updatedExpense = Expense(
            id: expense.id,
            title: title,
            amount: Double(amount) ?? expense.amount,
            category: category,
            date: date
        )

        expenseVM.updateExpense(updatedExpense, userId: userId)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditExpenseView(
            expense: Expense(
                title: "Movie ticket",
                amount: 12,
                category: .other,
                date: Date()
            )
        )
    }
}
