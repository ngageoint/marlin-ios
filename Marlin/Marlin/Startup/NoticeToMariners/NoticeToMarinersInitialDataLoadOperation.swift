//
//  NoticeToMarinersInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

class NoticeToMarinersInitialDataLoadOperation: CountingDataLoadOperation {
    var localDataSource: NoticeToMarinersLocalDataSource
    var bundle: Bundle

    init(localDataSource: NoticeToMarinersLocalDataSource, bundle: Bundle = .main) {
        self.localDataSource = localDataSource
        self.bundle = bundle
    }

    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.noticeToMariners))
    }

    @MainActor override func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.noticeToMariners.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.noticeToMariners)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.noticeToMariners.key)
        )
    }

    override func loadData() async {
        NSLog("Notice To Mariners Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "ntm", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let propertyContainer = try decoder.decode(NoticeToMarinersPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, noticeToMariners: propertyContainer.pubs)
            } catch {
                print("error:\(error)")
            }
        }

    }
}
