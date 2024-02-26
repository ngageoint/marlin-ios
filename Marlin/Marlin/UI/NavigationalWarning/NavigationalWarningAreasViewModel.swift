//
//  NavigationalWarningAreasViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/25/24.
//

import Foundation

class NavigationalWarningAreasViewModel: ObservableObject {
    @Published var warningAreas: [NavigationalAreaInformation] = []
    @Published var currentArea: NavigationalAreaInformation?

    var currentNavAreaName: String? {
        didSet {
            Task {
                await populateWarningAreaInformation()
            }
        }
    }

    var repository: NavigationalWarningRepository? {
        didSet {
            Task {
                await populateWarningAreaInformation()
            }
        }
    }

    func populateWarningAreaInformation() async {
        let info = await repository?.getNavAreasInformation()
        await MainActor.run {
            currentArea = info?.first { area in
                area.navArea.name == currentNavAreaName
            }
            warningAreas = info?.filter({ area in
                area.navArea.name != currentNavAreaName
            }) ?? []
        }
    }
}
