//
//  NavigationalWarningDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI
import MapKit

struct NavigationalWarningDetailView: View {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    @EnvironmentObject var navigationalWarningRepository: NavigationalWarningRepository
    @EnvironmentObject var routeWaypointRepository: RouteWaypointRepository
    @StateObject var viewModel: NavigationalWarningViewModel = NavigationalWarningViewModel()
    @State var msgYear: Int
    @State var msgNumber: Int
    @State var navArea: String
    @State var waypointURI: URL?

    var body: some View {
        switch viewModel.navWarning {
        case nil:
            Color.clear.onAppear {
                viewModel.repository = navigationalWarningRepository
                viewModel.routeWaypointRepository = routeWaypointRepository
                viewModel.getNavigationalWarning(
                    msgYear: msgYear,
                    msgNumber: msgNumber,
                    navArea: navArea,
                    waypointURI: waypointURI
                )
            }
        case .some(let navigationalWarning):
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(navigationalWarning.itemTitle)
                            .padding(.all, 8)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .itemTitle()
                            .foregroundColor(Color.white)
                            .background(Color(uiColor: NavigationalWarning.color))
                            .padding(.bottom, -8)
                        DataSourceLocationMapView(
                            dataSourceLocation: navigationalWarning,
                            mapName: "Navigational Warning Detail Map",
                            mixins: [
                                NavigationalWarningMap(
                                    mapFeatureRepository: NavigationalWarningMapFeatureRepository(
                                        msgYear: navigationalWarning.msgYear ?? -1,
                                        msgNumber: navigationalWarning.msgNumber ?? -1,
                                        navArea: navigationalWarning.navArea,
                                        localDataSource: navigationalWarningRepository.localDataSource
                                    )
                                )
                            ]
                        )
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        Group {
                            Text(navigationalWarning.dateString ?? "")
                                .overline()
                                .padding(.top, 16)
                            Property(property: "Authority", value: navigationalWarning.authority)
                            Property(property: "Cancel Date", value: navigationalWarning.cancelDateString)
                            if let cancelNavArea = navigationalWarning.cancelNavArea,
                               let cancelMsgNumber = navigationalWarning.cancelMsgNumber,
                               let cancelMsgYear = navigationalWarning.cancelMsgYear,
                               let navAreaEnum = NavigationalWarningNavArea.fromId(id: cancelNavArea) {
                                Property(
                                    property: "Cancelled By",
                                    value: """
                                    \(navAreaEnum.display) \(cancelMsgNumber)/\
                                    \(cancelMsgYear)
                                    """
                                )
                            }
                            if navigationalWarning.canBookmark {
                                BookmarkNotes(bookmarkViewModel: bookmarkViewModel)
                            }
                            DataSourceActions(
                                location: Actions.Location(latLng: navigationalWarning.coordinate),
                                zoom: NavigationalWarningActions.Zoom(
                                    latLng: navigationalWarning.coordinate,
                                    itemKey: navigationalWarning.itemKey
                                ),
                                bookmark: navigationalWarning.canBookmark ? Actions.Bookmark(
                                    itemKey: navigationalWarning.itemKey,
                                    bookmarkViewModel: bookmarkViewModel
                                ) : nil,
                                share: navigationalWarning.itemTitle
                            )
                        }
                        .padding([.leading, .trailing], 16)
                    }
                    .card()
                } header: {
                    EmptyView().frame(width: 0, height: 0, alignment: .leading)
                }
                .dataSourceSection()

                if let text = navigationalWarning.text {
                    Section("Warning") {
                        UITextViewContainer(text: text)
                            .padding(.all, 16)
                            .card()
                    }
                    .dataSourceSection()
                }
            }
            .dataSourceDetailList()
            .navigationTitle("""
                \(navigationalWarning.navAreaName) \
                \(String(navigationalWarning.msgNumber ?? -1))/\(String(navigationalWarning.msgYear ?? -1)) \
                (\(navigationalWarning.subregion ?? ""))
                """)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                bookmarkViewModel.repository = bookmarkRepository
                bookmarkViewModel.getBookmark(
                    itemKey: navigationalWarning.itemKey,
                    dataSource: DataSources.navWarning.key
                )
                Metrics.shared.dataSourceDetail(dataSource: NavigationalWarning.definition)
            }

        }

    }
}
