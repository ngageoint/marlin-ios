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
                    Text(modu.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: modu.color))
                        .padding(.bottom, -8)
                    DataSourceLocationMapView(dataSourceLocation: modu, mapName: "Modu Detail Map", mixins: [ModuMap(fetchPredicate: fetchRequest.predicate)])
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    Group {
                        Text(modu.dateString ?? "")
                            .overline()
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
                    if modu.distance != 0 {
                        Property(property: "Distance", value: "\(modu.distance)")
                    }
                    Property(property: "Navigational Area", value: modu.navArea)
                    Property(property: "Charting Subregion", value: "\(modu.subregion)")
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
