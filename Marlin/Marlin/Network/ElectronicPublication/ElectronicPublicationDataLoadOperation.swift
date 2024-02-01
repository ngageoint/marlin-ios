//
//  ElectronicPublicationDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData

class ElectronicPublicationDataLoadOperation: CountingDataLoadOperation {

    var epubs: [ElectronicPublicationModel] = []
    var localDataSource: ElectronicPublicationLocalDataSource

    init(epubs: [ElectronicPublicationModel], localDataSource: ElectronicPublicationLocalDataSource) {
        self.epubs = epubs
        self.localDataSource = localDataSource
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: epubs)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceNeedsProcessed,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.dgps.key)
                )
            }
        }
    }
}
