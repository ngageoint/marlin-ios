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
    @EnvironmentObject var dgpsRepository: DifferentialGPSStationRepository
    @EnvironmentObject var routeWaypointRepository: RouteWaypointRepository

    @StateObject var viewModel: DifferentialGPSStationViewModel = DifferentialGPSStationViewModel()
    @State var featureNumber: Int?
    @State var volumeNumber: String?
    @State var waypointURI: URL?

    var body: some View {
        Group {
            switch viewModel.differentialGPSStation {
            case nil:
                Color.clear.onAppear {
                    viewModel.repository = dgpsRepository
                    viewModel.getDifferentialGPSStation(
                        featureNumber: featureNumber,
                        volumeNumber: volumeNumber,
                        waypointURI: waypointURI
                    )
                }
            case .some(let differentialGPSStation):
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(differentialGPSStation.itemTitle)
                                .padding(.all, 8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .itemTitle()
                                .foregroundColor(Color.white)
                                .background(Color(uiColor: DataSources.dgps.color))
                                .padding(.bottom, -8)
                            DataSourceLocationMapView(
                                dataSourceLocation: differentialGPSStation,
                                mapName: "DifferentialGPSStation Detail Map",
                                mixins: [
                                    DifferentialGPSStationMap(
                                        repository: DifferentialGPSStationTileRepository(
                                            featureNumber: differentialGPSStation.featureNumber ?? -1,
                                            volumeNumber: differentialGPSStation.volumeNumber ?? "",
                                            localDataSource: dgpsRepository.localDataSource
                                        )
                                    )
                                ]
                            )
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                            DifferentialGPSStationSummaryView(
                                differentialGPSStation: DifferentialGPSStationListModel(
                                    differentialGPSStationModel: differentialGPSStation)
                            )
                            .showBookmarkNotes(true)
                            .setShowSectionHeader(true)
                            .setShowTitle(false)
                            .padding(.all, 16)
                        }
                        .card()
                    } header: {
                        EmptyView().frame(width: 0, height: 0, alignment: .leading)
                    }
                    .dataSourceSection()
                    
                    KeyValueSection(
                        sectionName: "Additional Information",
                        properties: differentialGPSStation.additionalKeyValues
                    )
                    .dataSourceSection()
                }
                .dataSourceDetailList()
            }
        }
        .navigationTitle("\(viewModel.differentialGPSStation?.name ?? DataSources.dgps.fullName)" )
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: featureNumber) { _ in
            viewModel.getDifferentialGPSStation(
                featureNumber: featureNumber,
                volumeNumber: volumeNumber,
                waypointURI: waypointURI
            )
        }
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: DataSources.dgps)
        }
    }
}
