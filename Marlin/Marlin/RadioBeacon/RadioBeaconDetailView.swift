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
        print("xxx the predicate is \(predicate)")
        fetchRequest = RadioBeacon.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "RadioBeacon Detail Map", mixins: [RadioBeaconMap(fetchRequest: fetchRequest, showRadioBeaconsAsTiles: false)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: radioBeacon.latitude, longitude: radioBeacon.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                        }
                        .onChange(of: radioBeacon) { radioBeacon in
                            mapState.center = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: radioBeacon.latitude, longitude: radioBeacon.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
                        }
                    RadioBeaconSummaryView(radioBeacon: radioBeacon) //, currentLocation: locationManager.lastLocation)
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

