//
//  ElectronicPublicationsChaptersListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
class ElectronicPublicationsChaptersListViewModel: ObservableObject {
    @Published var publications: [ElectronicPublicationModel] = []
    @Published var completeVolumes: [ElectronicPublicationModel] = []
    @Published var chapters: [ElectronicPublicationModel] = []

    var pubTypeId: Int? {
        didSet {
            Task {
                await fetchPublications()
            }
        }
    }

    init(pubTypeId: Int? = nil) {
        self.pubTypeId = pubTypeId
    }

    var repository: ElectronicPublicationRepository? {
        didSet {
            Task {
                await fetchPublications()
            }
        }
    }

    func fetchPublications() async {
        if let pubTypeId = pubTypeId, let repository = repository {
            let fetched = await repository.getPublications(typeId: pubTypeId)
            let grouped = Dictionary(grouping: fetched, by: { $0.fullPubFlag })
            let fetchedCompleteVolumes = grouped[true]?.sorted {
                ($0.pubDownloadOrder ?? -1) < ($1.pubDownloadOrder ?? -1)
            } ?? []

            let fetchedChapters = grouped[false]?.sorted {
                if $0.sectionOrder == $1.sectionOrder {
                    return ($0.pubDownloadOrder ?? -1) < ($1.pubDownloadOrder ?? -1)
                }
                return ($0.sectionOrder ?? -1) < ($1.sectionOrder ?? -1)
            } ?? []

            await MainActor.run {
                publications = fetched
                completeVolumes = fetchedCompleteVolumes
                chapters = fetchedChapters
            }
        }
    }
}
