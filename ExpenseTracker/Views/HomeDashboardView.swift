//
//  DashboardView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//
import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @StateObject private var expenseVM = ExpenseViewModel()
    @StateObject private var budgetVM = BudgetViewModel()
    private let userId = FirebaseManager.shared.auth.currentUser?.uid ?? ""

    var body: some View {
        TabView {
            HomeView(expenseVM: expenseVM, userId: userId)
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            NavigationStack {
                ChartView(expenses: expenseVM.expenses)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .tint(.appBlue)
        .onAppear {
            expenseVM.fetchExpenses(userId: userId)
            budgetVM.fetchBudget(userId: userId)
        }
    }
}

private struct HomeView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    let userId: String

    @State private var selectedDate = Date()

    private var displayedExpenses: [Expense] {
        let calendar = Calendar.current
        return expenseVM.expenses
            .filter { calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }
            .sorted { $0.date < $1.date }
    }

    private var groupedExpenses: [(date: Date, expenses: [Expense])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: displayedExpenses) { expense in
            calendar.startOfDay(for: expense.date)
        }

        return groups
            .map { (date: $0.key, expenses: $0.value.sorted { $0.date < $1.date }) }
            .sorted { $0.date < $1.date }
    }

    private var balance: Double {
        -displayedExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    CalendarHeader(selectedDate: $selectedDate)

                    Text("My Balance \(formatSignedCurrency(balance))")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.white)

                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            if groupedExpenses.isEmpty {
                                EmptyExpenseState()
                            } else {
                                ForEach(groupedExpenses, id: \.date) { group in
                                    DayExpenseGroup(
                                        date: group.date,
                                        expenses: group.expenses,
                                        userId: userId,
                                        expenseVM: expenseVM
                                    )
                                }
                            }
                        }
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddExpenseView(date: selectedDate)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .accessibilityLabel("Add expense")
                }
            }
        }
    }

    private func formatSignedCurrency(_ amount: Double) -> String {
        let sign = amount < 0 ? "-" : ""
        return "\(sign)₹\(String(format: "%.1f", abs(amount)))"
    }
}

private struct CalendarHeader: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    private var monthDates: [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) ?? selectedDate
        let range = calendar.range(of: .day, in: .month, for: startOfMonth) ?? 1..<1

        return range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }

    private var monthOptions: [Date] {
        let components = calendar.dateComponents([.year], from: selectedDate)
        let startOfYear = calendar.date(from: components) ?? selectedDate

        return (0..<12).compactMap { monthOffset in
            calendar.date(byAdding: .month, value: monthOffset, to: startOfYear)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Menu {
                    ForEach(monthOptions, id: \.self) { month in
                        Button(monthTitle(for: month)) {
                            selectMonth(month)
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(monthTitle(for: selectedDate))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.appBlue)
                }

                HStack {
                    Button(previousMonthTitle) {
                        moveMonth(by: -1)
                    }
                    .foregroundStyle(Color(.systemGray4))

                    Spacer()

                    Button(nextMonthTitle) {
                        moveMonth(by: 1)
                    }
                    .foregroundStyle(Color(.systemGray4))
                }
                .font(.system(size: 15, weight: .regular))
                .buttonStyle(.plain)
            }
            .padding(.top, 8)
            .padding(.horizontal, 24)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        ForEach(monthDates, id: \.self) { date in
                            DatePickerItem(
                                date: date,
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                            ) {
                                selectedDate = date
                            }
                            .id(dateId(for: date))
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .onAppear {
                    proxy.scrollTo(dateId(for: selectedDate), anchor: .center)
                }
                .onChange(of: selectedDate) { _, newValue in
                    withAnimation(.snappy) {
                        proxy.scrollTo(dateId(for: newValue), anchor: .center)
                    }
                }
            }
            .padding(.bottom, 18)
        }
        .background(Color.white)
    }

    private var previousMonthTitle: String {
        monthTitle(for: calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate)
    }

    private var nextMonthTitle: String {
        monthTitle(for: calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate)
    }

    private func monthTitle(for date: Date) -> String {
        date.formatted(.dateTime.month(.wide).year())
    }

    private func moveMonth(by value: Int) {
        guard let month = calendar.date(byAdding: .month, value: value, to: selectedDate) else {
            return
        }

        selectMonth(month)
    }

    private func selectMonth(_ month: Date) {
        let selectedDay = calendar.component(.day, from: selectedDate)
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) ?? month
        let monthRange = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<1
        let clampedDay = min(selectedDay, monthRange.count)

        selectedDate = calendar.date(byAdding: .day, value: clampedDay - 1, to: monthStart) ?? monthStart
    }

    private func dateId(for date: Date) -> String {
        date.formatted(.iso8601.year().month().day())
    }
}

private struct DatePickerItem: View {
    let date: Date
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 13))
                    .foregroundStyle(isSelected ? Color.appBlue : .secondary)

                Text(date.formatted(.dateTime.day()))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? .white : .primary)
                    .frame(width: 30, height: 30)
                    .background {
                        Circle()
                            .fill(isSelected ? Color.appBlue : Color.clear)
                    }
            }
            .frame(width: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct DayExpenseGroup: View {
    let date: Date
    let expenses: [Expense]
    let userId: String
    @ObservedObject var expenseVM: ExpenseViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text(date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day().year()))
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(Color(.systemGroupedBackground))

            ForEach(expenses) { expense in
                ExpenseListRow(
                    expense: expense,
                    userId: userId,
                    expenseVM: expenseVM
                )

                if expense.id != expenses.last?.id {
                    Divider()
                        .padding(.leading, 108)
                }
            }
        }
    }
}

private struct ExpenseListRow: View {
    let expense: Expense
    let userId: String
    @ObservedObject var expenseVM: ExpenseViewModel

    var body: some View {
        HStack(spacing: 16) {
            NavigationLink {
                EditExpenseView(expense: expense)
            } label: {
                HStack(spacing: 16) {
                    Text(icon(for: expense))
                        .font(.system(size: 44))
                        .frame(width: 58, height: 58)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(expense.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)

                        Text(categoryTitle(for: expense))
                            .font(.system(size: 14))
                            .foregroundStyle(Color(.systemGray2))
                    }

                    Spacer(minLength: 12)

                    Text("-₹\(expense.amount, specifier: "%.1f")")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button(role: .destructive) {
                expenseVM.deleteExpense(expense, userId: userId)
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.appBlue)
                    .frame(width: 28, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete \(expense.title)")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(Color.white)
    }

    private func icon(for expense: Expense) -> String {
        switch expense.category {
        case .food:
            return expense.title.localizedCaseInsensitiveContains("pharmacy") ? "🧃" : "🍿"
        case .travel:
            return expense.title.localizedCaseInsensitiveContains("bus") ? "🚌" : "✈️"
        case .shopping:
            return "🛍️"
        case .bills:
            return "🏠"
        case .health:
            return "🥗"
        case .other:
            return "💳"
        }
    }

    private func categoryTitle(for expense: Expense) -> String {
        switch expense.category {
        case .travel:
            return "Transportation"
        case .bills:
            return expense.title.localizedCaseInsensitiveContains("electric") ? "Home" : expense.category.rawValue
        default:
            return expense.category.rawValue
        }
    }
}

private struct EmptyExpenseState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 34))
                .foregroundStyle(Color(.systemGray3))

            Text("No expenses this month")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

private extension Color {
    static var appBlue: Color {
        Color(red: 0.12, green: 0.48, blue: 0.76)
    }
}

#Preview {
    DashboardView()
}
