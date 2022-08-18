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
    
    let persistenceController = PersistenceController.shared

    static let shared = MSI()
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.af.default
    lazy var session: Session = {
        let manager = ServerTrustManager(evaluators: ["msi.gs.mil": DisabledTrustEvaluator()])
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    func loadAllData() {
        if UserDefaults.standard.dataSourceEnabled(Asam.self) {
            loadAsams()
        }
        if UserDefaults.standard.dataSourceEnabled(Modu.self) {
            loadModus()
        }
        if UserDefaults.standard.dataSourceEnabled(NavigationalWarning.self) {
            loadNavigationalWarnings()
        }
        if UserDefaults.standard.dataSourceEnabled(Light.self) {
            loadLights()
        }
        if UserDefaults.standard.dataSourceEnabled(Port.self) {
            loadPorts(resetData: false)
        }
    }
    
    func loadAsams() {
        let newestAsam = try? persistenceController.container.viewContext.fetchFirst(Asam.self, sortBy: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)])
        session.request(MSIRouter.readAsams(date: newestAsam?.dateString))
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
    
    func loadModus() {
        let newestModu = try? persistenceController.container.viewContext.fetchFirst(Modu.self, sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)])
        
        session.request(MSIRouter.readModus(date: newestModu?.dateString))
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
                        try await NavigationalWarning.batchImport(from: navigationalWarnings, taskContext: PersistenceController.shared.newTaskContext())
                    }
                }
                })
            }
    }
    
    func loadLights(date: String? = nil) {
        let queue = DispatchQueue(label: "com.test.api", qos: .background)
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(Light.self)
        print("There are \(count ?? 0) lights")
        for lightVolume in Light.lightVolumes {
            let newestLight = try? PersistenceController.shared.container.viewContext.fetchFirst(Light.self, sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)], predicate: NSPredicate(format: "volumeNumber = %@", lightVolume.volumeNumber))
            
            let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0
            
            session.request(MSIRouter.readLights(volume: lightVolume.volumeQuery, noticeYear: newestLight?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
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
    
    func loadPorts(resetData: Bool = false) {
        let portCount = try? persistenceController.container.viewContext.countOfObjects(Port.self)
        if portCount != 0 && !resetData {
            return
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        session.request(MSIRouter.readPorts)
            .validate()
            .responseDecodable(of: PortPropertyContainer.self, queue: queue) { response in
                queue.async( execute:{
                    Task.detached {
                        let portCount = response.value?.ports.count
                        self.logger.debug("Received \(portCount ?? 0) port records.")
                        if let ports = response.value?.ports {
                            try await Port.batchImport(from: ports, taskContext: PersistenceController.shared.newTaskContext())
                        }
                    }
                })
            }
    }
}

