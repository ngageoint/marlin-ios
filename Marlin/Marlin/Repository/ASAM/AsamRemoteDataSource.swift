//
//  AsamRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 11/1/23.
//

import Foundation
import UIKit
import BackgroundTasks

class AsamRemoteDataSource {
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    lazy var asamBackgroundFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Asam fetch queue"
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
            NSLog("Background task ended. Asam Fetch")
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
    
    var cleanup: (() -> Void)?
    var operation: AsamDataFetchOperation?

    @discardableResult
    func fetchAsams(task: BGTask? = nil, dateString: String? = nil) async -> [AsamModel] {

        if let task = task {
            registerBackgroundTask(name: task.identifier)
            guard backgroundTask != .invalid else { return [] }
        }
                
        // Create an operation that performs the main part of the background task.
        operation = AsamDataFetchOperation(dateString: dateString)
        
        // Provide the background task with an expiration handler that cancels the operation.
        task?.expirationHandler = {
            self.operation?.cancel()
        }
        
        NSLog("Start the operation to fetch Asams")
        // Start the operation.
        if let operation = operation {
            self.asamBackgroundFetchQueue.addOperation(operation)
        }
        
        return await withCheckedContinuation { continuation in
            // Inform the system that the background task is complete
            // when the operation completes.
            operation?.completionBlock = {
                task?.setTaskCompleted(success: !(self.operation?.isCancelled ?? false))
                NSLog("Asam Remote Data Source asams count \(self.operation?.data.count ?? 0)")
                continuation.resume(returning: self.operation?.data ?? [])
            }
        }
    }
}
