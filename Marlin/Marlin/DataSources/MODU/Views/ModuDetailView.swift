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
    @State var predicate: NSPredicate?
    
    @ObservedObject var modu: Modu
    
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
                    if let predicate = predicate {
                        DataSourceLocationMapView(dataSourceLocation: modu, mapName: "Modu Detail Map", mixins: [ModuMap(fetchPredicate: predicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    Group {
                        Text(modu.dateString ?? "")
                            .overline()
                        DataSourceActionBar(data: modu)
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
        .onChange(of: modu, perform: { newValue in
            predicate = NSPredicate(format: "name == %@", modu.name ?? "")
        })
        .onAppear {
            predicate = NSPredicate(format: "name == %@", modu.name ?? "")
            Metrics.shared.dataSourceDetail(dataSource: Modu.self)
        }
    }
}
