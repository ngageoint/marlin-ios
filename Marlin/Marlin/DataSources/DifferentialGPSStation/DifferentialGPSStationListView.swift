//
//  DifferentialGPSStationListView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DifferentialGPSStationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String, DifferentialGPSStation>(
        sectionIdentifier: \.geopoliticalHeading!,
        sortDescriptors: [NSSortDescriptor(keyPath: \DifferentialGPSStation.geopoliticalHeading, ascending: true), NSSortDescriptor(keyPath: \DifferentialGPSStation.featureNumber, ascending: true)]
    )
    var sectionedDifferentialGPSStations: SectionedFetchResults<String, DifferentialGPSStation>
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    var watchFocusedItem: Bool = false
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let differentialGPSStation = focusedItem.dataSource as? DifferentialGPSStation {
                NavigationLink(tag: "detail", selection: $selection) {
                    differentialGPSStation.detailView
                        .navigationTitle("\(differentialGPSStation.name ?? DifferentialGPSStation.dataSourceName)" )
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
                    if watchFocusedItem, let _ = focusedItem.dataSource as? DifferentialGPSStation {
                        selection = "detail"
                    }
                }
                
            }
            List(sectionedDifferentialGPSStations) { section in
                
                Section(header: HStack {
                    Text(section.id)
                        .font(Font.overline)
                        .foregroundColor(Color.onBackgroundColor)
                }) {
                    
                    ForEach(section) { differentialGPSStation in
                        
                        ZStack {
                            NavigationLink(destination: differentialGPSStation.detailView
                                .navigationTitle("\(differentialGPSStation.name ?? DifferentialGPSStation.dataSourceName)" )
                                .navigationBarTitleDisplayMode(.inline)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            
                            HStack {
                                differentialGPSStation.summaryView(showMoreDetails: false, showSectionHeader: false)
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
            }
            .navigationTitle(DifferentialGPSStation.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .background(Color.backgroundColor)
        }
    }
}

struct DifferentialGPSStationListView_Previews: PreviewProvider {
    static var previews: some View {
        DifferentialGPSStationListView(focusedItem: ItemWrapper())
    }
}

