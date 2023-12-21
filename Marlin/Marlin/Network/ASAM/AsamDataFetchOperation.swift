//
//  AsamDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 11/7/23.
//

import Foundation

enum AsamDataFetchOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

class AsamDataFetchOperation: Operation {
    
    var asams: [AsamModel] = []
    var dateString: String?
    
    init(dateString: String? = nil) {
        self.dateString = dateString
    }
    
    var state: AsamDataFetchOperationState = .isReady {
        willSet(newValue) {
            willChangeValue(forKey: state.rawValue)
            willChangeValue(forKey: newValue.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    override var isExecuting: Bool { state == .isExecuting }
    override var isFinished: Bool {
        if isCancelled && state != .isExecuting { return true }
        return state == .isFinished
    }
    override var isAsynchronous: Bool { true }
    
    override func start() {
        guard !isCancelled else { return }
        state = .isExecuting
        Task {
            let asams = await fetchData()
            await self.finishFetch(asams: asams)
        }
    }
    
    @MainActor func finishFetch(asams: [AsamModel]) {
        self.asams = asams
        NSLog("Finished fetch with \(asams.count) asams")
        self.state = .isFinished
    }
    
    func fetchData() async -> [AsamModel] {
        if self.isCancelled || !Asam.shouldSync() {
            return []
        }
        
        let request = AsamService.getAsams(date: dateString)
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: AsamPropertyContainer.self, queue: queue) { response in
                    NSLog("Response asam count \(response.value?.asam.count ?? 0)")
                    continuation.resume(returning: response.value?.asam ?? [])
                }
        }
    }
}
