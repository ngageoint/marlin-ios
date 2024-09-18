//
//  CoreDataDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 12/21/23.
//

import Foundation
import UIKit
import BackgroundTasks
import CoreData
import Combine

protocol CoreDataDataSource {
    typealias Page = Int
    
    func publisher<T: NSManagedObject>(for managedObject: T,
                                       in context: NSManagedObjectContext
    ) -> AnyPublisher<T, Never>
    func executeOperationInBackground(operation: CountingDataLoadOperation) async -> Int
    func buildPredicates(filters: [DataSourceFilterParameter]?) -> [NSPredicate]
    func boundsPredicate(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> NSPredicate
}
 
extension CoreDataDataSource {
    func publisher<T: NSManagedObject>(for managedObject: T,
                                       in context: NSManagedObjectContext
    ) -> AnyPublisher<T, Never> {
        let notification = NSManagedObjectContext.didSaveObjectsNotification
        return NotificationCenter.default.publisher(for: notification) // , object: context)
            .compactMap({ notification in
                if let updated = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>,
                   let updatedObject = updated.first(where: { object in
                       object.objectID == managedObject.objectID
                   }) as? T {
                    return updatedObject
                } else {
                    return nil
                }
            })
            .eraseToAnyPublisher()
    }

    func executeOperationInBackground(operation: CountingDataLoadOperation) async -> Int {
        MSI.shared.backgroundLoadQueue.addOperation(operation)

        return await withCheckedContinuation { continuation in
            // Inform the system that the background task is complete
            // when the operation completes.
            operation.completionBlock = {
                continuation.resume(returning: operation.count)
            }
        }
    }

    func buildPredicates(filters: [DataSourceFilterParameter]?) -> [NSPredicate] {
        var predicates: [NSPredicate] = []

        if let filters = filters {
            for filter in filters {
                let predicate = filter.toPredicate(
                    boundsPredicateBuilder: { bounds in
                        return self.boundsPredicate(
                            minLatitude: bounds.swCorner.y,
                            maxLatitude: bounds.neCorner.y,
                            minLongitude: bounds.swCorner.x,
                            maxLongitude: bounds.swCorner.y
                        )
                    })
                if let predicate = predicate {
                    predicates.append(predicate)
                }
            }
        }

        return predicates
    }

    func boundsPredicate(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) -> NSPredicate {
        return NSPredicate(
            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
            minLatitude,
            maxLatitude,
            minLongitude,
            maxLongitude)
    }
}
