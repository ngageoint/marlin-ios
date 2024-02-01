//
//  NoticeToMarinersDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class NoticeToMarinersDataLoadOperation: CountingDataLoadOperation {

    var notices: [NoticeToMarinersModel] = []
    var localDataSource: NoticeToMarinersLocalDataSource

    init(notices: [NoticeToMarinersModel], localDataSource: NoticeToMarinersLocalDataSource) {
        self.notices = notices
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: notices)) ?? 0
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
