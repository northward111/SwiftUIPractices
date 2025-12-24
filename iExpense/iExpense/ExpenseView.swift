//
//  ExpenseView.swift
//  iExpense
//
//  Created by hn on 2025/10/28.
//

import SwiftData
import SwiftUI

enum FilterOption: String {
    case Personal = "Personal"
    case Business = "Business"
    case All
}

let currencyCode = Locale.current.currency?.identifier ?? "USD"

struct ExpenseCell: View {
    let item: ExpenseItem
    var body: some View {
        HStack {
            VStack(alignment: .leading, content: {
                Text(item.name)
                    .font(.headline)
                Text(item.type)
            })
            Spacer()
            Text(item.amount, format: .currency(code: currencyCode))
                .foregroundStyle(item.amount < 10 ? .blue : (item.amount < 100 ? .green : .red))
        }
        .accessibilityElement()
        .accessibilityLabel("\(item.name): \(item.amount)")
        .accessibilityHint(item.type)
    }
}

struct ExpenseView: View {
    @Environment(\.modelContext) var modelContext
    @Query var expenses: [ExpenseItem]
    var body: some View {
        List {
            ForEach(expenses) { item in
                ExpenseCell(item: item)
            }
            .onDelete { removeExpenses(at: $0) }
        }
    }
    
    func removeExpenses(at indices: IndexSet) {
        for index in indices {
            modelContext.delete(expenses[index])
        }
    }
    
    init(filterOption: FilterOption, sortOrder: [SortDescriptor<ExpenseItem>]) {
        if filterOption == .All {
            _expenses = Query(sort: sortOrder)
        }else {
            let typeValue = filterOption.rawValue
            _expenses = Query(filter:#Predicate<ExpenseItem> { expense in
                expense.type == typeValue
            }, sort: sortOrder)
        }
    }
}
