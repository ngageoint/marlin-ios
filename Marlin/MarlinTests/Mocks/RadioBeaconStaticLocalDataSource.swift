//
//  RadioBeaconStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class RadioBeaconStaticLocalDataSource: RadioBeaconLocalDataSource {
    var list: [RadioBeaconModel] = []

    func getNewestRadioBeacon() -> Marlin.RadioBeaconModel? {
        list.isEmpty ? nil : list[0]
    }
    
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?) -> Marlin.RadioBeaconModel? {
        list.first { model in
            model.featureNumber == featureNumber && model.volumeNumber == volumeNumber
        }
    }
    
    func getRadioBeaconsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.RadioBeaconModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { beacon in
            minLatitude...maxLatitude ~= beacon.latitude && minLongitude...maxLongitude ~= beacon.longitude
        }
    }
    
    func getRadioBeacons(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.RadioBeaconModel] {
        list
    }
    
    func radioBeacons(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.RadioBeaconItem], Error> {
        AnyPublisher(Just(list.map({ model in
            RadioBeaconItem.listItem(RadioBeaconListModel(radioBeaconModel:model))
        })).setFailureType(to: Error.self))
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }
    
    func insert(task: BGTask?, radioBeacons: [Marlin.RadioBeaconModel]) async -> Int {
        list.append(contentsOf: radioBeacons)
        return radioBeacons.count
    }
    
    func batchImport(from propertiesList: [Marlin.RadioBeaconModel]) async throws -> Int {
        list.append(contentsOf: propertiesList)
        return propertiesList.count
    }
}
