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
    @EnvironmentObject var portRepository: PortRepository
    @StateObject var viewModel: PortViewModel = PortViewModel()
    @State var portNumber: Int?
    @State var waypointURI: URL?
    
    var body: some View {
        switch viewModel.port {
        case nil:
            Color.clear.onAppear {
                viewModel.repository = portRepository
                viewModel.getPort(portNumber: portNumber, waypointURI: waypointURI)
            }
        case .some(let port):
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(port.itemTitle)
                            .padding(.all, 8)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .itemTitle()
                            .foregroundColor(Color.white)
                            .background(Color(uiColor: DataSources.port.color))
                            .padding(.bottom, -8)
                        DataSourceLocationMapView(
                            dataSourceLocation: port,
                            mapName: "Port Detail Map",
                            mixins: [
                                PortMap(
                                    repository: PortTileRepository(
                                        portNumber: portNumber ?? 0,
                                        localDataSource: portRepository.localDataSource
                                    )
                                )
                            ]
                        )
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        PortSummaryView(port: PortListModel(portModel: port))
                            .showBookmarkNotes(true)
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
                
                KeyValueSection(
                    sectionName: "Pilots, Tugs, Communications",
                    properties: port.pilotsTugsCommunicationsKeyValues
                )
                .dataSourceSection()
                
                KeyValueSection(sectionName: "Facilities", properties: port.facilitiesKeyValues)
                    .dataSourceSection()
                
                KeyValueSection(sectionName: "Cranes", properties: port.cranesKeyValues)
                    .dataSourceSection()
                
                KeyValueSection(sectionName: "Services and Supplies", properties: port.servicesSuppliesKeyValues)
                    .dataSourceSection()
            }
            .dataSourceDetailList()
            .navigationTitle(port.portName ?? DataSources.port.fullName)
            .navigationBarTitleDisplayMode(.inline)
            
            .onChange(of: portNumber) { _ in
                viewModel.getPort(portNumber: portNumber, waypointURI: waypointURI)
            }
            .onAppear {
                Metrics.shared.dataSourceDetail(dataSource: DataSources.port)
            }
        }
    }
}
