//
//  AsamStaticRemoteDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/12/24.
//

import Foundation
import BackgroundTasks

@testable import Marlin

class AsamStaticRemoteDataSource: AsamRemoteDataSource {
    var asamList: [AsamModel] = []

    override func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [AsamModel] {
        NSLog("Returning \(asamList.count) asams")
        return asamList
    }
}
