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
    var noticeNumber: Int?
    var disposables = Set<AnyCancellable>()
    @Published var noticeToMariners: NoticeToMarinersModel?

    func setupModel(repository: NoticeToMarinersRepository, noticeNumber: Int?) {
        self.repository = repository
        self.noticeNumber = noticeNumber
        if let noticeNumber = noticeNumber {
            noticeToMariners = repository.getNoticeToMariners(noticeNumber: noticeNumber)
            repository.observeNoticeToMariners(noticeNumber: noticeNumber)?
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { updatedObject in
                    print("notice was updated with progress \(updatedObject.downloadProgress)")
                    self.noticeToMariners = updatedObject
                })
                .store(in: &disposables)
        }
    }

    func checkFileExists() -> Bool {
        guard let repository = repository, let noticeNumber = noticeNumber else {
            return false
        }
        return repository.checkFileExists(id: noticeNumber)
    }

    func deleteFile() {
        guard let repository = repository, let noticeNumber = noticeNumber else {
            return
        }
        repository.deleteFile(id: noticeNumber)
    }

    func downloadFile() {
        guard let repository = repository, let noticeNumber = noticeNumber else {
            return
        }
        repository.downloadFile(id: noticeNumber)
    }

    func cancelDownload() {
        guard let repository = repository, let noticeNumber = noticeNumber else {
            return
        }
        repository.cancelDownload(noticeNumber: noticeNumber)
    }
}
