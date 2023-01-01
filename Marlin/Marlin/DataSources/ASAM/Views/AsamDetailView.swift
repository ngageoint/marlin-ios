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
    @StateObject var mapState: MapState = MapState()
    var fetchRequest: NSFetchRequest<Asam>

    var asam: Asam
    
    init(asam: Asam) {
        self.asam = asam
        let predicate = NSPredicate(format: "reference == %@", asam.reference ?? "")
        fetchRequest = Asam.fetchRequest()
        fetchRequest.predicate = predicate
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "Asam Detail Map", mixins: [AsamMap(fetchPredicate: fetchRequest.predicate)], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: asam.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: asam) { asam in
                            mapState.center = MKCoordinateRegion(center: asam.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    Group {
                        Text(asam.dateString ?? "")
                            .overline()
                        Text("\(asam.hostility ?? "")\(asam.hostility != nil && asam.victim != nil ? ": " : "")\(asam.victim ?? "")")
                            .primary()
                        AsamActionBar(asam: asam)
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
            Metrics.shared.dataSourceDetail(dataSource: Asam.self)
        }
    }
}
