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
    @State var predicate: NSPredicate?
    
    @ObservedObject var differentialGPSStation: DifferentialGPSStation

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(differentialGPSStation.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: differentialGPSStation.color))
                        .padding(.bottom, -8)
                    if let predicate = predicate {
                        DataSourceLocationMapView(dataSourceLocation: differentialGPSStation, mapName: "DifferentialGPSStation Detail Map", mixins: [DifferentialGPSStationMap(fetchPredicate: predicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    differentialGPSStation.summaryView(showSectionHeader: true, showTitle: false)
                        .padding(.all, 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            KeyValueSection(sectionName: "Additional Information", properties: differentialGPSStation.additionalKeyValues)
                .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("\(differentialGPSStation.name ?? DifferentialGPSStation.dataSourceName)" )
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: differentialGPSStation, perform: { newValue in
            predicate = NSPredicate(format: "featureNumber == %i AND volumeNumber == %@", differentialGPSStation.featureNumber, differentialGPSStation.volumeNumber ?? "")
        })
        .onAppear {
            predicate = NSPredicate(format: "featureNumber == %i AND volumeNumber == %@", differentialGPSStation.featureNumber, differentialGPSStation.volumeNumber ?? "")
            Metrics.shared.dataSourceDetail(dataSource: DifferentialGPSStation.self)
        }
    }
}
