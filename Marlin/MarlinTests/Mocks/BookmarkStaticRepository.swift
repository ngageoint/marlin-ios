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
    let asamRepository: AsamRepository

    init(asamRepository: AsamRepository) {
        self.asamRepository = asamRepository
    }
    func createBookmark(notes: String?, itemKey: String, dataSource: String) async {
        var model = BookmarkModel(dataSource: dataSource, id: itemKey, itemKey: itemKey, notes: notes, timestamp: Date())
        bookmarks["\(dataSource)--\(itemKey)"] = model
    }
    
    func getBookmark(itemKey: String, dataSource: String) -> Marlin.BookmarkModel? {
        return bookmarks["\(dataSource)--\(itemKey)"]
    }

    func removeBookmark(itemKey: String, dataSource: String) -> Bool {
        bookmarks["\(dataSource)--\(itemKey)"] = nil
        return true
    }

    func getDataSourceItem(itemKey: String, dataSource: String) -> (any Bookmarkable)? {
        switch dataSource {
        case DataSources.asam.key:
            return asamRepository.getAsam(reference: itemKey)
//        case DataSources.modu.key:
//            return MSI.shared.moduRepository?.getModu(name: self.id)
//        case DataSources.port.key:
//            return MSI.shared.portRepository?.getPort(portNumber: Int64(self.id ?? ""))
//        case NavigationalWarning.key:
//            if let context = context {
//                return NavigationalWarning.getItem(context: context, itemKey: self.id)
//            }
//        case NoticeToMariners.key:
//            if let context = context {
//                return NoticeToMariners.getItem(context: context, itemKey: self.id)
//            }
//        case DataSources.dgps.key:
//            if let split = itemKey?.split(separator: "--"), split.count == 2 {
//                return MSI.shared.differentialGPSStationRepository?.getDifferentialGPSStation(
//                    featureNumber: Int(split[0]) ?? -1,
//                    volumeNumber: "\(split[1])"
//                )
//            }
//        case DataSources.light.key:
//            if let split = itemKey?.split(separator: "--"), split.count == 3 {
//                return MSI.shared.lightRepository?.getCharacteristic(
//                    featureNumber: "\(split[0])",
//                    volumeNumber: "\(split[1])",
//                    characteristicNumber: 1
//                )
//            }
//        case DataSources.radioBeacon.key:
//            if let split = itemKey?.split(separator: "--"), split.count == 2 {
//                return MSI.shared.radioBeaconRepository?.getRadioBeacon(
//                    featureNumber: Int(split[0]) ?? -1,
//                    volumeNumber: "\(split[1])"
//                )
//            }
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
