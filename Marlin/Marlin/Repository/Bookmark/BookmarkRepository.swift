//
//  BookmarkRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/19/23.
//

import Foundation
import Combine

enum BookmarkItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let bookmark):
            return "\(bookmark.dataSource ?? "")--\(bookmark.itemKey ?? "")"
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ bookmark: BookmarkModel)
    case sectionHeader(header: String)
}

class BookmarkRepository: ObservableObject {
    let localDataSource: BookmarkLocalDataSource

    @Injected(\.asamRepository)
    var asamRepository: AsamRepository
    @Injected(\.dgpsRepository)
    var dgpsRepository: DGPSStationRepository
    @Injected(\.lightRepository)
    var lightRepository: LightRepository
    @Injected(\.moduRepository)
    var moduRepository: ModuRepository
    @Injected(\.portRepository)
    var portRepository: PortRepository
    @Injected(\.radioBeaconRepository)
    var radioBeaconRepository: RadioBeaconRepository
    let noticeToMarinersRepository: NoticeToMarinersRepository?
    @Injected(\.publicationRepository)
    var publicationRepository: PublicationRepository
    @Injected(\.navWarningRepository)
    var navigationalWarningRepository: NavigationalWarningRepository

    init(
        localDataSource: BookmarkLocalDataSource,
        noticeToMarinersRepository: NoticeToMarinersRepository? = nil
    ) {
        self.localDataSource = localDataSource
        self.noticeToMarinersRepository = noticeToMarinersRepository
    }

    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel? {
        localDataSource.getBookmark(itemKey: itemKey, dataSource: dataSource)
    }

    func createBookmark(notes: String?, itemKey: String, dataSource: String) async {
        await localDataSource.createBookmark(notes: notes, itemKey: itemKey, dataSource: dataSource)
    }

    func removeBookmark(itemKey: String, dataSource: String) -> Bool {
        localDataSource.removeBookmark(itemKey: itemKey, dataSource: dataSource)
    }

    func bookmarks(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[BookmarkItem], Error> {
        localDataSource.bookmarks(filters: filters, paginatedBy: paginator)
    }

    func getDataSourceItem(itemKey: String, dataSource: String) -> (any Bookmarkable)? {
        let split = itemKey.split(separator: "--")
        switch dataSource {
        case DataSources.asam.key:
            return asamRepository.getAsam(reference: itemKey)
        case DataSources.modu.key:
            return moduRepository.getModu(name: itemKey)
        case DataSources.port.key:
            return portRepository.getPort(portNumber: Int(itemKey))
        case DataSources.navWarning.key:
            if split.count == 3 {
                return navigationalWarningRepository.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? 0,
                    msgNumber: Int(split[1]) ?? 0,
                    navArea: "\(split[2])"
                )
            }
        case DataSources.noticeToMariners.key:
            return noticeToMarinersRepository?.getNoticesToMariners(noticeNumber: Int(itemKey))?.first
        case DataSources.dgps.key:
            if split.count == 2 {
                return dgpsRepository.getDGPSStation(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
        case DataSources.light.key:
            if split.count == 3 {
                return lightRepository.getCharacteristic(
                    featureNumber: "\(split[0])",
                    volumeNumber: "\(split[1])",
                    characteristicNumber: 1
                )
            }
        case DataSources.radioBeacon.key:
            if split.count == 2 {
                return radioBeaconRepository.getRadioBeacon(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
        case DataSources.epub.key:
            return publicationRepository.getPublication(s3Key: itemKey)
        case GeoPackageFeatureItem.key:
            return GeoPackageFeatureItem.getItem(
                context: PersistenceController.current.newTaskContext(),
                itemKey: itemKey
            )
        default:
            print("default")
        }
        return nil
    }
}
