//
//  NoticeToMarinersDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class NoticeToMarinersDataLoadOperation: CountingDataLoadOperation {

    var noticeToMariners: [NoticeToMarinersModel] = []
    var localDataSource: NoticeToMarinersLocalDataSource

    init(noticeToMariners: [NoticeToMarinersModel], localDataSource: NoticeToMarinersLocalDataSource) {
        self.noticeToMariners = noticeToMariners
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: noticeToMariners)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.noticeToMariners.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.noticeToMariners.key)
                )
            }
        }
    }
}
