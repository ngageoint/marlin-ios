//
//  AsamRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 11/1/23.
//

import Foundation
import UIKit
import BackgroundTasks

class AsamRemoteDataSource: RemoteDataSource<AsamModel> {

    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.asam, cleanup: cleanup)
    }

    func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [AsamModel] {
        let operation = AsamDataFetchOperation(dateString: dateString)
        return await fetch(task: task, operation: operation)
    }
}
