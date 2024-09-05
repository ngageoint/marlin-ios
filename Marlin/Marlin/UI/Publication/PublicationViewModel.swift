//
//  PublicationViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/16/24.
//

import Foundation
import Combine

class PublicationViewModel: ObservableObject {
    var repository: PublicationRepository?
    var s3Key: String?
    var disposables = Set<AnyCancellable>()
    @Published var publication: PublicationModel?

    func setupModel(repository: PublicationRepository, s3Key: String) {
        self.repository = repository
        self.s3Key = s3Key
        publication = repository.getPublication(s3Key: s3Key)
        repository.observePublication(s3Key: s3Key)?
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { updatedObject in
                self.publication = updatedObject
            })
            .store(in: &disposables)
    }

    func checkFileExists() -> Bool {
        guard let repository = repository, let s3Key = s3Key else {
            return false
        }
        return repository.checkFileExists(id: s3Key)
    }

    func deleteFile() {
        guard let repository = repository, let s3Key = s3Key else {
            return
        }
        repository.deleteFile(id: s3Key)
    }

    func downloadFile() {
        guard let repository = repository, let s3Key = s3Key else {
            return
        }
        repository.downloadFile(id: s3Key)
    }

    func cancelDownload() {
        guard let repository = repository, let s3Key = s3Key else {
            return
        }
        repository.cancelDownload(s3Key: s3Key)
    }
}
