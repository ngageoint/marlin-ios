//
//  NoticeToMarinersViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/21/24.
//

import Foundation
import Combine

class NoticeToMarinersViewModel: ObservableObject {
    @Injected(\.ntmRepository)
    private var repository: NoticeToMarinersRepository
    var odsEntryId: Int?
    var disposables = Set<AnyCancellable>()
    @Published var noticeToMariners: NoticeToMarinersModel?

    func setupModel(odsEntryId: Int?) {
        self.odsEntryId = odsEntryId
        if let odsEntryId = odsEntryId {
            noticeToMariners = repository.getNoticeToMariners(odsEntryId: odsEntryId)
            repository.observeNoticeToMariners(odsEntryId: odsEntryId)?
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { updatedObject in
                    print("notice was updated with progress \(updatedObject.downloadProgress)")
                    self.noticeToMariners = updatedObject
                })
                .store(in: &disposables)
        }
    }

    func checkFileExists() -> Bool {
        guard let odsEntryId = odsEntryId else {
            return false
        }
        return repository.checkFileExists(odsEntryId: odsEntryId)
    }

    func deleteFile() {
        guard let odsEntryId = odsEntryId else {
            return
        }
        repository.deleteFile(odsEntryId: odsEntryId)
    }

    func downloadFile() {
        guard let odsEntryId = odsEntryId else {
            return
        }
        repository.downloadFile(odsEntryId: odsEntryId)
    }

    func cancelDownload() {
        guard let odsEntryId = odsEntryId else {
            return
        }
        repository.cancelDownload(odsEntryId: odsEntryId)
    }
}
