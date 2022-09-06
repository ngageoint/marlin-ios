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
        configuration.httpMaximumConnectionsPerHost = 4
        return Session(configuration: configuration, serverTrustManager: manager)
    }()
    
    func loadAllData(appState: AppState) {
        if UserDefaults.standard.dataSourceEnabled(Asam.self) {
            loadAsams(appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(Modu.self) {
            loadModus(appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(NavigationalWarning.self) {
            loadNavigationalWarnings(appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(Light.self) {
            loadLights(appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(Port.self) {
            loadPorts(resetData: false, appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(RadioBeacon.self) {
            loadRadioBeacons(appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(DifferentialGPSStation.self) {
            loadDifferentialGPSStations(appState: appState)
        }
        if UserDefaults.standard.dataSourceEnabled(DFRS.self) {
            loadDFRS(resetData: false, appState: appState)
            loadDFRSAreas(resetData: true, appState: appState)
        }
    }
    
    func loadAsams(appState: AppState) {
        DispatchQueue.main.async {
            appState.loadingDataSource[Asam.key] = true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        let newestAsam = try? persistenceController.container.viewContext.fetchFirst(Asam.self, sortBy: [NSSortDescriptor(keyPath: \Asam.date, ascending: false)])
        session.request(MSIRouter.readAsams(date: newestAsam?.dateString))
            .validate()
            .responseDecodable(of: AsamPropertyContainer.self, queue: queue) { response in
                queue.async( execute:{
                    Task.detached {
                        let asamCount = response.value?.asam.count
                        self.logger.debug("Received \(asamCount ?? 0) asam records.")
                        if let asams = response.value?.asam {
                            try await Asam.batchImport(from: asams, taskContext: PersistenceController.shared.newTaskContext())
                        }
                        DispatchQueue.main.async {
                            appState.loadingDataSource[Asam.key] = false
                        }
                    }
                })
            }
    }
    
    func loadModus(appState: AppState) {
        DispatchQueue.main.async {
            appState.loadingDataSource[Modu.key] = false
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        let newestModu = try? persistenceController.container.viewContext.fetchFirst(Modu.self, sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)])
                
        session.request(MSIRouter.readModus(date: newestModu?.dateString))
            .validate()
            .responseDecodable(of: ModuPropertyContainer.self, queue: queue) { response in
                queue.async( execute:{
                    Task.detached {
                        let moduCount = response.value?.modu.count
                        self.logger.debug("Received \(moduCount ?? 0) modu records.")
                        if let modus = response.value?.modu {
                            try await Modu.batchImport(from: modus, taskContext: PersistenceController.shared.newTaskContext(), viewContext: PersistenceController.shared.container.viewContext)
                        }
                        DispatchQueue.main.async {
                            appState.loadingDataSource[Modu.key] = false
                        }
                    }
                })
            }
    }
    
    func loadNavigationalWarnings(date: String? = nil, appState: AppState) {
        DispatchQueue.main.async {
            appState.loadingDataSource[NavigationalWarning.key] = true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

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
                        
                        DispatchQueue.main.async {
                            appState.loadingDataSource[NavigationalWarning.key] = false
                        }
                    }
                })
            }
    }
    
    func loadLights(date: String? = nil, appState: AppState) {
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        DispatchQueue.main.async {
            appState.loadingDataSource[Light.key] = true
        }
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(Light.self)
        print("There are \(count ?? 0) lights")
        
        struct Counter {
            var volumeQueries = 0
            mutating func increment () -> Int {
                volumeQueries = volumeQueries + 1
                return volumeQueries
            }
        }
        
        struct QueryCounter {
            static var counter = Counter()
        }
        for lightVolume in Light.lightVolumes {
            let newestLight = try? PersistenceController.shared.container.viewContext.fetchFirst(Light.self, sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)], predicate: NSPredicate(format: "volumeNumber = %@", lightVolume.volumeNumber))
            
            let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0
            
            print("Query for lights in volume \(lightVolume) after year:\(newestLight?.noticeYear ?? "") week:\(noticeWeek)")
            session.request(MSIRouter.readLights(volume: lightVolume.volumeQuery, noticeYear: newestLight?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
                .validate()
                .responseDecodable(of: LightsPropertyContainer.self, queue: queue) { response in
                    
                    switch response.result {
                    case .success:
                        print("Validation Successful")
                    case .failure(let error):
                        print("ERROR: \(error.localizedDescription) \(error)")
                    }
                    queue.async(execute:{
                        Task.detached {
                            if let lights = response.value?.ngalol {
                                try await Light.batchImport(from: lights, taskContext: PersistenceController.shared.newTaskContext())
                            }
                            QueryCounter.counter.volumeQueries += 1
                            if QueryCounter.counter.volumeQueries == Light.lightVolumes.count {
                                DispatchQueue.main.async {
                                    appState.loadingDataSource[Light.key] = false
                                }
                            }
                        }
                    })
                }
        }
    }
    
    func loadRadioBeacons(date: String? = nil, appState: AppState) {
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        DispatchQueue.main.async {
            appState.loadingDataSource[RadioBeacon.key] = true
        }
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(RadioBeacon.self)
        print("There are \(count ?? 0) radio beacons")
        let newestRadioBeacon = try? PersistenceController.shared.container.viewContext.fetchFirst(RadioBeacon.self, sortBy: [NSSortDescriptor(keyPath: \RadioBeacon.noticeNumber, ascending: false)])
        
        let noticeWeek = Int(newestRadioBeacon?.noticeWeek ?? "0") ?? 0
        
        print("Query for radio beacons after year:\(newestRadioBeacon?.noticeYear ?? "") week:\(noticeWeek)")
        session.request(MSIRouter.readRadioBeacons(noticeYear: newestRadioBeacon?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
            .validate()
            .responseDecodable(of: RadioBeaconPropertyContainer.self, queue: queue) { response in
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription) \(error)")
                }
                queue.async(execute:{
                    Task.detached {
                        if let radioBeacons = response.value?.ngalol {
                            try await RadioBeacon.batchImport(from: radioBeacons, taskContext: PersistenceController.shared.newTaskContext())
                        }
                        DispatchQueue.main.async {
                            appState.loadingDataSource[RadioBeacon.key] = false
                        }
                    }
                })
            }
    }
    
    func loadDifferentialGPSStations(date: String? = nil, appState: AppState) {
        DispatchQueue.main.async {
            appState.loadingDataSource[DifferentialGPSStation.key] = true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(DifferentialGPSStation.self)
        print("There are \(count ?? 0) differential gps stations")
        let newestDifferentialGPSStation = try? PersistenceController.shared.container.viewContext.fetchFirst(DifferentialGPSStation.self, sortBy: [NSSortDescriptor(keyPath: \DifferentialGPSStation.noticeNumber, ascending: false)])
        
        let noticeWeek = Int(newestDifferentialGPSStation?.noticeWeek ?? "0") ?? 0
        
        print("Query for differential gps stations after year:\(newestDifferentialGPSStation?.noticeYear ?? "") week:\(noticeWeek)")
        session.request(MSIRouter.readDifferentialGPSStations(noticeYear: newestDifferentialGPSStation?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
            .validate()
            .responseDecodable(of: DifferentialGPSStationPropertyContainer.self, queue: queue) { response in
                
                switch response.result {
                case .success:
                    print("Validation Successful")
                case .failure(let error):
                    print("ERROR: \(error.localizedDescription) \(error)")
                }
                queue.async(execute:{
                    Task.detached {
                        if let differentialGPSStations = response.value?.ngalol {
                            try await DifferentialGPSStation.batchImport(from: differentialGPSStations, taskContext: PersistenceController.shared.newTaskContext())
                        }
                        DispatchQueue.main.async {
                            appState.loadingDataSource[DifferentialGPSStation.key] = false
                        }
                    }
                })
            }
    }
    
    func loadPorts(resetData: Bool = false, appState: AppState) {
        let portCount = try? persistenceController.container.viewContext.countOfObjects(Port.self)
        if portCount != 0 && !resetData {
            return
        }
        DispatchQueue.main.async {
            appState.loadingDataSource[Port.key] = true
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
                        DispatchQueue.main.async {
                            appState.loadingDataSource[Port.key] = false
                        }
                    }
                })
            }
    }
    
    func loadDFRS(resetData: Bool = false, appState: AppState) {
        DispatchQueue.main.async {
            appState.loadingDataSource[DFRS.key] = true
        }
        let dfrsCount = try? persistenceController.container.viewContext.countOfObjects(DFRS.self)
        if dfrsCount != 0 && !resetData {
            return
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        session.request(MSIRouter.readDFRS)
            .validate()
            .responseDecodable(of: DFRSPropertyContainer.self, queue: queue) { response in
                queue.async( execute:{
                    Task.detached {
                        let dfrsCount = response.value?.dfrs.count
                        self.logger.debug("Received \(dfrsCount ?? 0) dfrs records.")
                        if let dfrs = response.value?.dfrs {
                            try await DFRS.batchImport(from: dfrs, taskContext: PersistenceController.shared.newTaskContext())
                        }
                        DispatchQueue.main.async {
                            appState.loadingDataSource[DFRS.key] = true
                        }
                    }
                })
            }
    }
    
    func loadDFRSAreas(resetData: Bool = false, appState: AppState) {
        DispatchQueue.main.async {
            appState.loadingDataSource[DFRS.key] = true
        }
        let dfrsCount = try? persistenceController.container.viewContext.countOfObjects(DFRSArea.self)
        if dfrsCount != 0 && !resetData {
            return
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        session.request(MSIRouter.readDFRSAreas)
            .validate()
            .responseDecodable(of: DFRSAreaPropertyContainer.self, queue: queue) { response in
                queue.async( execute:{
                    Task.detached {
                        let dfrsCount = response.value?.areas.count
                        NSLog("Received \(dfrsCount ?? 0) dfrs area records.")
                        if let areas = response.value?.areas {
                            try await DFRSArea.batchImport(from: areas, taskContext: PersistenceController.shared.newTaskContext())
                        }
                        DispatchQueue.main.async {
                            appState.loadingDataSource[DFRS.key] = true
                        }
                    }
                })
            }
    }
}

