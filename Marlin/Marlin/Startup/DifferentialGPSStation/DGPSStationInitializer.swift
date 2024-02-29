//
//  DGPSStationInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

 class DGPSStationInitializer: Initializer {
    let repository: DGPSStationRepository

    init(repository: DGPSStationRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.dgps)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = DGPSStationInitialDataLoadOperation(
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
