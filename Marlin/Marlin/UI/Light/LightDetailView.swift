//
//  LightDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/7/22.
//

import SwiftUI
import MapKit
import CoreData

struct LightDetailView: View {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter
    @EnvironmentObject var lightRepository: LightRepository
    @StateObject var viewModel: LightViewModel = LightViewModel()
    @State var featureNumber: String
    @State var volumeNumber: String
    @State var waypointURI: URL?
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var body: some View {
        Group {
            if viewModel.lights.count > 0 {
                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            if let firstLight = viewModel.lights.first {
                                Text(firstLight.itemTitle)
                                    .padding(.all, 8)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .itemTitle()
                                    .foregroundColor(Color.white)
                                    .background(Color(uiColor: DataSources.light.color))
                                    .padding(.bottom, -8)
                                
                                DataSourceLocationMapView(
                                    dataSourceLocation: firstLight,
                                    mapName: "Light Detail Map",
                                    mixins: [
                                        LightMap(
                                            repository: LightTileRepository(
                                                featureNumber: featureNumber,
                                                volumeNumber: volumeNumber,
                                                localDataSource: lightRepository.localDataSource
                                            )
                                        )
                                    ]
                                )
                                .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                                
                                Group {
                                    Text("""
                                    \(firstLight.featureNumber ?? "") \
                                    \(firstLight.internationalFeature ?? "") \
                                    \(firstLight.volumeNumber ?? "")
                                    """)
                                    .overline()
                                    if let sectionHeader = firstLight.sectionHeader {
                                        Text(sectionHeader)
                                            .secondary()
                                    }
                                    if let structure = firstLight.structure?.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    ) {
                                        Text(structure)
                                            .secondary()
                                    }
                                    if let heightFeet = firstLight.heightFeet,
                                        let heightMeters = firstLight.heightMeters, heightFeet != 0 {
                                        Text("Focal Plane Elevation: \(Int(heightFeet))ft (\(Int(heightMeters))m)")
                                            .secondary()
                                    }

                                    DataSourceActions(
                                        location: Actions.Location(latLng: firstLight.coordinate),
                                        zoom: LightActions.Zoom(latLng: firstLight.coordinate, itemKey: firstLight.id),
                                        bookmark: firstLight.canBookmark ? Actions.Bookmark(
                                            itemKey: firstLight.id,
                                            bookmarkViewModel: bookmarkViewModel
                                        ) : nil,
                                        share: firstLight.itemTitle
                                    )
                                    .padding(.bottom, 16)
                                }
                                .padding([.leading, .trailing], 16)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .card()
                    } header: {
                        EmptyView().frame(width: 0, height: 0, alignment: .leading)
                    }
                    .dataSourceSection()
                    
                    Section("Characteristics") {
                        ForEach(viewModel.lights) { light in
                            if light.isLight {
                                LightCard(light: light)
                                    .padding(.bottom, 16)
                            } else {
                                RaconCard(racon: light)
                                    .padding(.bottom, 16)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .dataSourceSection()
                }
                .dataSourceDetailList()
            } else {
                Text("Loading Light \(self.featureNumber) \(self.volumeNumber)")
            }
        }
        .onChange(of: featureNumber + volumeNumber) { _ in
            viewModel.getLights(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
        }
        .onAppear {
            viewModel.repository = lightRepository
            viewModel.getLights(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
            Metrics.shared.dataSourceDetail(dataSource: DataSources.light)
        }
    }
}
