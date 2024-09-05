//
//  RadioBeaconDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class RadioBeaconDataFetchOperation: DataFetchOperation<RadioBeaconModel> {

    var radioBeacons: [RadioBeaconModel] = []
    var noticeYear: String?
    var noticeWeek: String?

    init(noticeYear: String? = nil, noticeWeek: String? = nil) {
        self.noticeYear = noticeYear
        self.noticeWeek = noticeWeek
    }

    override func fetchData() async -> [RadioBeaconModel] {
        if self.isCancelled || !DataSources.radioBeacon.shouldSync() {
            return []
        }

        let request = RadioBeaconService.getRadioBeacons(noticeYear: noticeYear, noticeWeek: noticeWeek)
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: RadioBeaconPropertyContainer.self, queue: queue) { response in
                    NSLog("Response radio beacon count \(response.value?.ngalol.count ?? 0)")
                    continuation.resume(returning: response.value?.ngalol ?? [])
                }
        }
    }
}
