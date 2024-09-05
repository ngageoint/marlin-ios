//
//  AsamInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 11/8/23.
//

import Foundation
import BackgroundTasks

class AsamInitializer: Initializer {

    let repository: AsamRepository
    
    init(repository: AsamRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.asam)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = AsamInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchAsams()
                }
            }
            
            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchAsams()
            }
        }
    }
}
