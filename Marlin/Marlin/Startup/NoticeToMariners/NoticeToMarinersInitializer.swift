//
//  NoticeToMarinersInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import BackgroundTasks

class NoticeToMarinersInitializer: Initializer {

    let repository: NoticeToMarinersRepository

    init(repository: NoticeToMarinersRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.noticeToMariners)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }

    override func fetch() {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = NoticeToMarinersInitialDataLoadOperation(
                localDataSource: self.repository.localDataSource
            )
            initialDataLoadOperation.completionBlock = {
                Task {
                    await self.repository.fetchNoticeToMariners()
                }
            }

            backgroundFetchQueue.addOperation(initialDataLoadOperation)
        } else {
            Task {
                await self.repository.fetchNoticeToMariners()
            }
        }
    }
}
