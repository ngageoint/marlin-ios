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
    @EnvironmentObject var asamRepository: AsamRepository
    @EnvironmentObject var routeWaypointRepository: RouteWaypointRepository
    @StateObject var viewModel: AsamViewModel = AsamViewModel()
    @State var reference: String
    @State var waypointURI: URL?
    
    var body: some View {
        Self._printChanges()
        return List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.asam?.itemTitle ?? "")
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: DataSources.asam.color))
                        .padding(.bottom, -8)
                        .accessibilityElement(children: .contain)
                    if let asam = viewModel.asam {
                        DataSourceLocationMapView(
                            dataSourceLocation: asam,
                            mapName: "Asam Detail Map",
                            mixins: [
                                AsamMap(
                                    repository: AsamTileRepository(
                                        reference: asam.reference ?? "",
                                        localDataSource: asamRepository.localDataSource
                                    )
                                )
                            ]
                        )
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    if let asam = viewModel.asam {
                        Group {
                            AsamSummaryView(
                                asam: AsamListModel(asamModel: asam),
                                showTitle: false,
                                showBookmarkNotes: true
                            )
                            .padding(.bottom, 16)
                            .accessibilityElement(children: .contain)
                        }.padding([.leading, .trailing], 16)
                    }
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()

            Section("Additional Information") {
                VStack(alignment: .leading, spacing: 8) {
                    Property(property: "Hostility", value: viewModel.asam?.hostility)
                    Property(property: "Victim", value: viewModel.asam?.victim)
                    Property(property: "Reference Number", value: viewModel.asam?.reference)
                    Property(property: "Date of Occurence", value: viewModel.asam?.dateString)
                    Property(property: "Geographical Subregion", value: viewModel.asam?.subreg)
                    Property(property: "Navigational Area", value: viewModel.asam?.navArea)
                }
                .padding(.all, 16)
                .card()
                .frame(maxWidth: .infinity)
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle(viewModel.asam?.reference ?? DataSources.asam.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: reference) { _ in
            viewModel.getAsam(reference: reference, waypointURI: waypointURI)
        }
        .onAppear {
            viewModel.repository = asamRepository
            viewModel.routeWaypointRepository = routeWaypointRepository
            viewModel.getAsam(reference: reference, waypointURI: waypointURI)
            Metrics.shared.dataSourceDetail(dataSource: DataSources.asam)
        }
    }
}
