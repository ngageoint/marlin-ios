//
//  DifferentialGPSStationDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class DifferentialGPSStationDataFetchOperation: DataFetchOperation<DifferentialGPSStationModel> {

    var noticeYear: String?
    var noticeWeek: String?

    init(noticeYear: String? = nil, noticeWeek: String? = nil) {
        self.noticeYear = noticeYear
        self.noticeWeek = noticeWeek
    }

    override func fetchData() async -> [DifferentialGPSStationModel] {
        if self.isCancelled || !DataSources.dgps.shouldSync() {
            return []
        }

        let request = DifferentialGPSStationService.getDifferentialGPSStations(
            noticeYear: noticeYear,
            noticeWeek: noticeWeek
        )
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: DifferentialGPSStationPropertyContainer.self, queue: queue) { response in
                    NSLog("Response differential GPS station count \(response.value?.ngalol.count ?? 0)")
                    continuation.resume(returning: response.value?.ngalol ?? [])
                }
        }
    }
}
