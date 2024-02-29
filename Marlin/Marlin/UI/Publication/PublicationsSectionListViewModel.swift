//
//  PublicationsListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation

class PublicationsSectionListViewModel: ObservableObject {
    @Published var sections: [PublicationItem] = []

    var repository: PublicationRepository? {
        didSet {
            Task {
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
