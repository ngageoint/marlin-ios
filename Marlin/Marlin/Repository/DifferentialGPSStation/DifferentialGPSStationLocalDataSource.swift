//
//  DifferentialGPSStationLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

protocol DifferentialGPSStationLocalDataSource {
    func getNewestDifferentialGPSStation() -> DifferentialGPSStationModel?
    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?) -> DifferentialGPSStationModel?
    func getDifferentialGPSStationsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [DifferentialGPSStationModel]

    func getCount(filters: [DataSourceFilterParameter]?) -> Int
    func insert(task: BGTask?, dgpss: [DifferentialGPSStationModel]) async -> Int
    func batchImport(from propertiesList: [DifferentialGPSStationModel]) async throws -> Int
}

class DifferentialGPSStationCoreDataDataSource: 
    CoreDataDataSource,
    DifferentialGPSStationLocalDataSource,
    ObservableObject {
    private lazy var context: NSManagedObjectContext = {
        PersistenceController.current.newTaskContext()
    }()

    func getNewestDifferentialGPSStation() -> DifferentialGPSStationModel? {
        var model: DifferentialGPSStationModel?
        context.performAndWait {
            if let newestDifferentialGPSStation =
            try? PersistenceController.current.fetchFirst(
                DifferentialGPSStation.self,
                sortBy: [
                    NSSortDescriptor(keyPath: \DifferentialGPSStation.noticeNumber, ascending: false)
                ],
                predicate: nil,
                context: context) {
                model = DifferentialGPSStationModel(differentialGPSStation: newestDifferentialGPSStation)
            }
        }
        return model
    }

    func getDifferentialGPSStation(featureNumber: Int?, volumeNumber: String?) -> DifferentialGPSStationModel? {
        guard let featureNumber = featureNumber, let volumeNumber = volumeNumber else {
            return nil
        }
        if let dgps = try? context.fetchFirst(
            DifferentialGPSStation.self,
            predicate: NSPredicate(
                format: "featureNumber = %ld AND volumeNumber = %@",
                argumentArray: [featureNumber, volumeNumber])) {
            return DifferentialGPSStationModel(differentialGPSStation: dgps)
        }
        return nil
    }

    func getDifferentialGPSStationsInBounds(
        filters: [DataSourceFilterParameter]?,
        minLatitude: Double?,
        maxLatitude: Double?,
        minLongitude: Double?,
        maxLongitude: Double?
    ) -> [DifferentialGPSStationModel] {
        var dgpss: [DifferentialGPSStationModel] = []
        // TODO: this should probably execute on a different context and be a perform
        context.performAndWait {
            let fetchRequest = DifferentialGPSStation.fetchRequest()
            var predicates: [NSPredicate] = buildPredicates(filters: filters)

            if let minLatitude = minLatitude,
               let maxLatitude = maxLatitude,
               let minLongitude = minLongitude,
               let maxLongitude = maxLongitude {
                predicates.append(NSPredicate(
                    format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
                    minLatitude,
                    maxLatitude,
                    minLongitude,
                    maxLongitude
                ))
            }

            let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            fetchRequest.predicate = predicate

            fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.dgps.key).map({ sortParameter in
                sortParameter.toNSSortDescriptor()
            })
            dgpss = (context.fetch(request: fetchRequest)?.map { dgps in
                DifferentialGPSStationModel(differentialGPSStation: dgps)
            }) ?? []
        }
        return dgpss
    }

    func getCount(filters: [DataSourceFilterParameter]?) -> Int {
        let fetchRequest = DifferentialGPSStation.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)

        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = predicate

        fetchRequest.sortDescriptors = UserDefaults.standard.sort(DataSources.dgps.key).map({ sortParameter in
            sortParameter.toNSSortDescriptor()
        })

        var count = 0
        context.performAndWait {
            count = (try? context.count(for: fetchRequest)) ?? 0
        }
        return count
    }

    func insert(task: BGTask? = nil, dgpss: [DifferentialGPSStationModel]) async -> Int {
        let count = dgpss.count
        NSLog("Received \(count) \(DataSources.dgps.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = DifferentialGPSStationDataLoadOperation(dgpss: dgpss, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [DifferentialGPSStationModel]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDgps"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) DGPS records")
                    return count
                } else {
                    NSLog("No new DGPS records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [DifferentialGPSStationModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: DifferentialGPSStation.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            dictionary.addEntries(from: propertyDictionary.mapValues({ value in
                if let value = value {
                    return value
                }
                return NSNull()
            }) as [AnyHashable: Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
}
