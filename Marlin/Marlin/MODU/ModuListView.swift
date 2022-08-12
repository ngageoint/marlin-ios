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
    
    var body: some View {
        ZStack {
        if let focusedModu = focusedItem.dataSource as? Modu {
            NavigationLink(tag: "detail", selection: $selection) {
                ModuDetailView(modu: focusedModu)
                    .navigationTitle(focusedModu.name ?? Modu.dataSourceName)
                    .navigationBarTitleDisplayMode(.inline)
            } label: {
                EmptyView().hidden()
            }
            
            .isDetailLink(false)
            .onAppear {
                selection = "detail"
            }
            .onChange(of: focusedItem.dataSource as? Modu) { newValue in
                selection = "detail"
            }
        }
        
        List {
            ForEach(modus) { modu in
                
                ZStack {
                    NavigationLink(destination:
                                    ModuDetailView(modu: modu)
                                    .navigationTitle(modu.name ?? Modu.dataSourceName)
                                    .navigationBarTitleDisplayMode(.inline)) {
                            EmptyView()
                        }
                        .opacity(0)
                    
                    HStack {
                        ModuSummaryView(modu: modu)
                    }
                    .padding(.all, 16)
                    .background(Color.surfaceColor)
                    .modifier(CardModifier())
                }
                
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
        }
        .navigationTitle(Modu.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .background(Color.backgroundColor)
        }
    }
}

struct ModuListView_Previews: PreviewProvider {
    static var previews: some View {
        ModuListView(focusedItem: ItemWrapper()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
