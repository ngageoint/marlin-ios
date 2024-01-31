//
//  PortDataFetchOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 1/30/24.
//

import Foundation

enum PortDataFetchOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

class PortDataFetchOperation: Operation {

    var ports: [PortModel] = []

    var state: PortDataFetchOperationState = .isReady {
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
            await self.finishFetch(ports: ports)
        }
    }

    @MainActor func finishFetch(ports: [PortModel]) {
        self.ports = ports
        NSLog("Finished fetch with \(ports.count) ports")
        self.state = .isFinished
    }

    func fetchData() async -> [PortModel] {
        if self.isCancelled || !DataSources.port.shouldSync() {
            return []
        }

        let request = PortService.getPorts
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        return await withCheckedContinuation { continuation in
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(of: PortPropertyContainer.self, queue: queue) { response in
                    NSLog("Response port count \(response.value?.ports.count ?? 0)")
                    continuation.resume(returning: response.value?.ports ?? [])
                }
        }
    }
}
