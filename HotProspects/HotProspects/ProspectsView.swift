//
//  ProspectsView.swift
//  HotProspects
//
//  Created by hn on 2025/11/2.
//

import CodeScanner
import SwiftData
import SwiftUI
import UserNotifications

enum FilterType {
    case none, contacted, uncontacted
}

struct ProspectCell: View {
    let isShowingContactedMark: Bool
    let prospect: Prospect
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(prospect.name)
                    .font(.headline)
                Text(prospect.emailAddress)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isShowingContactedMark {
                Image(systemName: prospect.isContacted ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.fill.badge.xmark")
            }
        }
    }
}

struct ProspectList: View {
    @Environment(\.modelContext) var modelContext
    @Query var prospects: [Prospect]
    @Binding var selectedProspects: Set<Prospect>
    @State private var isShowingScanner = false
    let filter: FilterType
    var body: some View {
        List(selection: $selectedProspects) {
            ForEach(prospects){ prospect in
                NavigationLink(destination: {
                    EditView(prospect: prospect)
                }, label: {
                    ProspectCell(isShowingContactedMark: filter == .none, prospect: prospect)
                })
                .tag(prospect)
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(prospect)
                    }
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    }else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)
                        Button("Remind me", systemImage: "bell") {
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
            }
            if selectedProspects.isEmpty == false {
                ToolbarItem(placement: .bottomBar) {
                    Button("Delete Selected", action: delete)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Scan", systemImage: "qrcode.viewfinder") {
                    isShowingScanner = true
                }
            }
        }
        .sheet(isPresented: $isShowingScanner) {
            CodeScannerView(codeTypes: [.qr],simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
        }
    }
    
    init(filter: FilterType, sortOrder: [SortDescriptor<Prospect>], selectedProspects: Binding<Set<Prospect>>) {
        self.filter = filter
        _selectedProspects = selectedProspects
        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate<Prospect> {prospect in
                prospect.isContacted == showContactedOnly
            }, sort: sortOrder)
        } else {
            _prospects = Query(sort: sortOrder)
        }
    }
    
    func delete() {
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
        selectedProspects.removeAll()
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            }else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    }else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else {
                return
            }
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            person.createDate = .now
            print("\(person.createDate?.description ?? "")")
            modelContext.insert(person)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

struct ProspectsView: View {
    @State private var selectedProspects: Set<Prospect> = []
    @State private var sortOrder = [SortDescriptor(\Prospect.name)]
    let filter: FilterType
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted people"
        case .uncontacted:
            "Uncontacted people"
        }
    }
    var body: some View {
        NavigationStack {
            ProspectList(filter: filter, sortOrder: sortOrder, selectedProspects: $selectedProspects)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement:.topBarTrailing) {
                    Picker("Sort", selection: $sortOrder) {
                        Text("Name")
                            .tag([SortDescriptor(\Prospect.name)])
                        Text("Recent")
                            .tag([SortDescriptor(\Prospect.createDate, order: .reverse)])
                    }
                }
            }
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
}
