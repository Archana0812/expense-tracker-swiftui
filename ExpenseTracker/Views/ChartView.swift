//
//  ChartView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import SwiftUI
import Charts

struct ChartView: View {
    enum ViewMode: String, CaseIterable, Identifiable {
        case stats = "Stats"
        case budget = "Budget"

        var id: String { rawValue }
    }

    let expenses: [Expense]

    @State private var selectedDate = Date()
    @State private var selectedMode: ViewMode = .stats

    private var monthExpenses: [Expense] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, equalTo: selectedDate, toGranularity: .month) }
    }

    private var categoryStats: [ExpenseCategoryStat] {
        let groups = Dictionary(grouping: monthExpenses, by: ExpenseCategoryStat.groupName(for:))
        let total = monthExpenses.reduce(0) { $0 + $1.amount }

        return groups.map { name, expenses in
            let amount = expenses.reduce(0) { $0 + $1.amount }
            return ExpenseCategoryStat(
                name: name,
                amount: amount,
                percentage: total > 0 ? amount / total : 0,
                icon: ExpenseCategoryStat.icon(for: name),
                color: ExpenseCategoryStat.color(for: name)
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Picker("", selection: $selectedMode) {
                    ForEach(ViewMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 210)
                .padding(.vertical, 20)
                .background(Color(.systemGroupedBackground))

                if selectedMode == .stats {
                    StatsContent(
                        selectedDate: $selectedDate,
                        categoryStats: categoryStats
                    )
                } else {
                    BudgetView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StatsContent: View {
    @Binding var selectedDate: Date
    let categoryStats: [ExpenseCategoryStat]

    var body: some View {
        VStack(spacing: 0) {
            StatsCalendarHeader(selectedDate: $selectedDate)

            ScrollView {
                VStack(spacing: 0) {
                    StatsPieChart(categoryStats: categoryStats)
                        .frame(height: 310)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)

                    LazyVStack(spacing: 0) {
                        if categoryStats.isEmpty {
                            StatsEmptyState()
                        } else {
                            ForEach(categoryStats) { stat in
                                CategoryStatRow(stat: stat)

                                if stat.id != categoryStats.last?.id {
                                    Divider()
                                        .padding(.leading, 112)
                                }
                            }
                        }
                    }
                    .background(Color.white)
                }
            }
        }
    }
}

private struct StatsPieChart: View {
    let categoryStats: [ExpenseCategoryStat]

    var body: some View {
        ZStack {
            if categoryStats.isEmpty {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 42)
                    .frame(width: 170, height: 170)

                Text("0%")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
            } else {
                Chart(categoryStats) { stat in
                    SectorMark(
                        angle: .value("Amount", stat.amount),
                        innerRadius: .ratio(0),
                        angularInset: 0
                    )
                    .foregroundStyle(stat.color)
                    .annotation(position: .overlay) {
                        if stat.percentage >= 0.15 {
                            Text(percentText(stat.percentage))
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.black.opacity(0.75))
                        }
                    }
                }
                .chartLegend(.hidden)
                .frame(width: 210, height: 210)

                ForEach(Array(categoryStats.prefix(4).enumerated()), id: \.element.id) { index, stat in
                    Text(stat.icon)
                        .font(.system(size: 34))
                        .offset(iconOffset(for: index))
                }
            }
        }
    }

    private func percentText(_ percentage: Double) -> String {
        if percentage < 0.1 {
            return "\(Int((percentage * 100).rounded()))%"
        }

        return "\(String(format: "%.1f", percentage * 100))%"
    }

    private func iconOffset(for index: Int) -> CGSize {
        switch index {
        case 0:
            return CGSize(width: -74, height: 116)
        case 1:
            return CGSize(width: -30, height: -126)
        case 2:
            return CGSize(width: 94, height: -86)
        default:
            return CGSize(width: 130, height: -28)
        }
    }
}

private struct CategoryStatRow: View {
    let stat: ExpenseCategoryStat

    var body: some View {
        HStack(spacing: 18) {
            Text(stat.icon)
                .font(.system(size: 56))
                .frame(width: 76, height: 76)

            VStack(alignment: .leading, spacing: 12) {
                Text(stat.name)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(percentText(stat.percentage))
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(Color(.systemGray3))
            }

            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .background(Color.white)
    }

    private func percentText(_ percentage: Double) -> String {
        if percentage < 0.1 {
            return "\(Int((percentage * 100).rounded()))%"
        }

        return "\(String(format: "%.1f", percentage * 100))%"
    }
}

private struct StatsEmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.pie")
                .font(.system(size: 34))
                .foregroundStyle(Color(.systemGray3))

            Text("No expenses this month")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct StatsCalendarHeader: View {
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    private var visibleDates: [Date] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) ?? selectedDate
        let weekdayOffset = calendar.component(.weekday, from: startOfMonth) - 1
        let start = calendar.date(byAdding: .day, value: -weekdayOffset, to: startOfMonth) ?? startOfMonth

        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    private var monthOptions: [Date] {
        let components = calendar.dateComponents([.year], from: selectedDate)
        let startOfYear = calendar.date(from: components) ?? selectedDate

        return (0..<12).compactMap { calendar.date(byAdding: .month, value: $0, to: startOfYear) }
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
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.statsBlue)
                }

                HStack {
                    Button(monthTitle(for: calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate)) {
                        moveMonth(by: -1)
                    }
                    .foregroundStyle(Color(.systemGray5))

                    Spacer()

                    Button(monthTitle(for: calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate)) {
                        moveMonth(by: 1)
                    }
                    .foregroundStyle(Color(.systemGray5))
                }
                .font(.system(size: 17, weight: .regular))
                .buttonStyle(.plain)
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            HStack(spacing: 0) {
                ForEach(visibleDates, id: \.self) { date in
                    VStack(spacing: 12) {
                        Text(date.formatted(.dateTime.weekday(.abbreviated)))
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)

                        Text(date.formatted(.dateTime.day()))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(calendar.isDate(date, equalTo: selectedDate, toGranularity: .month) ? .primary : .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 24)
        }
        .background(Color.white)
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
}

private struct ExpenseCategoryStat: Identifiable {
    let name: String
    let amount: Double
    let percentage: Double
    let icon: String
    let color: Color

    var id: String { name }

    nonisolated static func groupName(for expense: Expense) -> String {
        switch expense.category {
        case .food:
            return "Food"
        case .travel:
            return "Transportation"
        case .bills:
            return "Home"
        case .other:
            return expense.title.localizedCaseInsensitiveContains("movie") ? "Entertainment" : "Other"
        case .shopping:
            return "Shopping"
        case .health:
            return "Health"
        }
    }

    nonisolated static func icon(for name: String) -> String {
        switch name {
        case "Home":
            return "🏠"
        case "Food":
            return "🧃"
        case "Transportation":
            return "🚌"
        case "Entertainment":
            return "🍿"
        case "Shopping":
            return "🛍️"
        case "Health":
            return "🥗"
        default:
            return "💳"
        }
    }

    nonisolated static func color(for name: String) -> Color {
        switch name {
        case "Home":
            return Color(red: 0.73, green: 0.44, blue: 0.73)
        case "Food":
            return Color(red: 0.38, green: 0.93, blue: 0.93)
        case "Transportation":
            return Color(red: 0.68, green: 0.77, blue: 0.76)
        case "Entertainment":
            return Color(red: 1.0, green: 0.73, blue: 0.44)
        case "Shopping":
            return Color(red: 0.38, green: 0.64, blue: 0.97)
        case "Health":
            return Color(red: 0.48, green: 0.84, blue: 0.52)
        default:
            return Color(.systemGray3)
        }
    }
}

private extension Color {
    static var statsBlue: Color {
        Color(red: 0.12, green: 0.48, blue: 0.76)
    }
}

#Preview {
    NavigationStack {
        ChartView(
            expenses: [
                Expense(title: "Electricity bill", amount: 60, category: .bills, date: Date()),
                Expense(title: "Pharmacy", amount: 25, category: .food, date: Date()),
                Expense(title: "Bus fare", amount: 2, category: .travel, date: Date()),
                Expense(title: "Movie ticket", amount: 12, category: .other, date: Date())
            ]
        )
    }
}
