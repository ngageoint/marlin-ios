//
//  NoticeToMarinersDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import Kingfisher

class NoticeToMarinersDataLoadOperation: CountingDataLoadOperation, @unchecked Sendable {

    let noticeToMariners: [NoticeToMarinersModel]
    
    @Injected(\.ntmLocalDataSource)
    var localDataSource: NoticeToMarinersLocalDataSource

    init(noticeToMariners: [NoticeToMarinersModel]) {
        self.noticeToMariners = noticeToMariners
    }

    @MainActor
    override func finishLoad() {
        Kingfisher.ImageCache(name: DataSources.noticeToMariners.key).clearCache()
        self.state = .isFinished

        MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] = false
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.noticeToMariners.key)
                )
            }
        }
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: noticeToMariners)) ?? 0
    }
}
