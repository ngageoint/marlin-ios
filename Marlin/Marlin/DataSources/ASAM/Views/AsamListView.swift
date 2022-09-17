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

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)],
        animation: .default)
    private var asams: FetchedResults<Asam>
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    var watchFocusedItem: Bool = false
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedAsam = focusedItem.dataSource as? Asam {
                NavigationLink(tag: "detail", selection: $selection) {
                    focusedAsam.detailView
                        .navigationTitle(focusedAsam.reference ?? Asam.dataSourceName)
                        .navigationBarTitleDisplayMode(.inline)
                        .onDisappear {
                            focusedItem.dataSource = nil
                        }
                } label: {
                    EmptyView().hidden()
                }
                
                .isDetailLink(false)
                .onAppear {
                    selection = "detail"
                }
                .onChange(of: focusedItem.date) { newValue in
                    if watchFocusedItem, let _ = focusedItem.dataSource as? Asam {
                        selection = "detail"
                    }
                }
                
            }
            List {
                ForEach(asams) { asam in
                    
                    ZStack {
                        NavigationLink(destination: asam.detailView
                            .navigationTitle(asam.reference ?? Asam.dataSourceName)
                            .navigationBarTitleDisplayMode(.inline)) {
                            EmptyView()
                        }
                        .opacity(0)
                        
                        HStack {
                            asam.summaryView()
                        }
                        .padding(.all, 16)
                        .card()
                    }
                    
                }
                .dataSourceSummaryItem()
            }
            .navigationTitle(Asam.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .dataSourceSummaryList()
        }
    }
}

struct AsamListView_Previews: PreviewProvider {
    static var previews: some View {
        AsamListView(focusedItem: ItemWrapper()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
