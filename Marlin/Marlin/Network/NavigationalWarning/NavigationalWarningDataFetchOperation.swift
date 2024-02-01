//
//  NavigationalWarningDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class NavigationalWarningDataFetchOperation: DataFetchOperation<ModuModel> {

    var dateString: String?

    init(dateString: String? = nil) {
        self.dateString = dateString
    }

    override func fetchData() async -> [ModuModel] {
        if self.isCancelled || !DataSources.modu.shouldSync() {
            return []
        }

        let request = ModuService.getModus(date: dateString)
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: ModuPropertyContainer.self, queue: queue) { response in
                    NSLog("Response asam count \(response.value?.modu.count ?? 0)")
                    continuation.resume(returning: response.value?.modu ?? [])
                }
        }
    }
}
