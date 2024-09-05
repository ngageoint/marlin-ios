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
    }

    var repository: PublicationRepository? {
        didSet {
            Task {
                await fetchPublications()
            }
        }
    }

    func fetchPublications() async {
        if let pubTypeId = pubTypeId, let repository = repository {
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
