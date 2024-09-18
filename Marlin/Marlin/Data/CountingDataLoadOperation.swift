//
//  DataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 12/21/23.
//

import Foundation
import BackgroundTasks
import UIKit

enum DataLoadOperationState: String {
    case isReady
    case isExecuting
    case isFinished
}

// actor BackgroundOperationRunner {
//    var operations: [UIBackgroundTaskIdentifier: Operation] = [:]
//    
//    func run(name: String) {
//        var backgroundTask = UIApplication.shared.beginBackgroundTask(withName: name) { @Sendable [weak self] in
//        operations.append(operation)
//        operation.start()
//    }
// }

// @MainActor
class CountingDataLoadOperation: Operation, @unchecked Sendable {
    var count: Int = 0

    var state: DataLoadOperationState = .isReady {
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
            await self.startLoad()
            await loadData()
            await self.finishLoad()
        }
    }

    @MainActor
    func finishLoad() {
        self.state = .isFinished
    }

    func loadData() async {
        fatalError("Load data should be implemented in sub class")
    }

    @MainActor
    func startLoad() { }
}
