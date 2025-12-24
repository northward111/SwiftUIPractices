//
//  ContactsFeatureTests.swift
//  TCAField1Tests
//
//  Created by hn on 2025/11/12.
//

import ComposableArchitecture
import Foundation
import Testing
@testable import TCAField1

@MainActor
struct ContactsFeatureTests {
    @Test func addFlow() async throws {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: { dependencyValues in
            dependencyValues.uuid = .incrementing
        }
        await store.send(.addButtonTapped) { state in
            state.destination = .addContact(
                AddContactFeature.State(contact: Contact(id: UUID(0), name: ""))
            )
        }
        
        await store.send(\.destination.addContact.setName, "Blob Jr.") { state in
            state.destination?.modify(\.addContact) {
                $0.contact.name = "Blob Jr."
            }
        }
        
        await store.send(\.destination.addContact.saveButtonTapped)
        
        await store.receive(\.destination.addContact.delegate.saveContact, Contact(id: UUID(0), name: "Blob Jr.")) { state in
            state.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
        }
        
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
        
    }
    
    @Test func addFlowNonExhaustive() async throws {
        let store = TestStore(initialState: ContactsFeature.State()) {
            ContactsFeature()
        } withDependencies: { dependencyValues in
            dependencyValues.uuid = .incrementing
        }
        store.exhaustivity = .off
        await store.send(.addButtonTapped)
        await store.send(\.destination.addContact.setName, "Blob Jr.")
        await store.send(\.destination.addContact.saveButtonTapped)
        await store.skipReceivedActions()
        store.assert { state in
            state.contacts = [
                Contact(id: UUID(0), name: "Blob Jr.")
            ]
            state.destination = nil
        }
    }
    
    @Test func deleteContact() async throws {
        let store = TestStore(initialState: ContactsFeature.State(
            contacts: [
                Contact(id: UUID(0), name: "Blob"),
                Contact(id: UUID(1), name: "Blob Jr."),
            ]
        )) {
            ContactsFeature()
        }
//        await store.send(.deleteButtonTapped(id: UUID(1))) { state in
//            state.destination = .alert(.deleteConfirmation(id: UUID(1)))
//        }
        
        await store.send(\.destination.alert.confirmDeletion, UUID(1)) {
            $0.contacts = [
                Contact(id: UUID(0), name: "Blob")
            ]
            $0.destination = nil
        }
    }
}
