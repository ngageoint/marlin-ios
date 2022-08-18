//
//  PortDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/17/22.
//

import SwiftUI
import MapKit

struct PortDetailView: View {
    @State private var region: MKCoordinateRegion
    @EnvironmentObject var locationManager: LocationManager

    var port: Port
    
    init(port: Port) {
        self.port = port
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: port.latitude, longitude: port.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    
                    Map(coordinateRegion: $region, annotationItems: [port]) { asam in
                        MapAnnotation(coordinate: port.coordinate, anchorPoint: CGPoint(x: 0.5, y: 1)) {
                            Image("port")
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    PortSummaryView(port: port, currentLocation: locationManager.lastLocation)
                        .padding(.all, 16)
                }
                
                .background(Color.surfaceColor)
                .modifier(CardModifier())
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .padding(.top, -24)
            .padding(.bottom, -20)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Name and Location", properties: port.nameAndLocationKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Depths", properties: port.depthKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Maximum Vessel Size", properties: port.maximumVesselSizeKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Physical Environment", properties: port.physicalEnvironmentKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Approach", properties: port.approachKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Pilots, Tugs, Communications", properties: port.pilotsTugsCommunicationsKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Facilities", properties: port.facilitiesKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Cranes", properties: port.cranesKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Services and Supplies", properties: port.servicesSuppliesKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listStyle(.grouped)
        .padding([.leading, .trailing], -8)
    }
}

struct PortDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let port = try? context.fetchFirst(Port.self)
        PortDetailView(port: port!)
    }
}
