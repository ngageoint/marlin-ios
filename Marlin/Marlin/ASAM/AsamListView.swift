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
        .listStyle(.plain)
        .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
    }
}

struct AsamListView_Previews: PreviewProvider {
    static var previews: some View {
        AsamListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
