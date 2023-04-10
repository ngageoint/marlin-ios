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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DFRSArea.areaName, ascending: true), NSSortDescriptor(keyPath: \DFRSArea.index, ascending: true)],
        predicate: NSPredicate(format: "areaNote != nil || indexNote != nil"),
        animation: .default)
    private var areas: FetchedResults<DFRSArea>
    
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
                        MarlinMap(name: "DFRS Detail Map", mixins: [DFRSMap(fetchPredicate: fetchRequest.predicate), UserLayersMap()], mapState: mapState)
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            .onAppear {
                                mapState.center = MKCoordinateRegion(center: dfrs.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                            }
                            .onChange(of: dfrs) { dfrs in
                                mapState.center = MKCoordinateRegion(center: dfrs.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                            }
                    }
                    dfrs.summaryView(showMoreDetails: false, showSectionHeader: true)
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
            Metrics.shared.dataSourceDetail(dataSource: DFRS.self)
        }
    }
}
