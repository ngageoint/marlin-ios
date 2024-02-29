//
//  PublicationInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import BackgroundTasks

class PublicationInitializer: Initializer {

    let repository: PublicationRepository

    init(repository: PublicationRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.epub)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = PublicationInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetch()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetch()
            }
        }
    }
}
