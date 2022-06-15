//
//  ContentView.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)],
        animation: .default)
    private var asams: FetchedResults<Asam>

    var body: some View {
        NavigationView {
            List {
                ForEach(asams) { asam in
                    NavigationLink {
                        Text("Asam at \(asam.longitude!, formatter: longitudeFormatter)")
                    } label: {
                        HStack(alignment: .center, spacing: 16) {
                           VStack(alignment: .center, spacing: 8) {
                               Text(asam.asamDescription ?? "")
                               Text(asam.longitude ?? 0.0, formatter: longitudeFormatter)
                               Text(asam.longitude ?? 0.0, formatter: longitudeFormatter).bold()
                           }
                        }
                        
                    }
                }
                .onDelete(perform: deleteItems)
            }.listStyle(.plain)
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Asam", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Asam(context: viewContext)
            newItem.date = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { asams[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let longitudeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.maximumFractionDigits = 2
    return formatter
}()

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
