//
//  PublicationDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class PublicationDataFetchOperation: DataFetchOperation<PublicationModel> {

    override func fetchData() async -> [PublicationModel] {
        if self.isCancelled || !DataSources.epub.shouldSync() {
            return []
        }

        let request = PublicationService.getPublications
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: PublicationPropertyContainer.self, queue: queue) { response in
                    NSLog("Response electronic publications count \(response.value?.publications.count ?? 0)")
                    continuation.resume(returning: response.value?.publications ?? [])
                }
        }
    }
}
