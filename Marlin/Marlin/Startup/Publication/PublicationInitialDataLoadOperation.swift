//
//  PublicationInitialDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation

class PublicationInitialDataLoadOperation: CountingDataLoadOperation {
    @Injected(\.publicationLocalDataSource)
    var localDataSource: PublicationLocalDataSource
    var bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    @MainActor override func startLoad() {
        MSI.shared.appState.loadingDataSource[DataSources.epub.key] = true

        NotificationCenter.default.post(name: .DataSourceLoading, object: DataSourceItem(dataSource: DataSources.epub))
    }

    @MainActor override func finishLoad() {
        self.state = .isFinished
        MSI.shared.appState.loadingDataSource[DataSources.epub.key] = false
        NotificationCenter.default.post(
            name: .DataSourceLoaded,
            object: DataSourceItem(dataSource: DataSources.epub)
        )
        NotificationCenter.default.post(
            name: .DataSourceUpdated,
            object: DataSourceUpdatedNotification(key: DataSources.epub.key)
        )
    }

    override func loadData() async {
        NSLog("Electronic Publication Initial Data Load")
        if self.isCancelled {
            return
        }
        if let url = bundle.url(forResource: "epub", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let propertyContainer = try decoder.decode(PublicationPropertyContainer.self, from: data)
                count = await localDataSource.insert(task: nil, epubs: propertyContainer.publications)
            } catch {
                print("error:\(error)")
            }
        }

    }
}
