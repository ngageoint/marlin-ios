//
//  PortStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class PortStaticLocalDataSource: PortLocalDataSource {
    var list: [PortModel] = []

    func getPort(portNumber: Int64?) -> Marlin.PortModel? {
        list.first { model in
            model.portNumber == Int(portNumber ?? -1)
        }
    }
    
    func getPortsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.PortModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { port in
            minLatitude...maxLatitude ~= port.latitude && minLongitude...maxLongitude ~= port.longitude
        }
    }
    
    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }
    
    func getPorts(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.PortModel] {
        list
    }
    
    func insert(task: BGTask?, ports: [Marlin.PortModel]) async -> Int {
        list.append(contentsOf: ports)
        return ports.count
    }
    
    func batchImport(from propertiesList: [Marlin.PortModel]) async throws -> Int {
        list.append(contentsOf: propertiesList)
        return propertiesList.count
    }
    
    func ports(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.PortItem], Error> {
        AnyPublisher(Just(list.map({ model in
            PortItem.listItem(PortListModel(portModel:model))
        })).setFailureType(to: Error.self))
    }
}
