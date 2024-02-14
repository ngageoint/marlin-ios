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
    let dgpsRepository: DifferentialGPSStationRepository?
    let lightRepository: LightRepository?
    let moduRepository: ModuRepository?
    let portRepository: PortRepository?
    let radioBeaconRepository: RadioBeaconRepository?

    init(
        asamRepository: AsamRepository? = nil,
        dgpsRepository: DifferentialGPSStationRepository? = nil,
        lightRepository: LightRepository? = nil,
        moduRepository: ModuRepository? = nil,
        portRepository: PortRepository? = nil,
        radioBeaconRepository: RadioBeaconRepository? = nil
    ) {
        self.asamRepository = asamRepository
        self.dgpsRepository = dgpsRepository
        self.lightRepository = lightRepository
        self.moduRepository = moduRepository
        self.portRepository = portRepository
        self.radioBeaconRepository = radioBeaconRepository
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
        switch dataSource {
        case DataSources.asam.key:
            return asamRepository?.getAsam(reference: itemKey)
        case DataSources.modu.key:
            return moduRepository?.getModu(name: itemKey)
        case DataSources.port.key:
            return portRepository?.getPort(portNumber: Int64(itemKey))
//        case NavigationalWarning.key:
//            if let context = context {
//                return NavigationalWarning.getItem(context: context, itemKey: self.id)
//            }
//        case NoticeToMariners.key:
//            if let context = context {
//                return NoticeToMariners.getItem(context: context, itemKey: self.id)
//            }
        case DataSources.dgps.key:
            let split = itemKey.split(separator: "--")
            if split.count == 2 {
                return dgpsRepository?.getDifferentialGPSStation(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
        case DataSources.light.key:
            let split = itemKey.split(separator: "--")
            if split.count == 3 {
                return lightRepository?.getCharacteristic(
                    featureNumber: "\(split[0])",
                    volumeNumber: "\(split[1])",
                    characteristicNumber: 1
                )
            }
        case DataSources.radioBeacon.key:
            let split = itemKey.split(separator: "--")
            if split.count == 2 {
                return radioBeaconRepository?.getRadioBeacon(
                    featureNumber: Int(split[0]) ?? -1,
                    volumeNumber: "\(split[1])"
                )
            }
//        case ElectronicPublication.key:
//            if let context = context {
//                return ElectronicPublication.getItem(context: context, itemKey: self.id)
//            }
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
