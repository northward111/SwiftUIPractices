//
//  iExpenseApp.swift
//  iExpense
//
//  Created by hn on 2025/9/22.
//

import SwiftData
import SwiftUI

@main
struct iExpenseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: ExpenseItem.self)
    }
}
