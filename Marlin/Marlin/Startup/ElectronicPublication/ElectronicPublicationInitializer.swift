//
//  ElectronicPublicationInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import BackgroundTasks

class ElectronicPublicationInitializer: Initializer {

    let repository: ElectronicPublicationRepository

    init(repository: ElectronicPublicationRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.epub)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = ElectronicPublicationInitialDataLoadOperation(
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
