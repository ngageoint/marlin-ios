//
//  BookmarkSummary.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct BookmarkSummary: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager

    var showMoreDetails: Bool = false
    var showTitle: Bool = false
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = true
    var bookmark: Bookmark?
    @State var dataSource: (any Bookmarkable)?

    var body: some View {
        Self._printChanges()
        
        return VStack(alignment: .leading) {

            HStack {
                if let dataSource = dataSource {
                    DataSourceIcon(dataSource: type(of: dataSource).definition)
                    Spacer()
                }
            }
            switch dataSource {
            case let dataSource as AsamModel:
                AsamSummaryView(asam: AsamListModel(asamModel: dataSource))
                    .showBookmarkNotes(true)
            case let dataSource as ModuModel:
                ModuSummaryView(modu: ModuListModel(moduModel: dataSource))
                    .showBookmarkNotes(true)
            case let dataSource as PortModel:
                PortSummaryView(port: PortListModel(portModel: dataSource))
                    .showBookmarkNotes(true)
            case let dataSource as LightModel:
                LightSummaryView(light: LightListModel(lightModel: dataSource))
                    .showBookmarkNotes(true)
            case let dataSource as RadioBeaconModel:
                RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel: dataSource))
                    .showBookmarkNotes(true)
            case let dataSource as DifferentialGPSStationModel:
                DifferentialGPSStationSummaryView(
                    differentialGPSStation: DifferentialGPSStationListModel(
                        differentialGPSStationModel: dataSource
                    )
                )
                .showBookmarkNotes(true)
            case let dataSource as NoticeToMarinersModel:
                NoticeToMarinersSummaryView(
                    noticeToMariners: NoticeToMarinersListModel(
                        noticeToMarinersModel: dataSource
                    )
                )
                .showBookmarkNotes(true)
            case let dataSource as any DataSourceViewBuilder:
                AnyView(
                    dataSource.summary
                        .setShowTitle(true)
                        .setShowSectionHeader(false)
                        .setShowMoreDetails(false)
                        .showBookmarkNotes(true)
                )
            default:
                EmptyView()
            }

        }
        .task {
            if let itemKey = bookmark?.itemKey, let bookmarkDataSource = bookmark?.dataSource {
                dataSource = bookmarkRepository.getDataSourceItem(
                    itemKey: itemKey,
                    dataSource: bookmarkDataSource
                )
            }
        }
    }
}
