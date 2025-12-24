//
//  ContentView.swift
//  iExpense
//
//  Created by hn on 2025/9/22.
//

import SwiftData
import SwiftUI



struct ContentView: View {
    static let orderName = [SortDescriptor(\ExpenseItem.name), SortDescriptor(\ExpenseItem.amount, order: .reverse)]
    static let orderAmount = [
        SortDescriptor(\ExpenseItem.amount, order: .reverse),
        SortDescriptor(\ExpenseItem.name)
    ]
    @Environment(\.modelContext) var modelContext
    @State private var filterOption = FilterOption.All
    @State private var sortOrder = orderName
    @Query var expenses: [ExpenseItem]
    var body: some View {
        NavigationStack {
            ExpenseView(filterOption:filterOption, sortOrder: sortOrder)
            .toolbar(content: {
                NavigationLink("Add") {
                    AddView()
                }
                Menu("Sort") {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Sort by Name")
                            .tag(Self.orderName)
                        Text("Sort by Amount")
                            .tag(Self.orderAmount)
                    }
                }
                Menu("Filter") {
                    Picker("Filter", selection: $filterOption) {
                        Text("Personal Only")
                            .tag(FilterOption.Personal)
                        Text("Business Only")
                            .tag(FilterOption.Business)
                        Text("All")
                            .tag(FilterOption.All)
                    }
                }
            })
            .navigationTitle("iExpense")
        }
    }
    
    func removeExpenses(at indices: IndexSet) {
        for index in indices {
            modelContext.delete(expenses[index])
        }
    }
}

#Preview {
    ContentView()
}
