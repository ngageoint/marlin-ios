//
//  ModuRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import UIKit
import BackgroundTasks

class ModuRemoteDataSource {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    lazy var backgroundFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Modu fetch queue"
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
            NSLog("Background task ended. Modu Fetch")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }

    var cleanup: (() -> Void)?
    var operation: ModuDataFetchOperation?

    @discardableResult
    func fetchModus(task: BGTask? = nil, dateString: String? = nil) async -> [ModuModel] {

        if let task = task {
            registerBackgroundTask(name: task.identifier)
            guard backgroundTask != .invalid else { return [] }
        }

        // Create an operation that performs the main part of the background task.
        operation = ModuDataFetchOperation(dateString: dateString)

        // Provide the background task with an expiration handler that cancels the operation.
        task?.expirationHandler = {
            self.operation?.cancel()
        }

        NSLog("Start the operation to fetch Modus")
        // Start the operation.
        if let operation = operation {
            self.backgroundFetchQueue.addOperation(operation)
        }

        return await withCheckedContinuation { continuation in
            // Inform the system that the background task is complete
            // when the operation completes.
            operation?.completionBlock = {
                task?.setTaskCompleted(success: !(self.operation?.isCancelled ?? false))
                NSLog("Modu Remote Data Source modus count \(self.operation?.modus.count ?? 0)")
                continuation.resume(returning: self.operation?.modus ?? [])
            }
        }
    }
}
