//
//  LightsListView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct LightsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    @SectionedFetchRequest<String, Light>(
        sectionIdentifier: \.sectionHeader!,
        sortDescriptors: [NSSortDescriptor(keyPath: \Light.sectionHeader, ascending: true), NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)],
        predicate: NSPredicate(format: "characteristicNumber = 1")// AND volumeNumber = 'PUB 116'")
    )
    var sectionedLights: SectionedFetchResults<String, Light>
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    var watchFocusedItem: Bool = false

    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedLight = focusedItem.dataSource as? Light {
                NavigationLink(tag: "detail", selection: $selection) {
                    focusedLight.detailView
                        .navigationTitle("\(focusedLight.name ?? Light.dataSourceName)" )
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
                    if watchFocusedItem, let _ = focusedItem.dataSource as? Light {
                        selection = "detail"
                    }
                }
                
            }
            List(sectionedLights) { section in
                
                Section(header: HStack {
                    Text(section.id)
                        .overline()
                }) {

                    ForEach(section) { light in
                         
                        ZStack {
                            NavigationLink(destination: light.detailView
                                .navigationTitle("\(light.name ?? Light.dataSourceName)" )
                                .navigationBarTitleDisplayMode(.inline)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            
                            HStack {
                                light.summaryView()
                            }
                            .padding(.all, 16)
                            .card()
                        }
                        
                    }
                    .dataSourceSummaryItem()
                }
            }
            .navigationTitle(Light.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .dataSourceSummaryList()
        }
    }
}

struct LightsListView_Previews: PreviewProvider {
    static var previews: some View {
        LightsListView(focusedItem: ItemWrapper())
    }
}
