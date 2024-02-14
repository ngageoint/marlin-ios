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

    var list: [AsamModel] = []

    func getNewestAsam() -> Marlin.AsamModel? {
        list.isEmpty ? nil : list[0]
    }
    
    func getAsam(reference: String?) -> Marlin.AsamModel? {
        list.first { model in
            model.reference == reference
        }
    }
    
    func getAsamsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.AsamModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { asam in
             minLatitude...maxLatitude ~= asam.latitude && minLongitude...maxLongitude ~= asam.longitude
        }
    }
    
    func asams(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.AsamItem], Error> {
        AnyPublisher(Just(list.map({ model in
            AsamItem.listItem(AsamListModel(asamModel:model))
        })).setFailureType(to: Error.self))
    }
    
    func getAsams(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.AsamModel] {
        list
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }
    
    func insert(task: BGTask?, asams: [Marlin.AsamModel]) async -> Int {
        NSLog("Insert asams \(asams.count)")
        list.append(contentsOf: asams)
        return asams.count
    }
    
    func batchImport(from propertiesList: [Marlin.AsamModel]) async throws -> Int {
        list.append(contentsOf: propertiesList)
        return propertiesList.count
    }
    

}
