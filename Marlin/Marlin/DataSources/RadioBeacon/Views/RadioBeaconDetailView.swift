//
//  RadioBeaconDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import SwiftUI
import MapKit
import CoreData

struct RadioBeaconDetailView: View {
    
    @StateObject var mapState: MapState = MapState()
    
    var fetchRequest: NSFetchRequest<RadioBeacon>
    var radioBeacon: RadioBeacon
    
    init(radioBeacon: RadioBeacon) {
        self.radioBeacon = radioBeacon
        let predicate = NSPredicate(format: "featureNumber == %i AND volumeNumber == %@", radioBeacon.featureNumber, radioBeacon.volumeNumber ?? "")
        fetchRequest = RadioBeacon.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "RadioBeacon Detail Map", mixins: [RadioBeaconMap(fetchPredicate: fetchRequest.predicate), UserLayersMap()], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: radioBeacon.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: radioBeacon) { radioBeacon in
                            mapState.center = MKCoordinateRegion(center: radioBeacon.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    radioBeacon.summaryView(showSectionHeader: true)
                        .padding(.all, 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            KeyValueSection(sectionName: "Additional Information", properties: radioBeacon.additionalKeyValues)
                .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("\(radioBeacon.name ?? RadioBeacon.dataSourceName)" )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: RadioBeacon.self)
        }
    }
}

