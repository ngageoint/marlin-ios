//
//  NavigationalWarningAreasViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/25/24.
//

import Foundation
import Combine

class NavigationalWarningAreasViewModel: ObservableObject {
    @Published var warningAreas: [NavigationalAreaInformation] = []
    @Published var currentArea: NavigationalAreaInformation?
    private var disposables = Set<AnyCancellable>()

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.light.key
            }
            .sink { _ in
                Task {
                    await self.populateWarningAreaInformation()
                }
            }
    }
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
                dataSourceUpdatedPub.store(in: &disposables)

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
