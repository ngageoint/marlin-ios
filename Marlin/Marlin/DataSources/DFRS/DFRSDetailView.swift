//
//  DFRSDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI
import MapKit
import CoreData

struct DFRSDetailView: View {
    @StateObject var mapState: MapState = MapState()
    
    var fetchRequest: NSFetchRequest<DFRS>
    var dfrs: DFRS
    
    init(dfrs: DFRS) {
        self.dfrs = dfrs
        let predicate = NSPredicate(format: "stationNumber == %@", dfrs.stationNumber ?? "")
        fetchRequest = DFRS.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if CLLocationCoordinate2DIsValid(dfrs.coordinate) {
                        MarlinMap(name: "DFRS Detail Map", mixins: [DFRSMap(fetchRequest: fetchRequest, showAsTiles: true)], mapState: mapState)
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            .onAppear {
                                mapState.center = MKCoordinateRegion(center: dfrs.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                            }
                            .onChange(of: dfrs) { dfrs in
                                mapState.center = MKCoordinateRegion(center: dfrs.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                            }
                    }
                    DFRSSummaryView(dfrs: dfrs, showSectionHeader: true)
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
            
            KeyValueSection(sectionName: "Additional Information", properties: dfrs.additionalKeyValues)
                .padding(.bottom, -20)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .padding([.trailing, .leading], -8)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
        .listStyle(.grouped)
    }
}
