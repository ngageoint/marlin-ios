//
//  PortDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/17/22.
//

import SwiftUI
import MapKit
import CoreData

struct PortDetailView: View {
    @StateObject var mapState: MapState = MapState()
    var fetchRequest: NSFetchRequest<Port>
    
    var port: Port
    
    init(port: Port) {
        self.port = port
        let predicate = NSPredicate(format: "portNumber == %ld", port.portNumber)
        fetchRequest = Port.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "Port Detail Map", mixins: [PortMap(fetchPredicate: fetchRequest.predicate)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: port.coordinate, zoomLevel: 12.0, pixelWidth: 300.0)
                        }
                        .onChange(of: port) { port in
                            mapState.center = MKCoordinateRegion(center: port.coordinate, zoomLevel: 12.0, pixelWidth: 300.0)
                        }
                    port.summaryView()
                        .padding(.all, 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            KeyValueSection(sectionName: "Name and Location", properties: port.nameAndLocationKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Depths", properties: port.depthKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Maximum Vessel Size", properties: port.maximumVesselSizeKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Physical Environment", properties: port.physicalEnvironmentKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Approach", properties: port.approachKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Pilots, Tugs, Communications", properties: port.pilotsTugsCommunicationsKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Facilities", properties: port.facilitiesKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Cranes", properties: port.cranesKeyValues)
                .dataSourceSection()
            
            KeyValueSection(sectionName: "Services and Supplies", properties: port.servicesSuppliesKeyValues)
                .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle(port.portName ?? Port.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PortDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let port = try? context.fetchFirst(Port.self)
        PortDetailView(port: port!)
    }
}
