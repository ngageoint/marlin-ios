//
//  PublicationsChaptersListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
class PublicationsChaptersListViewModel: ObservableObject {
    @Published var publications: [PublicationModel] = []
    @Published var completeVolumes: [PublicationModel] = []
    @Published var chapters: [PublicationModel] = []

    var pubTypeId: Int? {
        didSet {
            Task {
                await fetchPublications()
            }
        }
    }

    init(pubTypeId: Int? = nil) {
        self.pubTypeId = pubTypeId
        Task {
            await fetchPublications()
        }
    }

    @Injected(\.publicationRepository)
    var repository: PublicationRepository

    func fetchPublications() async {
        if let pubTypeId = pubTypeId {
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
