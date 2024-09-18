//
//  AsamDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/7/23.
//

import Foundation

class AsamDataFetchOperation: DataFetchOperation<AsamModel>, @unchecked Sendable {

    let dateString: String?
    
    init(dateString: String? = nil) {
        self.dateString = dateString
    }

    override func fetchData() async -> [AsamModel] {
        if self.isCancelled || !DataSources.asam.shouldSync() {
            return []
        }
        
        let request = AsamService.getAsams(date: dateString)
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: AsamPropertyContainer.self, queue: queue) { response in
                    NSLog("Response asam count \(response.value?.asam.count ?? 0)")
                    continuation.resume(returning: response.value?.asam ?? [])
                }
        }
    }
}
