//
//  NavigationalWarningDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class NavigationalWarningDataTests: XCTestCase {

    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.navWarning)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")

        UserDefaults.standard.setFilter(DataSources.navWarning.key, filter: [])
        UserDefaults.standard.setSort(DataSources.navWarning.key, sort: DataSources.navWarning.filterable!.defaultSort)
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    override func tearDown() {
        HTTPStubs.removeAllStubs()
    }
    
    func testLoadData() async throws {

        stub(condition: isScheme("https") && pathEndsWith("/publications/broadcast-warn")) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("navwarnMockData.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 2)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let processed = expectation(forNotification: .DataSourceProcessed,
                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        let repository = NavigationalWarningRepository(localDataSource: NavigationalWarningCoreDataDataSource(), remoteDataSource: NavigationalWarningRemoteDataSource())

        let fetched = await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 2)
    }
    
    func testRejectInvalidNavigationalWarningNoMsgYear() async throws {
        stub(condition: isScheme("https") && pathEndsWith("/publications/broadcast-warn")) { request in
            let jsonObject = [
                "broadcast-warn": [
                    [
                        "msgYear": 2022,
                        "msgNumber": 1177,
                        "navArea": "4",
                        "subregion": "11,26",
                        "text": "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n",
                        "status": "A",
                        "issueDate": "072239Z NOV 2022",
                        "authority": "EASTERN RANGE 0/22 072203Z NOV 22.",
                        "cancelDate": nil,
                        "cancelNavArea": nil,
                        "cancelMsgYear": nil,
                        "cancelMsgNumber": nil,
                        "year": 2022,
                        "area": "4",
                        "number": 1177
                    ],
                    [
                        "msgYear": nil,
                        "msgNumber": 1169,
                        "navArea": "4",
                        "subregion": "GEN",
                        "text": "1. NAVAREA IV WARNINGS IN FORCE AS OF 041421Z NOV.\n   ALL THE INFORCE WARNINGS ARE LISTED HERE.\n   1168/22, 1167/22, 1166/22, 1165/22, 1163/22,\n   1159/22, 1156/22, 1151/22, 1147/22, 1144/22,\n   1143/22, 1138/22, 1135/22, 1131/22, 1119/22,\n   1118/22, 1117/22, 1116/22, 1109/22, 1082/22,\n   1075/22, 1066/22, 1051/22, 988/22, 964/22,\n   934/22, 916/22, 891/22, 856/22, 842/22, 823/22,\n   796/22, 793/22, 756/22, 748/22, 700/22, 668/22,\n   648/22, 644/22, 592/22, 591/22, 536/22, 516/22,\n   490/22, 441/22, 439/22, 367/22, 362/22, 316/22,\n   315/22, 295/22, 227/22, 212/22, 186/22, 141/22,\n   120/22.\n   1176/21, 1173/21, 1171/21, 1170/21, 1164/21,\n   1161/21, 1160/21, 1159/21, 1157/21, 1156/21,\n   1113/21, 1003/21, 977/21, 967/21, 961/21,\n   779/21, 778/21, 720/21, 665/21, 407/21, 346/21,\n   341/21, 306/21, 278/21, 277/21, 144/21.\n2. THE COMPLETE TEXT OF ALL IN-FORCE NAVAREA IV\n   BROADCAST WARNINGS ARE AVAILABLE ON THE NGA\n   MARITIME SAFETY INFORMATION WEBSITE AT:\n   MSI.NGA.MIL/NAVWARNINGS.\n   ALTERNATIVELY, THESE MAY BE REQUESTED BY E-MAIL\n   FROM THE NAVAREA IV COORDINATOR AT NAVSAFETY@NGA.MIL.\n3. CANCEL NAVAREA IV 1100/22, 1139/22, 1145/22.\n",
                        "status": "A",
                        "issueDate": "041426Z NOV 2022",
                        "authority": "NGA NAVSAFETY 0/22 041421Z NOV 22.",
                        "cancelDate": nil,
                        "cancelNavArea": nil,
                        "cancelMsgYear": nil,
                        "cancelMsgNumber": nil,
                        "year": 2022,
                        "area": "4",
                        "number": 1169
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        
        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NavigationalWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NavigationalWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        let repository = NavigationalWarningRepository(
            localDataSource: NavigationalWarningCoreDataDataSource(),
            remoteDataSource: NavigationalWarningRemoteDataSource()
        )

        await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)
    }
    
    func testRejectInvalidNavigationalWarningNoMsgNumber() async throws {
        stub(condition: isScheme("https") && pathEndsWith("/publications/broadcast-warn")) { request in
            let jsonObject = [
                "broadcast-warn": [
                    [
                        "msgYear": 2022,
                        "msgNumber": 1177,
                        "navArea": "4",
                        "subregion": "11,26",
                        "text": "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n",
                        "status": "A",
                        "issueDate": "072239Z NOV 2022",
                        "authority": "EASTERN RANGE 0/22 072203Z NOV 22.",
                        "cancelDate": nil,
                        "cancelNavArea": nil,
                        "cancelMsgYear": nil,
                        "cancelMsgNumber": nil,
                        "year": 2022,
                        "area": "4",
                        "number": 1177
                    ],
                    [
                        "msgYear": 2022,
                        "msgNumber": nil,
                        "navArea": "4",
                        "subregion": "GEN",
                        "text": "1. NAVAREA IV WARNINGS IN FORCE AS OF 041421Z NOV.\n   ALL THE INFORCE WARNINGS ARE LISTED HERE.\n   1168/22, 1167/22, 1166/22, 1165/22, 1163/22,\n   1159/22, 1156/22, 1151/22, 1147/22, 1144/22,\n   1143/22, 1138/22, 1135/22, 1131/22, 1119/22,\n   1118/22, 1117/22, 1116/22, 1109/22, 1082/22,\n   1075/22, 1066/22, 1051/22, 988/22, 964/22,\n   934/22, 916/22, 891/22, 856/22, 842/22, 823/22,\n   796/22, 793/22, 756/22, 748/22, 700/22, 668/22,\n   648/22, 644/22, 592/22, 591/22, 536/22, 516/22,\n   490/22, 441/22, 439/22, 367/22, 362/22, 316/22,\n   315/22, 295/22, 227/22, 212/22, 186/22, 141/22,\n   120/22.\n   1176/21, 1173/21, 1171/21, 1170/21, 1164/21,\n   1161/21, 1160/21, 1159/21, 1157/21, 1156/21,\n   1113/21, 1003/21, 977/21, 967/21, 961/21,\n   779/21, 778/21, 720/21, 665/21, 407/21, 346/21,\n   341/21, 306/21, 278/21, 277/21, 144/21.\n2. THE COMPLETE TEXT OF ALL IN-FORCE NAVAREA IV\n   BROADCAST WARNINGS ARE AVAILABLE ON THE NGA\n   MARITIME SAFETY INFORMATION WEBSITE AT:\n   MSI.NGA.MIL/NAVWARNINGS.\n   ALTERNATIVELY, THESE MAY BE REQUESTED BY E-MAIL\n   FROM THE NAVAREA IV COORDINATOR AT NAVSAFETY@NGA.MIL.\n3. CANCEL NAVAREA IV 1100/22, 1139/22, 1145/22.\n",
                        "status": "A",
                        "issueDate": "041426Z NOV 2022",
                        "authority": "NGA NAVSAFETY 0/22 041421Z NOV 22.",
                        "cancelDate": nil,
                        "cancelNavArea": nil,
                        "cancelMsgYear": nil,
                        "cancelMsgNumber": nil,
                        "year": 2022,
                        "area": "4",
                        "number": 1169
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NavigationalWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NavigationalWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        let repository = NavigationalWarningRepository(
            localDataSource: NavigationalWarningCoreDataDataSource(),
            remoteDataSource: NavigationalWarningRemoteDataSource()
        )

        await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)
    }
    
    func testRejectInvalidNavigationalWarningNoNavArea() async throws {
        stub(condition: isScheme("https") && pathEndsWith("/publications/broadcast-warn")) { request in
            let jsonObject = [
                "broadcast-warn": [
                    [
                        "msgYear": 2022,
                        "msgNumber": 1177,
                        "navArea": nil,
                        "subregion": "11,26",
                        "text": "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n",
                        "status": "A",
                        "issueDate": "072239Z NOV 2022",
                        "authority": "EASTERN RANGE 0/22 072203Z NOV 22.",
                        "cancelDate": nil,
                        "cancelNavArea": nil,
                        "cancelMsgYear": nil,
                        "cancelMsgNumber": nil,
                        "year": 2022,
                        "area": "4",
                        "number": 1177
                    ],
                    [
                        "msgYear": 2022,
                        "msgNumber": 1169,
                        "navArea": "4",
                        "subregion": "GEN",
                        "text": "1. NAVAREA IV WARNINGS IN FORCE AS OF 041421Z NOV.\n   ALL THE INFORCE WARNINGS ARE LISTED HERE.\n   1168/22, 1167/22, 1166/22, 1165/22, 1163/22,\n   1159/22, 1156/22, 1151/22, 1147/22, 1144/22,\n   1143/22, 1138/22, 1135/22, 1131/22, 1119/22,\n   1118/22, 1117/22, 1116/22, 1109/22, 1082/22,\n   1075/22, 1066/22, 1051/22, 988/22, 964/22,\n   934/22, 916/22, 891/22, 856/22, 842/22, 823/22,\n   796/22, 793/22, 756/22, 748/22, 700/22, 668/22,\n   648/22, 644/22, 592/22, 591/22, 536/22, 516/22,\n   490/22, 441/22, 439/22, 367/22, 362/22, 316/22,\n   315/22, 295/22, 227/22, 212/22, 186/22, 141/22,\n   120/22.\n   1176/21, 1173/21, 1171/21, 1170/21, 1164/21,\n   1161/21, 1160/21, 1159/21, 1157/21, 1156/21,\n   1113/21, 1003/21, 977/21, 967/21, 961/21,\n   779/21, 778/21, 720/21, 665/21, 407/21, 346/21,\n   341/21, 306/21, 278/21, 277/21, 144/21.\n2. THE COMPLETE TEXT OF ALL IN-FORCE NAVAREA IV\n   BROADCAST WARNINGS ARE AVAILABLE ON THE NGA\n   MARITIME SAFETY INFORMATION WEBSITE AT:\n   MSI.NGA.MIL/NAVWARNINGS.\n   ALTERNATIVELY, THESE MAY BE REQUESTED BY E-MAIL\n   FROM THE NAVAREA IV COORDINATOR AT NAVSAFETY@NGA.MIL.\n3. CANCEL NAVAREA IV 1100/22, 1139/22, 1145/22.\n",
                        "status": "A",
                        "issueDate": "041426Z NOV 2022",
                        "authority": "NGA NAVSAFETY 0/22 041421Z NOV 22.",
                        "cancelDate": nil,
                        "cancelNavArea": nil,
                        "cancelMsgYear": nil,
                        "cancelMsgNumber": nil,
                        "year": 2022,
                        "area": "4",
                        "number": 1169
                    ]
                ]
            ]
            return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
        }
        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NavigationalWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[NavigationalWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(1, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        let repository = NavigationalWarningRepository(
            localDataSource: NavigationalWarningCoreDataDataSource(),
            remoteDataSource: NavigationalWarningRemoteDataSource()
        )

        await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)
    }
    
    func testUpdateNavigationalWarningsDeleteOld() async throws {
        var requestCount = 0
        stub(condition: isScheme("https") && pathEndsWith("/publications/broadcast-warn")) { request in
            if requestCount == 0 {
                requestCount += 1
                let jsonObject = [
                    "broadcast-warn": [
                        [
                            "msgYear": 2022,
                            "msgNumber": 1177,
                            "navArea": "4",
                            "subregion": "11,26",
                            "text": "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n",
                            "status": "A",
                            "issueDate": "072239Z NOV 2022",
                            "authority": "EASTERN RANGE 0/22 072203Z NOV 22.",
                            "cancelDate": nil,
                            "cancelNavArea": nil,
                            "cancelMsgYear": nil,
                            "cancelMsgNumber": nil,
                            "year": 2022,
                            "area": "4",
                            "number": 1177
                        ],
                        [
                            "msgYear": 2022,
                            "msgNumber": 1169,
                            "navArea": "4",
                            "subregion": "GEN",
                            "text": "1. NAVAREA IV WARNINGS IN FORCE AS OF 041421Z NOV.\n   ALL THE INFORCE WARNINGS ARE LISTED HERE.\n   1168/22, 1167/22, 1166/22, 1165/22, 1163/22,\n   1159/22, 1156/22, 1151/22, 1147/22, 1144/22,\n   1143/22, 1138/22, 1135/22, 1131/22, 1119/22,\n   1118/22, 1117/22, 1116/22, 1109/22, 1082/22,\n   1075/22, 1066/22, 1051/22, 988/22, 964/22,\n   934/22, 916/22, 891/22, 856/22, 842/22, 823/22,\n   796/22, 793/22, 756/22, 748/22, 700/22, 668/22,\n   648/22, 644/22, 592/22, 591/22, 536/22, 516/22,\n   490/22, 441/22, 439/22, 367/22, 362/22, 316/22,\n   315/22, 295/22, 227/22, 212/22, 186/22, 141/22,\n   120/22.\n   1176/21, 1173/21, 1171/21, 1170/21, 1164/21,\n   1161/21, 1160/21, 1159/21, 1157/21, 1156/21,\n   1113/21, 1003/21, 977/21, 967/21, 961/21,\n   779/21, 778/21, 720/21, 665/21, 407/21, 346/21,\n   341/21, 306/21, 278/21, 277/21, 144/21.\n2. THE COMPLETE TEXT OF ALL IN-FORCE NAVAREA IV\n   BROADCAST WARNINGS ARE AVAILABLE ON THE NGA\n   MARITIME SAFETY INFORMATION WEBSITE AT:\n   MSI.NGA.MIL/NAVWARNINGS.\n   ALTERNATIVELY, THESE MAY BE REQUESTED BY E-MAIL\n   FROM THE NAVAREA IV COORDINATOR AT NAVSAFETY@NGA.MIL.\n3. CANCEL NAVAREA IV 1100/22, 1139/22, 1145/22.\n",
                            "status": "A",
                            "issueDate": "041426Z NOV 2022",
                            "authority": "NGA NAVSAFETY 0/22 041421Z NOV 22.",
                            "cancelDate": nil,
                            "cancelNavArea": nil,
                            "cancelMsgYear": nil,
                            "cancelMsgNumber": nil,
                            "year": 2022,
                            "area": "4",
                            "number": 1169
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            } else {
                let jsonObject = [
                    "broadcast-warn": [
                        [
                            "msgYear": 2022,
                            "msgNumber": 1169,
                            "navArea": "4",
                            "subregion": "GEN",
                            "text": "1. NAVAREA IV WARNINGS IN FORCE AS OF 041421Z NOV.\n   ALL THE INFORCE WARNINGS ARE LISTED HERE.\n   1168/22, 1167/22, 1166/22, 1165/22, 1163/22,\n   1159/22, 1156/22, 1151/22, 1147/22, 1144/22,\n   1143/22, 1138/22, 1135/22, 1131/22, 1119/22,\n   1118/22, 1117/22, 1116/22, 1109/22, 1082/22,\n   1075/22, 1066/22, 1051/22, 988/22, 964/22,\n   934/22, 916/22, 891/22, 856/22, 842/22, 823/22,\n   796/22, 793/22, 756/22, 748/22, 700/22, 668/22,\n   648/22, 644/22, 592/22, 591/22, 536/22, 516/22,\n   490/22, 441/22, 439/22, 367/22, 362/22, 316/22,\n   315/22, 295/22, 227/22, 212/22, 186/22, 141/22,\n   120/22.\n   1176/21, 1173/21, 1171/21, 1170/21, 1164/21,\n   1161/21, 1160/21, 1159/21, 1157/21, 1156/21,\n   1113/21, 1003/21, 977/21, 967/21, 961/21,\n   779/21, 778/21, 720/21, 665/21, 407/21, 346/21,\n   341/21, 306/21, 278/21, 277/21, 144/21.\n2. THE COMPLETE TEXT OF ALL IN-FORCE NAVAREA IV\n   BROADCAST WARNINGS ARE AVAILABLE ON THE NGA\n   MARITIME SAFETY INFORMATION WEBSITE AT:\n   MSI.NGA.MIL/NAVWARNINGS.\n   ALTERNATIVELY, THESE MAY BE REQUESTED BY E-MAIL\n   FROM THE NAVAREA IV COORDINATOR AT NAVSAFETY@NGA.MIL.\n3. CANCEL NAVAREA IV 1100/22, 1139/22, 1145/22.\n",
                            "status": "A",
                            "issueDate": "041426Z NOV 2022",
                            "authority": "NGA NAVSAFETY 0/22 041421Z NOV 22.",
                            "cancelDate": nil,
                            "cancelNavArea": nil,
                            "cancelMsgYear": nil,
                            "cancelMsgNumber": nil,
                            "year": 2022,
                            "area": "4",
                            "number": 1169
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }

        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 2)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        let repository = NavigationalWarningRepository(localDataSource: NavigationalWarningCoreDataDataSource(), remoteDataSource: NavigationalWarningRemoteDataSource())

        let fetched = await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 2)

        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                               object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification2 = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let batchUpdateCompleteNotification2 = expectation(forNotification: .BatchUpdateComplete,
                                                           object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            NSLog("updates \(updates)")
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(0, update.inserts)
            XCTAssertEqual(0, update.updates)
            XCTAssertEqual(1, update.deletes)
            return true
        }

        let processed2 = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        // force the sync
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.navWarning)
        let fetched2 = await repository.fetch()

        await fulfillment(of: [loadingNotification2, loadedNotification2, didSaveNotification2, batchUpdateCompleteNotification2, processed2], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 1)
    }
    
    func testUpdateNavigationalWarningsDeleteOldAddNew() async throws {
        var requestCount = 0
        stub(condition: isScheme("https") && pathEndsWith("/publications/broadcast-warn")) { request in
            if requestCount == 0 {
                requestCount += 1
                let jsonObject = [
                    "broadcast-warn": [
                        [
                            "msgYear": 2022,
                            "msgNumber": 1177,
                            "navArea": "4",
                            "subregion": "11,26",
                            "text": "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n",
                            "status": "A",
                            "issueDate": "072239Z NOV 2022",
                            "authority": "EASTERN RANGE 0/22 072203Z NOV 22.",
                            "cancelDate": nil,
                            "cancelNavArea": nil,
                            "cancelMsgYear": nil,
                            "cancelMsgNumber": nil,
                            "year": 2022,
                            "area": "4",
                            "number": 1177
                        ],
                        [
                            "msgYear": 2022,
                            "msgNumber": 1169,
                            "navArea": "4",
                            "subregion": "GEN",
                            "text": "1. NAVAREA IV WARNINGS IN FORCE AS OF 041421Z NOV.\n   ALL THE INFORCE WARNINGS ARE LISTED HERE.\n   1168/22, 1167/22, 1166/22, 1165/22, 1163/22,\n   1159/22, 1156/22, 1151/22, 1147/22, 1144/22,\n   1143/22, 1138/22, 1135/22, 1131/22, 1119/22,\n   1118/22, 1117/22, 1116/22, 1109/22, 1082/22,\n   1075/22, 1066/22, 1051/22, 988/22, 964/22,\n   934/22, 916/22, 891/22, 856/22, 842/22, 823/22,\n   796/22, 793/22, 756/22, 748/22, 700/22, 668/22,\n   648/22, 644/22, 592/22, 591/22, 536/22, 516/22,\n   490/22, 441/22, 439/22, 367/22, 362/22, 316/22,\n   315/22, 295/22, 227/22, 212/22, 186/22, 141/22,\n   120/22.\n   1176/21, 1173/21, 1171/21, 1170/21, 1164/21,\n   1161/21, 1160/21, 1159/21, 1157/21, 1156/21,\n   1113/21, 1003/21, 977/21, 967/21, 961/21,\n   779/21, 778/21, 720/21, 665/21, 407/21, 346/21,\n   341/21, 306/21, 278/21, 277/21, 144/21.\n2. THE COMPLETE TEXT OF ALL IN-FORCE NAVAREA IV\n   BROADCAST WARNINGS ARE AVAILABLE ON THE NGA\n   MARITIME SAFETY INFORMATION WEBSITE AT:\n   MSI.NGA.MIL/NAVWARNINGS.\n   ALTERNATIVELY, THESE MAY BE REQUESTED BY E-MAIL\n   FROM THE NAVAREA IV COORDINATOR AT NAVSAFETY@NGA.MIL.\n3. CANCEL NAVAREA IV 1100/22, 1139/22, 1145/22.\n",
                            "status": "A",
                            "issueDate": "041426Z NOV 2022",
                            "authority": "NGA NAVSAFETY 0/22 041421Z NOV 22.",
                            "cancelDate": nil,
                            "cancelNavArea": nil,
                            "cancelMsgYear": nil,
                            "cancelMsgNumber": nil,
                            "year": 2022,
                            "area": "4",
                            "number": 1169
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            } else {
                let jsonObject = [
                    "broadcast-warn": [
                        [
                            "msgYear": 2023,
                            "msgNumber": 1177,
                            "navArea": "4",
                            "subregion": "11,26",
                            "text": "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n",
                            "status": "A",
                            "issueDate": "072239Z NOV 2022",
                            "authority": "EASTERN RANGE 0/22 072203Z NOV 22.",
                            "cancelDate": nil,
                            "cancelNavArea": nil,
                            "cancelMsgYear": nil,
                            "cancelMsgNumber": nil,
                            "year": 2023,
                            "area": "4",
                            "number": 1177
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        let loadingNotification = expectation(forNotification: .DataSourceLoading,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification = expectation(forNotification: .DataSourceLoaded,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 2)
            return true
        }

        let batchUpdateCompleteNotification = expectation(forNotification: .BatchUpdateComplete,
                                                          object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let processed = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        let repository = NavigationalWarningRepository(localDataSource: NavigationalWarningCoreDataDataSource(), remoteDataSource: NavigationalWarningRemoteDataSource())

        let fetched = await repository.fetch()

        await fulfillment(of: [loadingNotification, loadedNotification, didSaveNotification, batchUpdateCompleteNotification, processed], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 2)

        let loadingNotification2 = expectation(forNotification: .DataSourceLoading,
                                               object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedNotification2 = expectation(forNotification: .DataSourceLoaded,
                                              object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.navWarning.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let didSaveNotification2 = expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(NavigationalWarning.self)
            XCTAssertEqual(count, 1)
            return true
        }

        let processed2 = expectation(forNotification: .DataSourceProcessed,
                                    object: nil) { notification in
            XCTAssertEqual((notification.object as? DataSourceUpdatedNotification)?.key, DataSources.navWarning.key)
            return true
        }

        // force the sync
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.navWarning)
        let fetched2 = await repository.fetch()

        await fulfillment(of: [
            loadingNotification2,
            loadedNotification2,
            didSaveNotification2,
            processed2
        ], timeout: 10)

        XCTAssertEqual(repository.getCount(filters: nil), 1)

        let navWarn = repository.getNavigationalWarning(msgYear: 2023, msgNumber: 1177, navArea: "4")

        XCTAssertEqual(navWarn!.msgYear, 2023)
        XCTAssertEqual(navWarn!.msgNumber, 1177)
    }
    
    func testDataRequest() {
        let request = NavigationalWarningService.getNavigationalWarnings
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 2)
        XCTAssertEqual(parameters?["status"] as? String, "active")
        XCTAssertEqual(parameters?["output"] as? String, "json")
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.navWarning.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.navWarning.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.navWarning.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60) - 10, forKey: "\(DataSources.navWarning.key)LastSyncTime")
        XCTAssertTrue(DataSources.navWarning.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60) + (60 * 10), forKey: "\(DataSources.navWarning.key)LastSyncTime")
        XCTAssertFalse(DataSources.navWarning.shouldSync())
    }
}
