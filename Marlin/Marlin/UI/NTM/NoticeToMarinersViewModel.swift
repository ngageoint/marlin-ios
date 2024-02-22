//
//  NoticeToMarinersViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/21/24.
//

import Foundation
import Combine

class NoticeToMarinersViewModel: ObservableObject {
    var repository: NoticeToMarinersRepository?
    var odsEntryId: Int?
    var disposables = Set<AnyCancellable>()
    @Published var noticeToMariners: NoticeToMarinersModel?

    func setupModel(repository: NoticeToMarinersRepository, odsEntryId: Int?) {
        self.repository = repository
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
        guard let repository = repository, let odsEntryId = odsEntryId else {
            return false
        }
        return repository.checkFileExists(odsEntryId: odsEntryId)
    }

    func deleteFile() {
        guard let repository = repository, let odsEntryId = odsEntryId else {
            return
        }
        repository.deleteFile(odsEntryId: odsEntryId)
    }

    func downloadFile() {
        guard let repository = repository, let odsEntryId = odsEntryId else {
            return
        }
        repository.downloadFile(odsEntryId: odsEntryId)
    }

    func cancelDownload() {
        guard let repository = repository, let odsEntryId = odsEntryId else {
            return
        }
        repository.cancelDownload(odsEntryId: odsEntryId)
    }
}
