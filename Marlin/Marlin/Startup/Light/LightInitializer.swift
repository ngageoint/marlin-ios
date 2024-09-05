//
//  LightInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class LightInitializer: Initializer {

    let repository: LightRepository

    init(repository: LightRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.light)
    }

    override func fetchPeriodically(task: BGTask) {
        print("\(dataSource.name) background fetch")
        scheduleRefresh()

        let operations = repository.createOperations()

        for operation in operations {
            // Inform the system that the background task is complete
            // when the operation completes.
            operation.completionBlock = {
                task.setTaskCompleted(success: !operation.isCancelled)
            }

            // Start the operation.
            self.backgroundFetchQueue.addOperation(operation)
        }
        
        // Provide the background task with an expiration handler that cancels the operation.
        task.expirationHandler = {
            for operation in operations {
                operation.cancel()
            }
        }
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = LightInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchLights()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchLights()
            }
        }
    }
}
