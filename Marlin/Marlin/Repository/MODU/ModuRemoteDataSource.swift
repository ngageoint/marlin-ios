//
//  ModuRemoteDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation
import UIKit
import BackgroundTasks

class ModuRemoteDataSource: RemoteDataSource<ModuModel> {
    init(cleanup: (() -> Void)? = nil) {
        super.init(dataSource: DataSources.modu, cleanup: cleanup)
    }

    func fetch(task: BGTask? = nil, dateString: String? = nil) async -> [ModuModel] {
        let operation = ModuDataFetchOperation(dateString: dateString)
        return await fetch(task: task, operation: operation)
    }
}
