//
//  DifferentialGPSStationRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/25/23.
//

import Foundation
import CoreData

protocol DifferentialGPSStationRepository {
    @discardableResult
    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> DifferentialGPSStationModel?
}

class DifferentialGPSStationRepositoryManager: DifferentialGPSStationRepository, ObservableObject {
    private var repository: DifferentialGPSStationRepository
    init(repository: DifferentialGPSStationRepository) {
        self.repository = repository
    }
    
    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> DifferentialGPSStationModel? {
        repository.getDifferentialGPSStation(featureNumber: featureNumber, volumeNumber: volumeNumber, waypointURI: waypointURI)
    }
}

class DifferentialGPSStationCoreDataRepository: DifferentialGPSStationRepository, ObservableObject {
    private var context: NSManagedObjectContext
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?, waypointURI: URL?) -> DifferentialGPSStationModel? {
        if let featureNumber = featureNumber, let volumeNumber = volumeNumber {
            if let dgps = try? context.fetchFirst(DifferentialGPSStation.self, predicate: NSPredicate(format: "featureNumber = %ld AND volumeNumber = %@", argumentArray: [featureNumber, volumeNumber])) {
                return DifferentialGPSStationModel(differentialGPSStation: dgps)
            }
        }
        return nil
    }
}
