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
        let manager = ServerTrustManager(evaluators: ["msi.gs.mil": DisabledTrustEvaluator()])
        return Session(configuration: configuration, serverTrustManager: manager)
//        return Session(configuration: configuration)
    }()
    
    func loadAsams(date: String? = nil) {
        session.request(MSIRouter.readAsams(date: date))
            .validate()
            .responseDecodable(of: AsamPropertyContainer.self) { response in
                Task {
                    let asamCount = response.value?.asam.count
                    self.logger.debug("Received \(asamCount ?? 0) asam records.")
                    if let asams = response.value?.asam {
                        try await Asam.batchImport(from: asams, taskContext: PersistenceController.shared.newTaskContext())
                    }
                }
            }
    }
    
    func loadModus(date: String? = nil) {
        session.request(MSIRouter.readModus(date: date))
            .validate()
            .responseDecodable(of: ModuPropertyContainer.self) { response in
                Task {
                    let moduCount = response.value?.modu.count
                    self.logger.debug("Received \(moduCount ?? 0) modu records.")
                    if let modus = response.value?.modu {
                        try await Modu.batchImport(from: modus, taskContext: PersistenceController.shared.newTaskContext(), viewContext: PersistenceController.shared.container.viewContext)
                    }
                }
            }
    }
    
    func loadNavigationalWarnings(date: String? = nil) {
        let queue = DispatchQueue(label: "com.test.api", qos: .background)

        session.request(MSIRouter.readNavigationalWarnings)
            .validate()
            .responseDecodable(of: NavigationalWarningPropertyContainer.self, queue: queue) { response in
                queue.async( execute:{
                Task.detached {
                    let navigationalWarningCount = response.value?.broadcastWarn.count
                    self.logger.debug("Received \(navigationalWarningCount ?? 0) navigational warning records.")
                    if let navigationalWarnings = response.value?.broadcastWarn {
                        try await NavigationalWarning.batchImport(from: navigationalWarnings, taskContext: PersistenceController.shared.newTaskContext(), viewContext: PersistenceController.shared.container.viewContext)
                    }
                }
                })
            }
    }
    
    func loadLights(date: String? = nil) {
        let queue = DispatchQueue(label: "com.test.api", qos: .background)
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(Light.self)
        print("There are \(count) lights")
        for lightVolume in Light.lightVolumes {
            let newestLight = try? PersistenceController.shared.container.viewContext.fetchFirst(Light.self, sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)], predicate: NSPredicate(format: "volumeNumber = %@", lightVolume.volumeNumber))
            
            session.request(MSIRouter.readLights(volume: lightVolume.volumeQuery, noticeYear: newestLight?.noticeYear, noticeWeek: newestLight?.noticeWeek))
                .validate()
                .responseDecodable(of: LightsPropertyContainer.self, queue: queue) { response in
                    queue.async(execute:{
                        Task.detached {
                            if let lights = response.value?.ngalol {
                                try await Light.batchImport(from: lights, taskContext: PersistenceController.shared.newTaskContext())
                            }
                        }
                    })
                }
        }
    }
}

