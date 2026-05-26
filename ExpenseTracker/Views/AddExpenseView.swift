import SwiftUI
import FirebaseAuth

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var category: ExpenseCategory = .food
    @State private var date: Date

    let expenseVM = ExpenseViewModel()
    let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""

    init(date: Date = Date()) {
        _date = State(initialValue: date)
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

            Button(action: {
                let expense = Expense(
                    title: title,
                    amount: Double(amount) ?? 0,
                    category: category,
                    date: date
                )

                expenseVM.addExpense(expense, userId: userId)
                dismiss()
            }) {
                Text("Save Expense")
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
        .navigationTitle("Add Expense")
    }
}
