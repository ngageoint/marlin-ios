//
//  RadioBeaconRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 2/2/24.
//

import Foundation
import BackgroundTasks

class RadioBeaconRemoteDataSource: RemoteDataSource<RadioBeaconModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.radioBeacon, cleanup: cleanup)
    }

    func fetch(
        task: BGTask? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [RadioBeaconModel] {
        let operation = RadioBeaconDataFetchOperation(noticeYear: noticeYear, noticeWeek: noticeWeek)
        return await fetch(task: task, operation: operation)
    }
}
