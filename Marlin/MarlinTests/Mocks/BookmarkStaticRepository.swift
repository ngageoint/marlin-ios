//
//  BookmarkStaticRepository.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/10/24.
//

import Foundation

@testable import Marlin

class BookmarkStaticRepository: BookmarkRepository {
    var bookmarks: [String: BookmarkModel] = [:]
    let asamRepository: AsamRepository?
    let dgpsRepository: DGPSStationRepository?
    let lightRepository: LightRepository?
    let moduRepository: ModuRepository?
    let portRepository: PortRepository?
    let radioBeaconRepository: RadioBeaconRepository?
    let noticeToMarinersRepository: NoticeToMarinersRepository?
    let publicationRepository: PublicationRepository?
    let navigationalWarningRepository: NavigationalWarningRepository?
    let differentialGPSStationRepository: DGPSStationRepository?

    init(
        asamRepository: AsamRepository? = nil,
        dgpsRepository: DGPSStationRepository? = nil,
        lightRepository: LightRepository? = nil,
        moduRepository: ModuRepository? = nil,
        portRepository: PortRepository? = nil,
        radioBeaconRepository: RadioBeaconRepository? = nil,
        noticeToMarinersRepository: NoticeToMarinersRepository? = nil,
        electronicPublicationRepository: PublicationRepository? = nil,
        navigationalWarningRepository: NavigationalWarningRepository? = nil,
        differentialGPSStationRepository: DGPSStationRepository? = nil
    ) {
        self.asamRepository = asamRepository
        self.dgpsRepository = dgpsRepository
        self.lightRepository = lightRepository
        self.moduRepository = moduRepository
        self.portRepository = portRepository
        self.radioBeaconRepository = radioBeaconRepository
        self.noticeToMarinersRepository = noticeToMarinersRepository
        self.publicationRepository = electronicPublicationRepository
        self.navigationalWarningRepository = navigationalWarningRepository
        self.differentialGPSStationRepository = differentialGPSStationRepository
    }
    func createBookmark(notes: String?, itemKey: String, dataSource: String) async {
        let model = BookmarkModel(dataSource: dataSource, id: itemKey, itemKey: itemKey, notes: notes, timestamp: Date())
        bookmarks["\(dataSource)--\(itemKey)"] = model
        NSLog("Create: Bookmarks is \(bookmarks)")
    }
    
    func getBookmark(itemKey: String, dataSource: String) -> Marlin.BookmarkModel? {
        NSLog("Get: Bookmarks is \(bookmarks)")
        NSLog("get the bookmark for \(dataSource)--\(itemKey)")
        return bookmarks["\(dataSource)--\(itemKey)"]
    }

    func removeBookmark(itemKey: String, dataSource: String) -> Bool {
        NSLog("Remove: Bookmarks is \(bookmarks)")
        bookmarks["\(dataSource)--\(itemKey)"] = nil
        return true
    }

    func getDataSourceItem(itemKey: String, dataSource: String) -> (any Bookmarkable)? {
        NSLog("GetDataSource Item: Bookmarks is \(bookmarks)")
        let split = itemKey.split(separator: "--")
        switch dataSource {
        case DataSources.asam.key:
            return asamRepository?.getAsam(reference: itemKey)
        case DataSources.modu.key:
            return moduRepository?.getModu(name: itemKey)
        case DataSources.port.key:
            return portRepository?.getPort(portNumber: Int64(itemKey))
        case NavigationalWarning.key:
            if split.count == 3 {
                return navigationalWarningRepository?.getNavigationalWarning(
                    msgYear: Int(split[0]) ?? 0,
                    msgNumber: Int(split[1]) ?? 0,
                    navArea: "\(split[2])"
                )
            }
        case DataSources.noticeToMariners.key:
            return noticeToMarinersRepository?.getNoticesToMariners(noticeNumber: Int(itemKey))?.first
        case DataSources.dgps.key:
            if split.count == 2 {
                return dgpsRepository?.getDGPSStation(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
        case DataSources.light.key:
            if split.count == 3 {
                return lightRepository?.getCharacteristic(
                    featureNumber: "\(split[0])",
                    volumeNumber: "\(split[1])",
                    characteristicNumber: 1
                )
            }
        case DataSources.radioBeacon.key:
            if split.count == 2 {
                return radioBeaconRepository?.getRadioBeacon(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
        case DataSources.epub.key:
            return publicationRepository?.getPublication(s3Key: itemKey)
//        case GeoPackageFeatureItem.key:
//            if let context = context {
//                return GeoPackageFeatureItem.getItem(context: context, itemKey: self.id)
//            }
        default:
            print("default")
        }
        return nil
    }
}
