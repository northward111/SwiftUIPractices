//
//  EditView.swift
//  HotProspects
//
//  Created by hn on 2025/11/3.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Bindable var prospect: Prospect
    var body: some View {
        Form {
            TextField("Name", text: $prospect.name)
            TextField("Email address", text: $prospect.emailAddress)
            Text(prospect.createDate?.formatted(date: .numeric, time: .standard) ?? "Unknown")
            Button("Save", systemImage: "square.and.arrow.down", action: save)
        }
        .navigationTitle("Edit")
    }
    
    func save() {
        dismiss()
    }
}

#Preview {
    EditView(prospect: .example())
}
