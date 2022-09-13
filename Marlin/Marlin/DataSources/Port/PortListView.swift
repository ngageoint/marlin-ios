//
//  PortListView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/17/22.
//

import SwiftUI

struct PortListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Port.portNumber, ascending: true)],
        animation: .default)
    private var ports: FetchedResults<Port>
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    @State var sortedPorts: [Port] = []
    
    @EnvironmentObject var locationManager: LocationManager

    var watchFocusedItem: Bool = false
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedPort = focusedItem.dataSource as? Port {
                NavigationLink(tag: "detail", selection: $selection) {
                    focusedPort.detailView
                        .navigationTitle(focusedPort.portName ?? "Port")
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    EmptyView().hidden()
                }
                
                .isDetailLink(false)
                .onAppear {
                    selection = "detail"
                }
                .onChange(of: focusedItem.date) { newValue in
                    if watchFocusedItem, let _ = focusedItem.dataSource as? Port {
                        selection = "detail"
                    }
                }
            }
            List {
                ForEach(sortedPorts) { port in
                    
                    ZStack {
                        NavigationLink(destination: port.detailView
                            .navigationTitle(port.portName ?? "Port")
                            .navigationBarTitleDisplayMode(.inline)) {
                                EmptyView()
                            }
                            .opacity(0)
                        
                        HStack {
                            port.summaryView(showMoreDetails: false, showSectionHeader: false)
                        }
                        .padding(.all, 16)
                        .card()
                    }
                    
                }
                .dataSourceSummaryItem()
            }
            .navigationTitle(Port.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .dataSourceSummaryList()
            .onAppear {
                if let lastLocation = locationManager.lastLocation {
                    sortedPorts = ports.sorted { first, second in
                        return first.distanceTo(lastLocation) < second.distanceTo(lastLocation)
                    }
                } else {
                    sortedPorts = ports.map { $0 }
                }
            }
            .onChange(of: locationManager.lastLocation) { newValue in
                if sortedPorts.count == 0 {
                    if let lastLocation = locationManager.lastLocation {
                        sortedPorts = ports.sorted { first, second in
                            return first.distanceTo(lastLocation) < second.distanceTo(lastLocation)
                        }
                    } else {
                        sortedPorts = ports.map { $0 }
                    }
                }
            }
        }
    }
}

struct PortListView_Previews: PreviewProvider {
    static var previews: some View {
        PortListView(focusedItem: ItemWrapper())
    }
}
