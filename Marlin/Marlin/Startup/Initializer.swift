//
//  Initializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class Initializer {

    var dataSource: any DataSourceDefinition

    init(dataSource: any DataSourceDefinition) {
        self.dataSource = dataSource
    }

    func createOperation() -> Operation {
        fatalError("must be overridden")
    }

    func fetch() {
        fatalError("must be overridden")
    }

    lazy var taskId: String = {
        "mil.nga.msi.\(dataSource.key).refresh"
    }()

    lazy var backgroundFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "\(dataSource.name) fetch queue"
        return queue
    }()

    func registerBackgroundHandler() {
        NSLog("Register \(dataSource.name) Background Refresh")
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskId,
            using: nil
        ) { [weak self] task in
            self?.fetchPeriodically(task: task)
        }
    }

    func fetchPeriodically(task: BGTask) {
        print("\(dataSource.name) background fetch")
        scheduleRefresh()

        // Create an operation that performs the main part of the background task.
        let operation = createOperation()

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
        self.backgroundFetchQueue.addOperation(operation)
    }

    func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskId)
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
