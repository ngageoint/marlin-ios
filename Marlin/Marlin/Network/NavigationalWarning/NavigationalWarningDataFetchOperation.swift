//
//  NavigationalWarningDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class NavigationalWarningDataFetchOperation: DataFetchOperation<NavigationalWarningModel> {

    var dateString: String?

    init(dateString: String? = nil) {
        self.dateString = dateString
    }

    override func fetchData() async -> [NavigationalWarningModel] {
        if self.isCancelled || !DataSources.navWarning.shouldSync() {
            return []
        }

        let request = NavigationalWarningService.getNavigationalWarnings
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: NavigationalWarningPropertyContainer.self, queue: queue) { response in
                    NSLog("Response nav warning count \(response.value?.broadcastWarn.count ?? 0)")
                    continuation.resume(returning: response.value?.broadcastWarn ?? [])
                }
        }
    }
}
