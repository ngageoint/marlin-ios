//
//  MSI.swift
//  Marlin
//
//  Created by Daniel Barela on 6/3/22.
//

import Foundation
import Alamofire
import OSLog
import CoreData

public class MSI {
    
    let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "persistence")
    
    static let shared = MSI()
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.af.default
    lazy var session: Session = {
        return Session(configuration: configuration)
    }()
    
    private func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = PersistenceController.shared.container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    func loadAsams(date: String? = nil) {
        session.request(MSIRouter.readAsams(date: date))
            .validate()
            .responseDecodable(of: AsamPropertyContainer.self) { response in
                Task {
                    let asamCount = response.value?.asam.count
                    self.logger.debug("Received \(asamCount ?? 0) records.")
                    if let asams = response.value?.asam {
                        try await Asam.batchImport(from: asams, taskContext: self.newTaskContext())
                    }
                }
            }
    }
    
    func loadModus() {
        session.request(MSIRouter.readModus())
            .validate()
            .responseDecodable(of: ModuPropertyContainer.self) { response in
                Task {
                    let moduCount = response.value?.modu.count
                    self.logger.debug("Received \(moduCount ?? 0) records.")
                    if let modus = response.value?.modu {
                        try await Modu.batchImport(from: modus, taskContext: self.newTaskContext())
                    }
                }
            }
    }
}

