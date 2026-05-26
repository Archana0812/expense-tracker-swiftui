//
//  CategoryChartView.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import SwiftUI
import Charts

struct CategoryChartView: View {
    let expenses: [Expense]

    var body: some View {
        Chart {
            ForEach(ExpenseCategory.allCases) { category in
                let total = expenses
                    .filter { $0.category == category }
                    .reduce(0) { $0 + $1.amount }

                if total > 0 {
                    SectorMark(
                        angle: .value("Amount", total),
                        innerRadius: .ratio(0.5)
                    )
                    .foregroundStyle(by: .value("Category", category.rawValue))
                }
            }
        }
        .navigationTitle("Category Breakdown")
    }
}
