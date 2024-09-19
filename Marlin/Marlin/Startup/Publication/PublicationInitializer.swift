//
//  PublicationInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/8/24.
//

import Foundation
import BackgroundTasks

class PublicationInitializer: Initializer {

    @Injected(\.publicationRepository)
    var repository: PublicationRepository

    init() {
        super.init(dataSource: DataSources.epub)
    }

    override func createOperation() async -> Operation {
        await repository.createOperation()
    }

    override func fetch() async {
        if await repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = PublicationInitialDataLoadOperation()
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
