//
//  RadioBeaconRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/27/23.
//

import Foundation
import CoreData

/**
 if let split = itemKey?.split(separator: "--"), split.count == 2 {
 return getRadioBeacon(context: context, featureNumber: "\(split[0])", volumeNumber: "\(split[1])")
 }
 */

protocol RadioBeaconRepository {
    @discardableResult
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel?
}

class RadioBeaconRepositoryManager: RadioBeaconRepository, ObservableObject {
    private var repository: RadioBeaconRepository
    init(repository: RadioBeaconRepository) {
        self.repository = repository
    }
    
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel? {
        repository.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
    }
}

class RadioBeaconCoreDataRepository: RadioBeaconRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: waypointURI), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? RadioBeaconModel {
                    return dataSource
                }
            }
        }
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            if let rb = try? context.fetchFirst(RadioBeacon.self, predicate: NSPredicate(format: "featureNumber = %ld AND volumeNumber = %@", argumentArray: [featureNumber, volumeNumber])) {
                return RadioBeaconModel(radioBeacon: rb)
            }
        }
        return nil
    }
}
