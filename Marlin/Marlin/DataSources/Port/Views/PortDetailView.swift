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
    @State var predicate: NSPredicate?

    @ObservedObject var port: Port
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(port.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: port.color))
                        .padding(.bottom, -8)
                    if let predicate = predicate {
                        DataSourceLocationMapView(dataSourceLocation: port, mapName: "Port Detail Map", mixins: [PortMap(fetchPredicate: predicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    port.summary
                        .setShowTitle(false)
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
        .onChange(of: port, perform: { newValue in
            predicate = NSPredicate(format: "portNumber == %ld", port.portNumber)
        })
        .onAppear {
            predicate = NSPredicate(format: "portNumber == %ld", port.portNumber)
            Metrics.shared.dataSourceDetail(dataSource: Port.self)
        }
    }
}
