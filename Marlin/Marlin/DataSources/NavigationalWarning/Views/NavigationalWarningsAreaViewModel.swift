//
//  NavigationalWarningsAreaDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 6/24/22.
//

import Foundation
import Combine

class NavigationalWarningsAreaViewModel: ObservableObject {
    @Published var warnings: [NavigationalWarningModel] = []
    var navArea: String?

    var repository: NavigationalWarningRepository? {
        didSet {
            if let navArea = navArea {
                getNavigationalWarnings(navArea: navArea)
            }
        }
    }

    func getNavigationalWarnings(navArea: String) {
        Task {
            let loaded = await self.repository?.getNavAreaNavigationalWarnings(navArea: navArea) ?? []
            await MainActor.run {
                warnings = loaded
            }
        }
    }
}
