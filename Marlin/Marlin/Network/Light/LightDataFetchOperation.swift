//
//  LightDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class LightDataFetchOperation: DataFetchOperation<LightModel> {

    var volume: String
    var noticeYear: String?
    var noticeWeek: String?

    init(volume: String, noticeYear: String? = nil, noticeWeek: String? = nil) {
        self.volume = volume
        self.noticeYear = noticeYear
        self.noticeWeek = noticeWeek
    }

    override func fetchData() async -> [LightModel] {
        if self.isCancelled || !DataSources.light.shouldSync() {
            return []
        }

        let request = LightService.getLights(
            volume: volume,
            noticeYear: noticeYear,
            noticeWeek: noticeWeek
        )
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: LightsPropertyContainer.self, queue: queue) { response in
                    NSLog("Response light station count \(response.value?.ngalol.count ?? 0)")
                    continuation.resume(returning: response.value?.ngalol ?? [])
                }
        }
    }
}
