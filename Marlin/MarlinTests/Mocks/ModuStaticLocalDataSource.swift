//
//  ModuStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class ModuStaticLocalDataSource: ModuLocalDataSource {
    var list: [ModuModel] = []

    func insert(task: BGTask?, modus: [Marlin.ModuModel]) async -> Int {
        list.append(contentsOf: modus)
        return modus.count
    }

    func batchImport(from propertiesList: [Marlin.ModuModel]) async throws -> Int {
        list.append(contentsOf: propertiesList)
        return propertiesList.count
    }

    func getNewestModu() -> Marlin.ModuModel? {
        list.isEmpty ? nil : list[0]
    }

    func getModus(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.ModuModel] {
        list
    }

    func getModusInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) -> [Marlin.ModuModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { modu in
            minLatitude...maxLatitude ~= modu.latitude && minLongitude...maxLongitude ~= modu.longitude
        }
    }

    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }

    func getModu(name: String?) -> Marlin.ModuModel? {
        list.first { model in
            model.name == name
        }
    }

    func modus(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.ModuItem], Error> {
        AnyPublisher(Just(list.map({ model in
            ModuItem.listItem(ModuListModel(moduModel:model))
        })).setFailureType(to: Error.self))
    }


}
