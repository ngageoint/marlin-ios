//
//  NoticeToMarinersDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 2/1/24.
//

import Foundation

class NoticeToMarinersDataFetchOperation: DataFetchOperation<NoticeToMarinersModel> {

    var noticeNumber: Int64?

    init(noticeNumber: Int64? = nil) {
        self.noticeNumber = noticeNumber
    }

    override func fetchData() async -> [NoticeToMarinersModel] {
        if self.isCancelled || !DataSources.noticeToMariners.shouldSync() {
            return []
        }

        let request = NoticeToMarinersService.getNoticeToMariners(noticeNumber: noticeNumber)
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: NoticeToMarinersPropertyContainer.self, queue: queue) { response in
                    NSLog("Response notice to mariners count \(response.value?.pubs.count ?? 0)")
                    continuation.resume(returning: response.value?.pubs ?? [])
                }
        }
    }
}
