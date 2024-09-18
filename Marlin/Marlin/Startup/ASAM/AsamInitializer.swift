//
//  AsamInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 11/8/23.
//

import Foundation
import BackgroundTasks

class AsamInitializer: Initializer {
    @Injected(\.asamRepository)
    var repository: AsamRepository
    
    init() {
        super.init(dataSource: DataSources.asam)
    }
    
    override func createOperation() async -> Operation {
        await repository.createOperation()
    }

    override func fetch() async {
        if await repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = AsamInitialDataLoadOperation()
            initialDataLoadOperation.completionBlock = {
                Task { [weak self] in
                    _ = await self?.repository.fetchAsams()
                }
            }
            
            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            _ = await self.repository.fetchAsams()
        }
    }
}
