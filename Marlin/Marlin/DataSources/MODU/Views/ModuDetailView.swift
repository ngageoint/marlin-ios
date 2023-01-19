//
//  ModuDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI
import MapKit
import CoreData

struct ModuDetailView: View {
    @StateObject var mapState: MapState = MapState()
    var fetchRequest: NSFetchRequest<Modu>
    
    var modu: Modu
    
    init(modu: Modu) {
        self.modu = modu
        let predicate = NSPredicate(format: "name == %@", modu.name ?? "")
        fetchRequest = Modu.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "Modu Detail Map", mixins: [ModuMap(fetchPredicate: fetchRequest.predicate)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: modu.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: modu) { modu in
                            mapState.center = MKCoordinateRegion(center: modu.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    Group {
                        Text(modu.dateString ?? "")
                            .overline()
                        Text("\(modu.name ?? "")")
                            .primary()
                        ModuActionBar(modu: modu)
                            .padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            Section("Additional Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Property(property: "Rig Status", value: modu.rigStatus)
                    Property(property: "Special Status", value: modu.specialStatus)
                    if let distance = modu.distance, distance != 0 {
                        Property(property: "Distance", value: "\(distance)")
                    }
                    Property(property: "Navigational Area", value: modu.navArea)
                    if let subregion = modu.subregion {
                        Property(property: "Charting Subregion", value: "\(subregion)")
                    }
                }
                .padding(.all, 16)
                .card()
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle(modu.name ?? Modu.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: Modu.self)
        }
    }
}
