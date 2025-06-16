//
//  AccountListView.swift
//  Linguista
//
//  Created by Daniel Grant on 6/11/25.
//


import SwiftUI
import CoreData

struct AccountListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AccountModel.createdAt, ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<AccountModel>

    var body: some View {
        NavigationView {
            List {
                ForEach(accounts) { account in
                    VStack(alignment: .leading) {
                        Text(account.username ?? "Unknown")
                            .font(.headline)
                        Text(account.email ?? "No Email")
                            .font(.subheadline)
                        Text("Created: \(account.createdAt!, formatter: dateFormatter)")
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteAccounts)
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    }

    private func deleteAccounts(offsets: IndexSet) {
        withAnimation {
            offsets.map { accounts[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
