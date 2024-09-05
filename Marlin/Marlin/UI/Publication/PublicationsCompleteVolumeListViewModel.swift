//
//  ElectronicPublictionsCompleteVolumeListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
class PublicationsCompleteVolumeListViewModel: ObservableObject {
    @Published var publications: [PublicationModel] = []

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
                .filter({ epub in
                    epub.fullPubFlag == true
                }).sorted {
                    ($0.pubDownloadOrder ?? -1) < ($1.pubDownloadOrder ?? -1)
                }
            await MainActor.run {
                publications = fetched
            }
        }
    }
}
