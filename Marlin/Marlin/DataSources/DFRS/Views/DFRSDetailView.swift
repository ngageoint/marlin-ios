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
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DFRSArea.areaName, ascending: true), NSSortDescriptor(keyPath: \DFRSArea.index, ascending: true)],
        predicate: NSPredicate(format: "areaNote != nil || indexNote != nil"),
        animation: .default)
    private var areas: FetchedResults<DFRSArea>
    
    @State var predicate: NSPredicate?
    @State var dfrs: DFRS
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dfrs.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: dfrs.color))
                        .padding(.bottom, -8)
                    if let predicate = predicate, CLLocationCoordinate2DIsValid(dfrs.coordinate) {
                        DataSourceLocationMapView(dataSourceLocation: dfrs, mapName: "DFRS Detail Map", mixins: [DFRSMap(fetchPredicate: predicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    dfrs.summaryView(showMoreDetails: false, showSectionHeader: true, showTitle: false)
                        .padding(.all, 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            let areaNotes = areas.reduce("") { result, area in
                if area.areaName == dfrs.areaName {
                    var newResult = "\(result)"
                    if newResult == "" {
                        newResult = "\(area.areaNote ?? "")\n\(area.indexNote ?? "")"
                    } else {
                        newResult = "\(newResult)\n\(area.indexNote ?? "")"
                    }
                    return newResult
                }
                return result
            }
            
            if areaNotes != "" {
                Section("\(dfrs.areaName ?? "") Area Notes") {
                    Text(areaNotes)
                        .secondary()
                        .lineLimit(8)
                        .frame(maxWidth:.infinity)
                        .padding(.all, 16)
                        .card()
                }
                .dataSourceSection()
            }
            
            KeyValueSection(sectionName: "Additional Information", properties: dfrs.additionalKeyValues)
                .dataSourceSection()
        }
        .dataSourceDetailList()
        .onAppear {
            predicate = NSPredicate(format: "stationNumber == %@", dfrs.stationNumber ?? "")
            Metrics.shared.dataSourceDetail(dataSource: DFRS.self)
        }
    }
}
