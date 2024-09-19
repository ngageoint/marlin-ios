//
//  NavigationalWarningInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation

class NavigationalWarningInitializer: Initializer {
    @Injected(\.navWarningRepository)
    var repository: NavigationalWarningRepository

    init() {
        super.init(dataSource: DataSources.navWarning)
    }

    override func createOperation() async -> Operation {
        await repository.createOperation()
    }

    override func fetch() async {
        _ = await self.repository.fetch()
    }
}
