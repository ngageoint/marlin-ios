//
//  NavigationalWarningInitializer.swift
//  Marlin
//
//  Created by Daniel Barela on 2/15/24.
//

import Foundation

class NavigationalWarningInitializer: Initializer {
    let repository: NavigationalWarningRepository

    init(repository: NavigationalWarningRepository) {
        self.repository = repository
        super.init(dataSource: DataSources.navWarning)
    }

    override func createOperation() -> Operation {
        repository.createOperation()
    }
}
