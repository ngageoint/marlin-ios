//
//  PublicationDataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation
import CoreData

class PublicationDataLoadOperation: CountingDataLoadOperation {

    var epubs: [PublicationModel] = []
    @Injected(\.publicationLocalDataSource)
    var localDataSource: PublicationLocalDataSource

    init(epubs: [PublicationModel]) {
        self.epubs = epubs
    }

    override func loadData() async {
        if self.isCancelled {
            return
        }

        count = (try? await localDataSource.batchImport(from: epubs)) ?? 0
        if count != 0 {
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .DataSourceUpdated,
                    object: DataSourceUpdatedNotification(key: DataSources.epub.key)
                )
            }
        }
    }
}
