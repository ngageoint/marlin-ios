//
//  ModuListView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI

import CoreData

struct ModuListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)],
        animation: .default)
    private var modus: FetchedResults<Modu>
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    var watchFocusedItem: Bool = false
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedModu = focusedItem.dataSource as? Modu {
                NavigationLink(tag: "detail", selection: $selection) {
                    focusedModu.detailView
                        .navigationTitle(focusedModu.name ?? Modu.dataSourceName)
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
                    if watchFocusedItem, let _ = focusedItem.dataSource as? Modu {
                        selection = "detail"
                    }
                }
            }
            
            List {
                ForEach(modus) { modu in
                    
                    ZStack {
                        NavigationLink(destination:
                                        modu.detailView
                                        .navigationTitle(modu.name ?? Modu.dataSourceName)
                                        .navigationBarTitleDisplayMode(.inline)) {
                                EmptyView()
                            }
                            .opacity(0)
                        
                        HStack {
                            ModuSummaryView(modu: modu)
                        }
                        .padding(.all, 16)
                        .card()
                    }
                    
                }
                .dataSourceSummaryItem()
            }
            .navigationTitle(Modu.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .dataSourceSummaryList()
        }
    }
}

struct ModuListView_Previews: PreviewProvider {
    static var previews: some View {
        ModuListView(focusedItem: ItemWrapper()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
