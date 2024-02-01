//
//  CoreDataDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 12/21/23.
//

import Foundation
import UIKit
import BackgroundTasks

class CoreDataDataSource {
    typealias Page = Int
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var cleanup: (() -> Void)?
    var operation: CountingDataLoadOperation?

    lazy var backgroundLoadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "\(NSStringFromClass(type(of: self))) load queue"
        return queue
    }()

    func registerBackgroundTask(name: String) {
        NSLog("Register the background task \(name)")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: name) { [weak self] in
            NSLog("iOS has signaled time has expired \(name)")
            self?.cleanup?()
            print("canceling \(name)")
            self?.operation?.cancel()
            print("calling endBackgroundTask \(name)")
            self?.endBackgroundTaskIfActive()
        }
    }

    func endBackgroundTaskIfActive() {
        let isBackgroundTaskActive = backgroundTask != .invalid
        if isBackgroundTaskActive {
            NSLog("Background task ended. \(NSStringFromClass(type(of: self))) Load")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    func executeOperationInBackground(task: BGTask? = nil) async -> Int {
        if let task = task {
            registerBackgroundTask(name: task.identifier)
            guard backgroundTask != .invalid else { return 0 }
        }

        // Provide the background task with an expiration handler that cancels the operation.
        task?.expirationHandler = {
            self.operation?.cancel()
        }

        // Start the operation.
        if let operation = operation {
            self.backgroundLoadQueue.addOperation(operation)
        }

        return await withCheckedContinuation { continuation in
            // Inform the system that the background task is complete
            // when the operation completes.
            operation?.completionBlock = {
                task?.setTaskCompleted(success: !(self.operation?.isCancelled ?? false))
                continuation.resume(returning: self.operation?.count ?? 0)
            }
        }
    }

    func buildPredicates(filters: [DataSourceFilterParameter]?) -> [NSPredicate] {
        var predicates: [NSPredicate] = []

        if let filters = filters {
            for filter in filters {
                let predicate = filter.toPredicate(
                    boundsPredicateBuilder: { bounds in
                        return NSPredicate(
                            format: "latitude >= %lf AND latitude <= %lf AND longitude >= %lf AND longitude <= %lf",
                            bounds.swCorner.y,
                            bounds.neCorner.y,
                            bounds.swCorner.x,
                            bounds.swCorner.y
                        )
                    })
                if let predicate = predicate {
                    predicates.append(predicate)
                }
            }
        }

        return predicates
    }
}
