import SwiftUI

struct ExpenseListView: View {
    @StateObject var viewModel = ExpenseViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.expenses) { expense in
                        HStack {
                            Text(expense.title)
                            Spacer()
                            Text("₹\(expense.amount, specifier: "%.2f")")
                        }
                    }
                    .onDelete(perform: viewModel.deleteExpense)
                }
                NavigationLink(
                    "View Monthly Summary",
                    destination: MonthlySummaryView(viewModel: viewModel)
                )
                .padding()
                .navigationTitle("Expenses")
                .toolbar {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                .sheet(isPresented: $showAdd) {
                    AddExpenseView(viewModel: viewModel)
                }
            }

        }
    }
}
