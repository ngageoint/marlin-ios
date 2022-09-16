//
//  LightsListView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI
import CoreData

struct LightsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    @StateObject var lightsViewModel: LightsViewModel = LightsViewModel()
    
    var watchFocusedItem: Bool = false
    
    init(focusedItem: ItemWrapper, watchFocusedItem: Bool = false) {
        self.watchFocusedItem = watchFocusedItem
        self.focusedItem = focusedItem
    }

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
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(lightsViewModel.lights, id: \.id) { section in
                        Section(header: HStack {
                            Text(section.name)
                                .overline()
                                .padding([.leading, .trailing], 8)
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                            Spacer()
                        }
                            .background(Color.backgroundColor)) {
                                
                                ForEach(lightsViewModel.lights[section.id].lights) { light in
                                    
                                    ZStack {
                                        NavigationLink(destination: light.detailView
                                            .navigationTitle("\(light.name ?? Light.dataSourceName)" )
                                            .navigationBarTitleDisplayMode(.inline)) {
                                                EmptyView()
                                            }
                                            .opacity(0)
                                        
                                        HStack {
                                            light.summaryView()
                                                .onAppear {
                                                    if section.id == lightsViewModel.lights[lightsViewModel.lights.count - 1].id {
                                                        lightsViewModel.getLights(for: section.id + 1)
                                                    }
                                                }
                                        }
                                        .padding(.all, 16)
                                        .card()
                                    }
                                    .padding(.all, 8)
                                    
                                }
                                .dataSourceSummaryItem()
                            }
                    }
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
