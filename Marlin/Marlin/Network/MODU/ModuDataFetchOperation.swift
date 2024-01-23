//
//  ModuDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/22/24.
//

import Foundation

enum ModuDataFetchOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

class ModuDataFetchOperation: Operation {

    var modus: [ModuModel] = []
    var dateString: String?

    init(dateString: String? = nil) {
        self.dateString = dateString
    }

    var state: ModuDataFetchOperationState = .isReady {
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
            let modus = await fetchData()
            await self.finishFetch(modus: modus)
        }
    }

    @MainActor func finishFetch(modus: [ModuModel]) {
        self.modus = modus
        NSLog("Finished fetch with \(modus.count) modus")
        self.state = .isFinished
    }

    func fetchData() async -> [ModuModel] {
        if self.isCancelled || !Modu.shouldSync() {
            return []
        }

        let request = ModuService.getModus(date: dateString)
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: ModuPropertyContainer.self, queue: queue) { response in
                    NSLog("Response asam count \(response.value?.modu.count ?? 0)")
                    continuation.resume(returning: response.value?.modu ?? [])
                }
        }
    }
}
