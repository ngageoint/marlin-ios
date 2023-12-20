//
//  ImageLoader.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import Foundation
import Combine
import UIKit

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private(set) var isLoading = false
    
    private let url: URL
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading else { return }
        
        if let image = cache?[url] {
            self.image = image
            return
        }
        
        cancellable = MSI.shared.session.request(url,
                   method: .get)
        .onURLRequestCreation(perform: { _ in
            self.onStart()
        })
        .validate()
        .publishData()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { response in
            self.onFinish()
            if let data = response.data {
                self.image = UIImage(data: data)
                self.cache(self.image)
            }
        })
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
}
