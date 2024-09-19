//
//  DGPSStationInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

 class DGPSStationInitializer: Initializer {
    @Injected(\.dgpsRepository)
    var repository: DGPSStationRepository

    init() {
        super.init(dataSource: DataSources.dgps)
    }

    override func createOperation() async -> Operation {
        await repository.createOperation()
    }

    override func fetch() async {
        if await repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = DGPSStationInitialDataLoadOperation()
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetch()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            _ = await self.repository.fetch()
        }
    }
 }
