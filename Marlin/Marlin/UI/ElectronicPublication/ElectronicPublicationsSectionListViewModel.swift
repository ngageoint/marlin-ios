//
//  ElectronicPublicationsListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation

class ElectronicPublicationsSectionListViewModel: ObservableObject {
    @Published var sections: [ElectronicPublicationItem] = []

    var repository: ElectronicPublicationRepository? {
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
