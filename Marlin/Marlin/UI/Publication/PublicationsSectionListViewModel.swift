//
//  PublicationsListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation
import Combine

class PublicationsSectionListViewModel: ObservableObject {
    @Published var sections: [PublicationItem] = []

    private var disposables = Set<AnyCancellable>()

    var dataSourceUpdatedPub: AnyCancellable {
        return NotificationCenter.default.publisher(for: .DataSourceUpdated)
            .compactMap { notification in
                notification.object as? DataSourceUpdatedNotification
            }
            .filter { notification in
                notification.key == DataSources.epub.key
            }
            .sink { _ in
                Task {
                    await self.fetchSections()
                }
            }
    }

    var repository: PublicationRepository? {
        didSet {
            Task {
                dataSourceUpdatedPub.store(in: &disposables)
                await fetchSections()
            }
        }
    }

    func fetchSections() async {
        let fetched = await repository?.getSections() ?? []
        await MainActor.run {
            sections = fetched
        }
    }
}
