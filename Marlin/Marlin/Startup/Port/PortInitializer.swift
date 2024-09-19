//
//  PortInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation
import BackgroundTasks

class PortInitializer: Initializer {

    @Injected(\.portRepository)
    private var repository: PortRepository

    init() {
        super.init(dataSource: DataSources.port)
    }

    override func createOperation() async -> Operation {
        PortDataFetchOperation()
    }

    override func fetch() async {
        if await repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = PortInitialDataLoadOperation()
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchPorts()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            _ = await self.repository.fetchPorts()
        }
    }
}
