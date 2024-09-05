//
//  DGPSStationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class DGPSStationRemoteDataSource: RemoteDataSource<DGPSStationModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.dgps, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [DGPSStationModel] {
        let operation = DGPSStationDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
