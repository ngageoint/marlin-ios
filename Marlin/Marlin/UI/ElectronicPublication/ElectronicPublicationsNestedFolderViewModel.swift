//
//  ElectronicPublicationsNestedFolderViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
class ElectronicPublicationsNestedFolderViewModel: ObservableObject {
    @Published var publications: [ElectronicPublicationModel] = []
    @Published var nestedFolders: [String: [ElectronicPublicationModel]] = [:]

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
                .sorted {
                    if ($0.pubDownloadOrder ?? -1) < ($1.pubDownloadOrder ?? -1) {
                        return ($0.sectionOrder ?? -1) < ($1.sectionOrder ?? -1)
                    }
                    return ($0.pubDownloadOrder ?? -1) < ($1.pubDownloadOrder ?? -1)
                }
            let fetchedNestedFolders = Dictionary(grouping: fetched, by: { $0.pubDownloadDisplayName ?? "" })
            await MainActor.run {
                publications = fetched
                nestedFolders = fetchedNestedFolders
            }
        }
    }
}
