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
    @State var predicate: NSPredicate?
    @ObservedObject var radioBeacon: RadioBeacon
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(radioBeacon.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: radioBeacon.color))
                        .padding(.bottom, -8)
                    if let predicate = predicate {
                        DataSourceLocationMapView(dataSourceLocation: radioBeacon, mapName: "Radio Beacon Detail Map", mixins: [RadioBeaconMap(fetchPredicate: predicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    radioBeacon.summary
                        .setBookmark(radioBeacon.bookmark)
                        .setShowSectionHeader(true)
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
            predicate = NSPredicate(format: "featureNumber == %i AND volumeNumber == %@", radioBeacon.featureNumber, radioBeacon.volumeNumber ?? "")
            Metrics.shared.dataSourceDetail(dataSource: RadioBeacon.self)
        }
    }
}

