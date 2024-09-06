//
//  BookmarkSummary.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct BookmarkSummary: DataSourceSummaryView {
    @Injected(\.bookmarkRepository)
    private var bookmarkRepository: BookmarkRepository
    
    @EnvironmentObject var router: MarlinRouter

    var showMoreDetails: Bool = false
    var showTitle: Bool = false
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = true
    var bookmark: BookmarkModel?
    @State var dataSource: (any Bookmarkable)?

    var body: some View {
        VStack(alignment: .leading) {

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
                    .onTapGesture {
                        if let reference = dataSource.reference {
                            router.path.append(AsamRoute.detail(reference: reference))
                        }
                    }
            case let dataSource as ModuModel:
                ModuSummaryView(modu: ModuListModel(moduModel: dataSource))
                    .showBookmarkNotes(true)
                    .onTapGesture {
                        if let name = dataSource.name {
                            router.path.append(ModuRoute.detail(name: name))
                        }
                    }
            case let dataSource as PortModel:
                PortSummaryView(port: PortListModel(portModel: dataSource))
                    .showBookmarkNotes(true)
                    .onTapGesture {
                        router.path.append(PortRoute.detail(portNumber: dataSource.portNumber))
                    }
            case let dataSource as LightModel:
                LightSummaryView(light: LightListModel(lightModel: dataSource))
                    .showBookmarkNotes(true)
                    .onTapGesture {
                        if let featureNumber = dataSource.featureNumber, let volumeNumber = dataSource.volumeNumber {
                            router.path.append(
                                LightRoute.detail(volumeNumber: volumeNumber, featureNumber: featureNumber)
                            )
                        }
                    }
            case let dataSource as RadioBeaconModel:
                RadioBeaconSummaryView(radioBeacon: RadioBeaconListModel(radioBeaconModel: dataSource))
                    .showBookmarkNotes(true)
                    .onTapGesture {
                        if let featureNumber = dataSource.featureNumber, let volumeNumber = dataSource.volumeNumber {
                            router.path.append(
                                RadioBeaconRoute.detail(featureNumber: featureNumber, volumeNumber: volumeNumber)
                            )
                        }
                    }
            case let dataSource as DGPSStationModel:
                DGPSStationSummaryView(
                    dgpsStation: DGPSStationListModel(
                        dgpsStationModel: dataSource
                    )
                )
                .showBookmarkNotes(true)
                .onTapGesture {
                    if let featureNumber = dataSource.featureNumber, let volumeNumber = dataSource.volumeNumber {
                        router.path.append(
                            DGPSStationRoute.detail(featureNumber: featureNumber, volumeNumber: volumeNumber)
                        )
                    }
                }
            case let dataSource as NoticeToMarinersModel:
                NoticeToMarinersSummaryView(
                    noticeToMariners: NoticeToMarinersListModel(
                        noticeToMarinersModel: dataSource
                    )
                )
                .showBookmarkNotes(true)
                .onTapGesture {
                    if let noticeNumber = dataSource.noticeNumber {
                        router.path.append(NoticeToMarinersRoute.fullView(noticeNumber: noticeNumber))
                    }
                }
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
