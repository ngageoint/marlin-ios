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

    override func createOperation() -> Operation {
        PortDataFetchOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = PortInitialDataLoadOperation()
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchPorts()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchPorts()
            }
        }
    }
}
