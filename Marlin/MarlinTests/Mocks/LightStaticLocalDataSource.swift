//
//  LightStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class LightStaticLocalDataSource: LightLocalDataSource {
    var list: [LightModel] = []

    func getCharacteristic(featureNumber: String?, volumeNumber: String?, characteristicNumber: Int64) -> Marlin.LightModel? {
        list.first { model in
            model.featureNumber == featureNumber &&
            model.volumeNumber == volumeNumber &&
            model.characteristicNumber == Int(characteristicNumber)
        }
    }
    
    func getLight(featureNumber: String?, volumeNumber: String?) -> [Marlin.LightModel]? {
        list.filter { model in
            model.featureNumber == featureNumber &&
            model.volumeNumber == volumeNumber
        }
    }
    
    func getNewestLight(volumeNumber: String) -> Marlin.LightModel? {
        list.first { model in
            model.volumeNumber == volumeNumber
        }
    }
    
    func getLightsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.LightModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { light in
            minLatitude...maxLatitude ~= light.latitude && minLongitude...maxLongitude ~= light.longitude
        }
    }
    
    func lights(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.LightItem], Error> {
        AnyPublisher(Just([]).setFailureType(to: Error.self))
    }
    
    func getLights(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.LightModel] {
        list
    }
    
    func volumeCount(volumeNumber: String) -> Int {
        list.filter { model in
            model.volumeNumber == volumeNumber
        }.count
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }
    
    func insert(task: BGTask?, lights: [Marlin.LightModel]) async -> Int {
        list.append(contentsOf: lights)
        return lights.count
    }
    
    func batchImport(from propertiesList: [Marlin.LightModel]) async throws -> Int {
        0
    }
    
    func postProcess() async {

    }
    

}
