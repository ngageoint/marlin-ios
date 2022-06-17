//
//  ContentView.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import SwiftUI
import CoreData

struct AsamListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var scheme: MarlinScheme

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)],
        animation: .default)
    private var asams: FetchedResults<Asam>

    var body: some View {
        NavigationView {
            List {
                ForEach(asams) { asam in
                    
                    ZStack {
                        NavigationLink(destination: AsamDetailView(asam: asam)
                            .navigationTitle(asam.reference ?? "ASAM")
                            .navigationBarTitleDisplayMode(.inline)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        HStack {
                            AsamSummaryView(asam: asam)
                        }
                        .padding(.all, 16)
                        .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                        .modifier(CardModifier())
                    }
                    
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }
            .navigationTitle("ASAMs")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.grouped)
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

struct AsamListView_Previews: PreviewProvider {
    static var previews: some View {
        AsamListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
