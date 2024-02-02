//
//  LightRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class LightRemoteDataSource: RemoteDataSource<LightModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.light, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil,
        volume: String,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [LightModel] {
        let operation = LightDataFetchOperation(volume: volume, noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
