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

private struct BookmarkRepositoryProviderKey: InjectionKey {
    static var currentValue: BookmarkRepository = BookmarkRepository()
}

extension InjectedValues {
    var bookmarkRepository: BookmarkRepository {
        get { Self[BookmarkRepositoryProviderKey.self] }
        set { Self[BookmarkRepositoryProviderKey.self] = newValue }
    }
}

actor BookmarkRepository: ObservableObject {
    @Injected(\.bookmarkLocalDataSource)
    private var localDataSource: BookmarkLocalDataSource

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
    @Injected(\.ntmRepository)
    private var noticeToMarinersRepository: NoticeToMarinersRepository
    @Injected(\.publicationRepository)
    var publicationRepository: PublicationRepository
    @Injected(\.navWarningRepository)
    var navigationalWarningRepository: NavigationalWarningRepository

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

    func getDataSourceItem(itemKey: String, dataSource: String) async -> (any Bookmarkable)? {
        let split = itemKey.split(separator: "--")
        switch dataSource {
        case DataSources.asam.key:
            return await asamRepository.getAsam(reference: itemKey)
        case DataSources.modu.key:
            return await moduRepository.getModu(name: itemKey)
        case DataSources.port.key:
            return await portRepository.getPort(portNumber: Int(itemKey))
        case DataSources.navWarning.key:
            if split.count == 3 {
                return navigationalWarningRepository.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? 0,
                    msgNumber: Int(split[1]) ?? 0,
                    navArea: "\(split[2])"
                )
            }
        case DataSources.noticeToMariners.key:
            return await noticeToMarinersRepository.getNoticesToMariners(noticeNumber: Int(itemKey))?.first
        case DataSources.dgps.key:
            if split.count == 2 {
                return await dgpsRepository.getDGPSStation(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
        case DataSources.light.key:
            if split.count == 3 {
                return await lightRepository.getCharacteristic(
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
            return await publicationRepository.getPublication(s3Key: itemKey)
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
