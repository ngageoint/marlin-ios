//
//  ElectronicPublicationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class ElectronicPublicationRemoteDataSource: RemoteDataSource<ElectronicPublicationModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.epub, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil
    ) async -> [ElectronicPublicationModel] {
        let operation = ElectronicPublicationDataFetchOperation()
        return await fetch(task: task, operation: operation)
    }
}
