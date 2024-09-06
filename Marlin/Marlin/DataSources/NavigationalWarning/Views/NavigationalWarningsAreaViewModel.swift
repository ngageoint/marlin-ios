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

    @Injected(\.navWarningRepository)
    var repository: NavigationalWarningRepository

    func getNavigationalWarnings(navArea: String) {
        Task {
            let loaded = await self.repository.getNavAreaNavigationalWarnings(navArea: navArea)
            print("loaded \(loaded)")
            await MainActor.run {
                warnings = loaded
            }
        }
    }
}
