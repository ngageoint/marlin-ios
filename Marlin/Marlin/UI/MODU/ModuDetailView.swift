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
    @EnvironmentObject var moduRepository: ModuRepository
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter
    @StateObject var viewModel: ModuViewModel = ModuViewModel()
    @State var name: String
    @State var waypointURI: URL?
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var body: some View {
        switch viewModel.modu {
        case nil:
            Color.clear.onAppear {
                viewModel.repository = moduRepository
                viewModel.getModu(name: name, waypointURI: waypointURI)
            }
        case .some(let modu):
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(modu.itemTitle)
                            .padding(.all, 8)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .itemTitle()
                            .foregroundColor(Color.white)
                            .background(Color(uiColor: DataSources.modu.color))
                            .padding(.bottom, -8)
                        DataSourceLocationMapView(
                            dataSourceLocation: modu,
                            mapName: "Modu Detail Map",
                            mixins: [
                                ModuMap(
                                    repository: ModuTileRepository(
                                        name: modu.name ?? "",
                                        localDataSource: moduRepository.localDataSource
                                    )
                                )
                            ]
                        )
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        Group {
                            Text("\(modu.dateString ?? "")")
                                .overline()
                            Text("\(modu.rigStatus ?? "")")
                                .lineLimit(1)
                                .secondary()
                            Text("\(modu.specialStatus ?? "")")
                                .lineLimit(1)
                                .secondary()
                            BookmarkNotes(itemKey: modu.itemKey, dataSource: modu.key)
                            DataSourceActions(
                                location: Actions.Location(latLng: modu.coordinate),
                                zoom: ModuActions.Zoom(latLng: modu.coordinate, itemKey: modu.id),
                                bookmark: modu.canBookmark ? Actions.Bookmark(
                                    itemKey: modu.id,
                                    bookmarkViewModel: bookmarkViewModel
                                ) : nil
                            )
                        }.padding([.leading, .trailing], 16)
                    }
                    .card()
                } header: {
                    EmptyView().frame(width: 0, height: 0, alignment: .leading)
                }
                .dataSourceSection()

                Section("Additional Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        if let distance = modu.distance {
                            Property(property: "Distance", value: distance.zeroIsEmptyString)
                        }
                        Property(property: "Navigational Area", value: modu.navArea)
                        if let subregion = viewModel.modu?.subregion {
                            Property(property: "Charting Subregion", value: subregion.zeroIsEmptyString)
                        }
                    }
                    .padding(.all, 16)
                    .card()
                }
                .dataSourceSection()
            }
            .dataSourceDetailList()
            .navigationTitle(modu.name ?? DataSources.modu.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: name) { _ in
                viewModel.getModu(name: name, waypointURI: waypointURI)
            }
            .onAppear {
                bookmarkViewModel.repository = bookmarkRepository
                bookmarkViewModel.getBookmark(itemKey: modu.id, dataSource: DataSources.modu.key)
                Metrics.shared.dataSourceDetail(dataSource: DataSources.modu)
            }
        }
    }
}
