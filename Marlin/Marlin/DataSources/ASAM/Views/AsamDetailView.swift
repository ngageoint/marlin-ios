//
//  AsamDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI
import MapKit
import CoreData

struct AsamDetailView: View {
    @State var predicate: NSPredicate?

    @State var asam: Asam
    
    var body: some View {
        Self._printChanges()
        return List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(asam.itemTitle)
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: asam.color))
                        .padding(.bottom, -8)
                    if let predicate = predicate {
                        DataSourceLocationMapView(dataSourceLocation: asam, mapName: "Asam Detail Map", mixins: [AsamMap(fetchPredicate: predicate)])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    Group {
                        AsamSummaryView(asam: asam, showTitle: false)
                            .padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()

            Section("Description") {
                Text(asam.asamDescription ?? "")
                    .secondary()
                    .frame(maxWidth:.infinity)
                    .padding(.all, 16)
                    .card()
            }
            .dataSourceSection()

            Section("Additional Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Property(property: "Hostility", value: asam.hostility)
                    Property(property: "Victim", value: asam.victim)
                    Property(property: "Reference Number", value: asam.reference)
                    Property(property: "Date of Occurence", value: asam.dateString)
                    Property(property: "Geographical Subregion", value: asam.subreg)
                    Property(property: "Navigational Area", value: asam.navArea)
                }
                .padding(.all, 16)
                .card()
                .frame(maxWidth: .infinity)
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle(asam.reference ?? Asam.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            predicate = NSPredicate(format: "reference == %@", asam.reference ?? "")
            Metrics.shared.dataSourceDetail(dataSource: Asam.self)
        }
    }
}
