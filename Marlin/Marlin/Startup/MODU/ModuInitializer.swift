//
//  ModuInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import BackgroundTasks

class ModuInitializer {

    let repository: ModuRepository

    init(repository: ModuRepository) {
        self.repository = repository
    }

    lazy var backgroundFetchQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = "Modu fetch queue"
        return queue
    }()

    func registerBackgroundHandler() {
        NSLog("Register MODU Background Refresh")
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "mil.nga.msi.modu.refresh",
            using: nil
        ) { [weak self] task in
            self?.fetchModusPeriodically(task: task)
        }
    }

    func fetchModus() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = ModuInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchModus(refresh: true)
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchModus(refresh: true)
            }
        }
    }

    func fetchModusPeriodically(task: BGTask) {
        print("Modu background fetch")
        scheduleModuRefresh()

        // Create an operation that performs the main part of the background task.
        let operation = ModuDataFetchOperation()

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

    private func scheduleModuRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "mil.nga.msi.modu.refresh")
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
