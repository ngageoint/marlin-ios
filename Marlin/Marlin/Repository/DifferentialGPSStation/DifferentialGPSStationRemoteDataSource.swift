//
//  DifferentialGPSStationRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class DifferentialGPSStationRemoteDataSource: RemoteDataSource<DifferentialGPSStationModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.dgps, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil,
        volume: String? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [DifferentialGPSStationModel] {
        let operation = DifferentialGPSStationFetchOperation(volume: volume, noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
