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
                    MarlinMap(name: "RadioBeacon Detail Map", mixins: [RadioBeaconMap(fetchRequest: fetchRequest, showRadioBeaconsAsTiles: true)], mapState: mapState)
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
                
                .background(Color.surfaceColor)
                .modifier(CardModifier())
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .padding(.top, -24)
            .padding(.bottom, -20)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            
            KeyValueSection(sectionName: "Additional Information", properties: radioBeacon.additionalKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .padding([.trailing, .leading], -8)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .listStyle(.grouped)
    }
}

