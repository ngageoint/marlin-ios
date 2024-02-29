//
//  DifferentialGPSStationStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/12/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class DifferentialGPSStationStaticLocalDataSource: DGPSStationLocalDataSource {
    var list: [DGPSStationModel] = []

    func getNewestDifferentialGPSStation() -> Marlin.DGPSStationModel? {
        list.isEmpty ? nil : list[0]
    }
    
    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?) -> Marlin.DGPSStationModel? {
        list.first { model in
            model.featureNumber == featureNumber && model.volumeNumber == volumeNumber
        }
    }
    
    func getDifferentialGPSStationsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.DGPSStationModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { dgps in
            minLatitude...maxLatitude ~= dgps.latitude && minLongitude...maxLongitude ~= dgps.longitude
        }
    }
    
    func dgps(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.DGPSStationItem], Error> {
        AnyPublisher(Just([]).setFailureType(to: Error.self))
    }
    
    func getDifferentialGPSStations(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.DGPSStationModel] {
        list
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }
    
    func insert(task: BGTask?, dgpss: [Marlin.DGPSStationModel]) async -> Int {
        list.append(contentsOf: dgpss)
        return dgpss.count
    }
    
    func batchImport(from propertiesList: [Marlin.DGPSStationModel]) async throws -> Int {
        0
    }
}
