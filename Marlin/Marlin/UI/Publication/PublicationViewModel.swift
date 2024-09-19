//
//  PublicationViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/16/24.
//

import Foundation
import Combine

@MainActor
class PublicationViewModel: ObservableObject {
    @Injected(\.publicationRepository)
    var repository: PublicationRepository
    var s3Key: String?
    var disposables = Set<AnyCancellable>()
    @Published var publication: PublicationModel?
    
    @Published var fileExists: Bool = false

    func setupModel(s3Key: String) async {
        self.s3Key = s3Key
        publication = await repository.getPublication(s3Key: s3Key)
        await repository.observePublication(s3Key: s3Key)?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { updatedObject in
                self.publication = updatedObject
            })
            .store(in: &disposables)
    }
    
    func checkFileExists() async -> Bool {
        guard let s3Key = s3Key else {
            return false
        }
        if publication?.isDownloaded ?? false {
            fileExists = await repository.checkFileExists(id: s3Key)
        } else {
            fileExists = false
        }
        return fileExists
    }

    func deleteFile() async {
        guard let s3Key = s3Key else {
            return
        }
        await repository.deleteFile(id: s3Key)
    }

    func downloadFile() {
        Task {
            guard let s3Key = s3Key else {
                return
            }
            await repository.downloadFile(id: s3Key)
        }
    }

    func cancelDownload() {
        Task {
            guard let s3Key = s3Key else {
                return
            }
            await repository.cancelDownload(s3Key: s3Key)
        }
    }
}
