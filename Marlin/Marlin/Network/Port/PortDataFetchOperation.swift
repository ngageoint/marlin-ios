//
//  PortDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation

class PortDataFetchOperation: DataFetchOperation<PortModel>, @unchecked Sendable {

    override func fetchData() async -> [PortModel] {
        if self.isCancelled || !DataSources.port.shouldSync() {
            return []
        }

        let request = PortService.getPorts
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: PortPropertyContainer.self, queue: queue) { response in
                    NSLog("Response port count \(response.value?.ports.count ?? 0)")
                    continuation.resume(returning: response.value?.ports ?? [])
                }
        }
    }
}
