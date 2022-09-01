//
//  DifferentialGPSStationDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI
import MapKit
import CoreData

struct DifferentialGPSStationDetailView: View {
    @StateObject var mapState: MapState = MapState()
    
    var fetchRequest: NSFetchRequest<DifferentialGPSStation>
    var differentialGPSStation: DifferentialGPSStation
    
    init(differentialGPSStation: DifferentialGPSStation) {
        self.differentialGPSStation = differentialGPSStation
        let predicate = NSPredicate(format: "featureNumber == %i AND volumeNumber == %@", differentialGPSStation.featureNumber, differentialGPSStation.volumeNumber ?? "")
        fetchRequest = DifferentialGPSStation.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "DifferentialGPSStation Detail Map", mixins: [DifferentialGPSStationMap(fetchRequest: fetchRequest)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: differentialGPSStation.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: differentialGPSStation) { differentialGPSStation in
                            mapState.center = MKCoordinateRegion(center: differentialGPSStation.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    differentialGPSStation.summaryView(showSectionHeader: true)
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
            
            KeyValueSection(sectionName: "Additional Information", properties: differentialGPSStation.additionalKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .padding([.trailing, .leading], -8)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .listStyle(.grouped)
    }
}
