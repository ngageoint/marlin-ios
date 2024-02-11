//
//  AsamStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/10/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class AsamStaticLocalDataSource: AsamLocalDataSource {

    var asamList: [AsamModel] = []

    func getNewestAsam() -> Marlin.AsamModel? {
        asamList.isEmpty ? nil : asamList[0]
    }
    
    func getAsam(reference: String?) -> Marlin.AsamModel? {
        asamList.first { model in
            model.reference == reference
        }
    }
    
    func getAsamsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.AsamModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return asamList.filter { asam in
             minLatitude...maxLatitude ~= asam.latitude && minLongitude...maxLongitude ~= asam.longitude
        }
    }
    
    func asams(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.AsamItem], Error> {
        AnyPublisher(Just([]).setFailureType(to: Error.self))

    }
    
    func getAsams(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.AsamModel] {
        asamList
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        asamList.count
    }
    
    func insert(task: BGTask?, asams: [Marlin.AsamModel]) async -> Int {
        0
    }
    
    func batchImport(from propertiesList: [Marlin.AsamModel]) async throws -> Int {
        0
    }
    

}
