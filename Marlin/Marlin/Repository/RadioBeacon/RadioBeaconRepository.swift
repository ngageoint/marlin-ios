//
//  RadioBeaconRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/27/23.
//

import Foundation
import CoreData

enum RadioBeaconItem: Hashable, Identifiable {
    var id: String {
        switch self {
        case .listItem(let radioBeacon):
            return radioBeacon.id
        case .sectionHeader(let header):
            return header
        }
    }

    case listItem(_ radioBeacon: RadioBeaconListModel)
    case sectionHeader(header: String)
}

protocol RadioBeaconRepository {
    @discardableResult
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel?
    func getCount(filters: [DataSourceFilterParameter]?) -> Int
}

class RadioBeaconRepositoryManager: RadioBeaconRepository, ObservableObject {
    private var repository: RadioBeaconRepository
    init(repository: RadioBeaconRepository) {
        self.repository = repository
    }
    
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel? {
        repository.getRadioBeacon(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        repository.getCount(filters: filters)
    }
}

class RadioBeaconCoreDataRepository: RadioBeaconRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getRadioBeacon(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> RadioBeaconModel? {
        if let waypointURI = waypointURI {
            if let id = context.persistentStoreCoordinator?.managedObjectID(
                forURIRepresentation: waypointURI
            ), let waypoint = try? context.existingObject(with: id) as? RouteWaypoint {
                let dataSource = waypoint.decodeToDataSource()
                if let dataSource = dataSource as? RadioBeaconModel {
                    return dataSource
                }
            }
        }
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            if let radioBeacon = try? context.fetchFirst(
                RadioBeacon.self,
                predicate: NSPredicate(
                    format: "featureNumber = %ld AND volumeNumber = %@",
                    argumentArray: [featureNumber, volumeNumber])
            ) {
                return RadioBeaconModel(radioBeacon: radioBeacon)
            }
        }
        return nil
    }
    
    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        guard let fetchRequest = AsamFilterable().fetchRequest(filters: filters, commonFilters: nil) else {
            return 0
        }
        return (try? context.count(for: fetchRequest)) ?? 0
    }
}
