//
//  ContactsFeature.swift
//  TCAField1
//
//  Created by hn on 2025/11/10.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}

@Reducer
struct ContactsFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var destination: Destination.State?
        var contacts: IdentifiedArrayOf<Contact> = []
        var path = StackState<ContactDetailFeature.State>()
    }
    
    enum Action {
        case addButtonTapped
//        case deleteButtonTapped(id: Contact.ID)
        case destination(PresentationAction<Destination.Action>)
        @CasePathable
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
        case path(StackActionOf<ContactDetailFeature>)
    }
    
    @Dependency(\.uuid) var uuid
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                state.destination = .addContact(AddContactFeature.State(contact: Contact(id: self.uuid(), name: "")))
                return .none
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
                state.contacts.append(contact)
                return .none
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
                state.contacts.remove(id: id)
                return .none
            case .destination:
                return .none
//            case let .deleteButtonTapped(id: id):
//                state.destination = .alert(.deleteConfirmation(id: id))
//                return .none
            case let .path(.element(id: id, action: .delegate(.confirmDeletion))):
                guard let detailState = state.path[id: id] else { return .none }
                state.contacts.remove(id: detailState.contact.id)
                return .none
            case .path:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination.body
        }
        .forEach(\.path, action: \.path) {
            ContactDetailFeature()
        }
    }
}

extension AlertState where Action == ContactsFeature.Action.Alert {
    static func deleteConfirmation(id: UUID) -> Self {
        Self {
            TextState("Are you sure?")
        } actions: {
            ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                TextState("Delete")
            }
        }
    }
}

extension ContactsFeature {
    @Reducer
    enum Destination {
        case addContact(AddContactFeature)
        case alert(AlertState<ContactsFeature.Action.Alert>)
    }
}

extension ContactsFeature.Destination.State: Equatable {}

struct ContactsView: View {
    @Bindable var store: StoreOf<ContactsFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            List(store.contacts) { contact in
                NavigationLink(state: ContactDetailFeature.State(contact: contact)) {
                    HStack {
                        Text(contact.name)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundStyle(.red)

                    }
                }
                
                
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
        } destination: { store in
            ContactDetailView(store: store)
        }
        .sheet(item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)) { addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}

#Preview {
    ContactsView(store: Store(initialState: ContactsFeature.State(contacts: [
        Contact(id: UUID(), name: "Bob"),
        Contact(id: UUID(), name: "Paul"),
        Contact(id: UUID(), name: "Steve")
    ]), reducer: {
        ContactsFeature()
    }))
}


