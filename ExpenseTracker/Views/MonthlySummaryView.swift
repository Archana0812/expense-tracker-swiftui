import SwiftUI

struct MonthlySummaryView: View {

    @ObservedObject var viewModel: ExpenseViewModel

    @State private var selectedDate = Date()
    @State private var shareURL: URL?
    @State private var showShareSheet = false

    var body: some View {
        VStack(spacing: 20) {

            // MARK: - Month Picker
            DatePicker(
                "Select Month",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .padding()

            // MARK: - Monthly Total
            Text("Monthly Total")
                .font(.headline)

            Text(
                "₹\(viewModel.monthlyTotal(for: selectedDate), specifier: "%.2f")"
            )
            .font(.largeTitle)
            .fontWeight(.bold)

            Divider()

            // MARK: - Export Buttons
            VStack(spacing: 12) {

                Button {
                    shareURL = ExpenseExporter.exportCSV(
                        expenses: viewModel.expenses(for: selectedDate)
                    )
                } label: {
                    Label("Export CSV", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)

                Button {
                    shareURL = ExpenseExporter.exportPDF(
                        total: viewModel.monthlyTotal(for: selectedDate)
                    )
                    showShareSheet = true
                } label: {
                    Label("Export PDF", systemImage: "doc.richtext")
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Monthly Summary")
        .sheet(isPresented: $showShareSheet) {
            if let url = shareURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
}
