//
//  NoticeToMarinersInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation
import BackgroundTasks

class NoticeToMarinersInitializer: Initializer {
    @Injected(\.ntmRepository)
    private var repository: NoticeToMarinersRepository

    init() {
        super.init(dataSource: DataSources.noticeToMariners)
    }

    override func createOperation() async -> Operation {
        repository.createOperation()
    }

    override func fetch() async {
        if repository.getCount(filters: nil) == 0 {
            let initialDataLoadOperation = NoticeToMarinersInitialDataLoadOperation()
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
