//
//  ElectronicPublicationDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class ElectronicPublicationDataFetchOperation: DataFetchOperation<ElectronicPublicationModel> {

    override func fetchData() async -> [ElectronicPublicationModel] {
        if self.isCancelled || !DataSources.epub.shouldSync() {
            return []
        }

        let request = ElectronicPublicationService.getElectronicPublications
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: ElectronicPublicationPropertyContainer.self, queue: queue) { response in
                    NSLog("Response electronic publications count \(response.value?.publications.count ?? 0)")
                    continuation.resume(returning: response.value?.publications ?? [])
                }
        }
    }
}
