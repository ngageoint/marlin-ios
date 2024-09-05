//
//  ModuInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import BackgroundTasks

class ModuInitializer: Initializer {

    let repository: ModuRepository

    init(repository: ModuRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.modu)
    }

    override func createOperation() -> Operation {
        ModuDataFetchOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = ModuInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchModus()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchModus()
            }
        }
    }
}
