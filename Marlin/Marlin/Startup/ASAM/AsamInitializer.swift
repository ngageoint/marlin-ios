//
//  AsamInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 11/8/23.
//

import Foundation
import BackgroundTasks

class AsamInitializer {
    
    let repository: AsamRepository
    
    init(repository: AsamRepository) {
        self.repository = repository
    }
    
    lazy var asamBackgroundFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Asam fetch queue"
        return queue
    }()
    
    func registerBackgroundHandler() {
        NSLog("Register ASAM Background Refresh")
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "mil.nga.msi.asam.refresh",
            using: nil
        ) { [weak self] task in
            self?.fetchAsamsPeriodically(task: task)
        }
    }
    
    func fetchAsams() {
        if repository.getCount(filters: nil) == 0 {
            let asamInitialDataLoadOperation = AsamInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            asamInitialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchAsams(refresh: true)
                }
            }
            
            asamBackgroundFetchQueue.addOperation(asamInitialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchAsams(refresh: true)
            }
        }
    }
    
    func fetchAsamsPeriodically(task: BGTask) {
        print("asam background fetch")
        scheduleAsamRefresh()
        
        // Create an operation that performs the main part of the background task.
        let operation = AsamDataFetchOperation()
        
        // Provide the background task with an expiration handler that cancels the operation.
        task.expirationHandler = {
            operation.cancel()
        }
        
        // Inform the system that the background task is complete
        // when the operation completes.
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        // Start the operation.
        self.asamBackgroundFetchQueue.addOperation(operation)
    }
    
    private func scheduleAsamRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "mil.nga.msi.asam.refresh")
        // Fetch no earlier than 1 hour from now
        request.earliestBeginDate = Calendar.current.date(byAdding: .minute, value: 1, to: Date())
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch BGTaskScheduler.Error.notPermitted {
            print("BGTaskScheduler.shared.submit notPermitted")
        } catch BGTaskScheduler.Error.tooManyPendingTaskRequests {
            print("BGTaskScheduler.shared.submit tooManyPendingTaskRequests")
        } catch BGTaskScheduler.Error.unavailable {
            print("BGTaskScheduler.shared.submit unavailable")
        } catch {
            print("BGTaskScheduler.shared.submit \(error.localizedDescription)")
        }
        print("Background task scheduled")
    }
}
