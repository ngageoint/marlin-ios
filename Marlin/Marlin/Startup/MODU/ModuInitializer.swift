//
//  ModuInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import BackgroundTasks

class ModuInitializer: Initializer {
    @Injected(\.moduRepository)
    var repository: ModuRepository
    
    init() {
        super.init(dataSource: DataSources.modu)
    }

    override func createOperation() async -> Operation {
        ModuDataFetchOperation()
    }

    override func fetch() async {
        if await repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = ModuInitialDataLoadOperation()
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchModus()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            _ = await self.repository.fetchModus()
        }
    }
}
