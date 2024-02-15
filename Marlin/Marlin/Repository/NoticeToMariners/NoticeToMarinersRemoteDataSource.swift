//
//  NoticeToMarinersRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class NoticeToMarinersRemoteDataSource: RemoteDataSource<NoticeToMarinersModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.noticeToMariners, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil,
        noticeNumber: Int? = nil
    ) async -> [NoticeToMarinersModel] {
        let operation = NoticeToMarinersDataFetchOperation(noticeNumber: noticeNumber)
        return await fetch(task: task, operation: operation)
    }
}
