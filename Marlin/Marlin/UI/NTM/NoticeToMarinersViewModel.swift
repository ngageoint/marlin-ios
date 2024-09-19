//
//  NoticeToMarinersViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/21/24.
//

import Foundation
import Combine

@MainActor
class NoticeToMarinersViewModel: ObservableObject {
    @Injected(\.ntmRepository)
    private var repository: NoticeToMarinersRepository
    var odsEntryId: Int?
    var disposables = Set<AnyCancellable>()
    @Published var noticeToMariners: NoticeToMarinersModel?
    
    @Published var fileExists: Bool = false

    func setupModel(odsEntryId: Int?) async {
        self.odsEntryId = odsEntryId
        if let odsEntryId = odsEntryId {
            noticeToMariners = await repository.getNoticeToMariners(odsEntryId: odsEntryId)
            await repository.observeNoticeToMariners(odsEntryId: odsEntryId)?
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { updatedObject in
                    print("notice was updated with progress \(updatedObject.downloadProgress)")
                    self.noticeToMariners = updatedObject
                    Task { [weak self] in
                        await self?.checkFileExists()
                    }
                })
                .store(in: &disposables)
        }
    }

    func checkFileExists() async -> Bool {
        guard let odsEntryId = odsEntryId else {
            return false
        }
        if noticeToMariners?.isDownloaded ?? false {
            fileExists = await repository.checkFileExists(odsEntryId: odsEntryId)
        } else {
            fileExists = false
        }
        return fileExists
    }

    func deleteFile() async {
        guard let odsEntryId = odsEntryId else {
            return
        }
        await repository.deleteFile(odsEntryId: odsEntryId)
    }

    func downloadFile() async {
        guard let odsEntryId = odsEntryId else {
            return
        }
        await repository.downloadFile(odsEntryId: odsEntryId)
    }

    func cancelDownload() async {
        guard let odsEntryId = odsEntryId else {
            return
        }
        await repository.cancelDownload(odsEntryId: odsEntryId)
    }
}
