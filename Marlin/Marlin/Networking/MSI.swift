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
        configuration.timeoutIntervalForRequest = 120
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
    
    actor Counter {
        var value = 0
        
        func increment() -> Int {
            value += 1
            return value
        }
        
        func increase() -> Int {
            return self.increment()
        }
    }
    
    func loadData<T: Decodable, D: NSManagedObject & BatchImportable>(appState: AppState, type: T.Type, dataType: D.Type) {
        DispatchQueue.main.async {
            appState.loadingDataSource[D.key] = true
        }
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        // if this is an empty database, load the initial data
        let count = try? PersistenceController.shared.container.viewContext.countOfObjects(D.self)
        
        let queryCounter = Counter()
        let loadCounter = Counter()
        if count == 0, let seedDataFiles = D.seedDataFiles {
            NSLog("Loading initial data for \(D.key)")
            for seedDataFile in seedDataFiles {
                if let localUrl = Bundle.main.url(forResource: seedDataFile, withExtension: "json") {
                    session.request(localUrl, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: .none)
                        .responseDecodable(of: T.self, queue: queue) { response in
                            queue.async( execute:{
                                Task.detached {
                                    var initialLoadObserver: NSObjectProtocol?
                                    initialLoadObserver = NotificationCenter.default.addObserver(forName: NSManagedObjectContext.didChangeObjectsNotification, object: PersistenceController.shared.container.viewContext, queue: nil) { notification in
                                        
                                        guard let userInfo = notification.userInfo else { return }
                                        
                                        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
                                            if let _ = inserts.first as? D {
                                                if let initialLoadObserver = initialLoadObserver {
                                                    NotificationCenter.default.removeObserver(initialLoadObserver, name: NSManagedObjectContext.didChangeObjectsNotification, object: PersistenceController.shared.container.viewContext)
                                                }
                                                
                                                Task.detached {
                                                    let sum = await loadCounter.increment()
                                                    if sum == seedDataFiles.count {
                                                        DispatchQueue.main.async {
                                                            appState.loadingDataSource[D.key] = false
                                                        }
                                                        MSI.shared.loadData(appState: appState, type: type, dataType: dataType)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    try await D.batchImport(value: response.value)
                                }
                            })
                        }
                }
            }
            return
        }
        
        let requests = D.dataRequest()
        
        for request in requests {
            session.request(request)
                .validate()
                .responseDecodable(of: T.self, queue: queue) { response in
                    queue.async( execute:{
                        Task.detached {
                            try await D.batchImport(value: response.value)
                            
                            let sum = await queryCounter.increment()
                            if sum == requests.count {
                                DispatchQueue.main.async {
                                    appState.loadingDataSource[D.key] = false
                                }
                            }
                        }
                    })
                }
        }
    }
    
    func loadAsams(appState: AppState) {
        MSI.shared.loadData(appState: appState, type: AsamPropertyContainer.self, dataType: Asam.self)
    }
    
    func loadModus(appState: AppState) {
        MSI.shared.loadData(appState: appState, type: ModuPropertyContainer.self, dataType: Modu.self)
    }
    
    func loadNavigationalWarnings(date: String? = nil, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: NavigationalWarningPropertyContainer.self, dataType: NavigationalWarning.self)
    }
    
    func loadLights(date: String? = nil, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: LightsPropertyContainer.self, dataType: Light.self)
    }
    
    func loadPorts(resetData: Bool = false, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: PortPropertyContainer.self, dataType: Port.self)
    }
    
    func loadRadioBeacons(date: String? = nil, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: RadioBeaconPropertyContainer.self, dataType: RadioBeacon.self)
    }
    
    func loadDifferentialGPSStations(date: String? = nil, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: DifferentialGPSStationPropertyContainer.self, dataType: DifferentialGPSStation.self)
    }
    
    func loadDFRS(resetData: Bool = false, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: DFRSPropertyContainer.self, dataType: DFRS.self)
    }
    
    func loadDFRSAreas(resetData: Bool = false, appState: AppState) {
        MSI.shared.loadData(appState: appState, type: DFRSAreaPropertyContainer.self, dataType: DFRSArea.self)
    }
}

