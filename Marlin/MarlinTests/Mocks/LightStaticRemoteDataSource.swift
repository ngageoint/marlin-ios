//
//  LightStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/13/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class LightStaticRemoteDataSource: LightRemoteDataSource {
    var list: [String: [LightModel]] = [:]

    override func fetch(task: BGTask? = nil, volume: String, noticeYear: String? = nil, noticeWeek: String? = nil) async -> [LightModel] {
        NSLog("Returning \(list[volume]?.count) lights")
        return list[volume] ?? []
    }
}
