//
//  DifferentialGPSStationStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class DifferentialGPSStationStaticRemoteDataSource: DifferentialGPSStationRemoteDataSource {
    var list: [DifferentialGPSStationModel] = []

    override func fetch(
        task: BGTask? = nil,
        noticeYear: String? = nil,
        noticeWeek: String? = nil
    ) async -> [DifferentialGPSStationModel] {
        NSLog("Returning \(list.count) dgps")
        return list
    }
}
