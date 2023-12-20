//
//  LightRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/18/23.
//

import Foundation
import CoreData

protocol LightRepository {
    @discardableResult
    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel]
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class LightRepositoryManager: LightRepository, ObservableObject {
    private var repository: LightRepository
    init(repository: LightRepository) {
        self.repository = repository
    }
    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel] {
        repository.getLights(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
    }
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
}

class LightCoreDataRepository: LightRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getLights(featureNumber: String?, volumeNumber: String?, waypointURI: URL?) -> [LightModel] {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: waypointURI),
               let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? LightModel {
                    return [dataSource]
                }
            }
        }
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            if let lights = try? context.fetchObjects(
                Light.self,
                predicate: NSPredicate(
                    format: "featureNumber = %@ AND volumeNumber = %@",
                    argumentArray: [featureNumber, volumeNumber]
                )
            ) {
                var models: [LightModel] = []
                for light in lights {
                    models.append(LightModel(light: light))
                }
                return models
            }
        }
        return []
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = LightFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
