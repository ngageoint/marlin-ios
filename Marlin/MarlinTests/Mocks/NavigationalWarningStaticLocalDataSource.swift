//
//  NavigationalWarningStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/22/24.
//

import Foundation
import Combine
import BackgroundTasks

@testable import Marlin

class NavigationalWarningStaticLocalDataSource: NavigationalWarningLocalDataSource {
    func getNavAreasInformation() async -> [Marlin.NavigationalAreaInformation] {
        []
    }
    
    func postProcess() async {

    }
    
    var list: [NavigationalWarningModel] = []
    func getNavigationalWarning(msgYear: Int, msgNumber: Int, navArea: String?) -> Marlin.NavigationalWarningModel? {
        list.first { model in
            (model.msgYear ?? -1) == msgYear && (model.msgNumber ?? -1) == msgNumber && model.navArea == navArea
        }
    }

    func getNavigationalWarningsInBounds(filters: [Marlin.DataSourceFilterParameter]?, minLatitude: Double?, maxLatitude: Double?, minLongitude: Double?, maxLongitude: Double?) async -> [NavigationalWarningModel] {
        guard let minLatitude = minLatitude, let maxLatitude = maxLatitude, let minLongitude = minLongitude, let maxLongitude = maxLongitude else {
            return []
        }
        return list.filter { warning in
            minLatitude...maxLatitude ~= warning.latitude ?? 0.0 && minLongitude...maxLongitude ~= warning.longitude ?? 0.0
        }
    }

    func getNavigationalWarnings(filters: [Marlin.DataSourceFilterParameter]?) async -> [Marlin.NavigationalWarningModel] {
        list
    }

    func navigationalWarnings(filters: [Marlin.DataSourceFilterParameter]?, paginatedBy paginator: Marlin.Trigger.Signal?) -> AnyPublisher<[Marlin.NavigationalWarningItem], Error> {
        AnyPublisher(Just(list.map({ model in
            NavigationalWarningItem.listItem(model)
        })).setFailureType(to: Error.self))
    }

    func getCount(filters: [Marlin.DataSourceFilterParameter]?) -> Int {
        list.count
    }

    func insert(task: BGTask?, navigationalWarnings: [Marlin.NavigationalWarningModel]) async -> Int {
        list.append(contentsOf: navigationalWarnings)
        return navigationalWarnings.count
    }

    func batchImport(from propertiesList: [Marlin.NavigationalWarningModel]) async throws -> Int {
        list.append(contentsOf: propertiesList)
        return list.count
    }


}
