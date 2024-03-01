//
//  LightCoreDataDataSourceImport.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks
import Kingfisher

// MARK: Import methods
extension LightCoreDataDataSource {

    func insert(task: BGTask? = nil, lights: [ModelType]) async -> Int {
        let count = lights.count
        NSLog("Received \(count) \(DataSources.light.key) records.")

        // Create an operation that performs the main part of the background task.
        operation = LightDataLoadOperation(lights: lights, localDataSource: self)

        return await executeOperationInBackground(task: task)
    }

    func batchImport(from propertiesList: [ModelType]) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        let taskContext = PersistenceController.current.newTaskContext()
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importLight"

        let count = try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                try? taskContext.save()
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) light records")
                    return count
                } else {
                    NSLog("No new light records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
        return count
    }

    func newBatchInsertRequest(with propertyList: [ModelType]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count

        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(
            entity: DataType.entity(),
            dictionaryHandler: { dictionary in
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
            }
        )
        return batchInsertRequest
    }

    func postProcess() async {
        Kingfisher.ImageCache(name: DataSources.light.key).clearCache()
        //        imageCache.clearCache()
        let fetchRequest = NSFetchRequest<Light>(entityName: "Light")
        fetchRequest.predicate = NSPredicate(format: "requiresPostProcessing == true")
        let context = PersistenceController.current.newTaskContext()
        await context.perform {
            if let objects = try? context.fetch(fetchRequest) {
                if !objects.isEmpty {
                    for light in objects {
                        var ranges: [LightRange] = []
                        light.requiresPostProcessing = false
                        if let rangeString = light.range {
                            for rangeSplit in rangeString.components(
                                separatedBy: CharacterSet(charactersIn: ";\n")
                            ) {
                                let colorSplit = rangeSplit
                                    .trimmingCharacters(in: .whitespacesAndNewlines)
                                    .components(separatedBy: ". ")
                                if colorSplit.count == 2, let doubleRange = Double(colorSplit[1]) {
                                    let lightRange = LightRange(context: context)
                                    lightRange.light = light
                                    lightRange.color = colorSplit[0]
                                    lightRange.range = doubleRange
                                    ranges.append(lightRange)

                                }
                            }
                        }
                        light.lightRange = NSSet(array: ranges)
                    }
                }
            }
            try? context.save()
        }
        NotificationCenter.default.post(
            Notification(name: .DataSourceProcessed, object: DataSourceUpdatedNotification(key: DataSources.light.key))
        )

    }
}
