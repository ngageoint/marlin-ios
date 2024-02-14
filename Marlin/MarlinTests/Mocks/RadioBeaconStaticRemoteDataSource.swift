//
//  RadioBeaconStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class RadioBeaconStaticRemoteDataSource: RadioBeaconRemoteDataSource {
    var list: [RadioBeaconModel] = []

    override func fetch(task: BGTask? = nil, noticeYear: String? = nil, noticeWeek: String? = nil) async -> [RadioBeaconModel] {
        list
    }
}
