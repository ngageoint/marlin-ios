//
//  PortDataTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/22.
//

import XCTest
import Combine
import OHHTTPStubs
import CoreData

@testable import Marlin

final class PortDataTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.memory
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore = PersistenceController.memory
        persistentStore.reset()
    }
    
    override func tearDown() {
    }
    
    func testLoadInitialData() throws {
        
        for seedDataFile in Port.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                return HTTPStubsResponse(
                    fileAtPath: OHPathForFile("portMockData.json", type(of: self))!,
                    statusCode: 200,
                    headers: ["Content-Type":"application/json"]
                )
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Port.self)
            XCTAssertEqual(count, 2)
            return true
        }
        
        MSI.shared.loadInitialData(type: Marlin.Port.decodableRoot, dataType: Marlin.Port.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidPortNoPortNumber() throws {
        for seedDataFile in Port.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ports": [
                        [
                            "portNumber": nil,
                            "portName": "Aasiaat",
                            "regionNumber": 545,
                            "regionName": "GREENLAND  WEST COAST",
                            "countryCode": "GL",
                            "countryName": "Greenland",
                            "latitude": "68°42'00\"N",
                            "longitude": "52°52'00\"W",
                            "publicationNumber": "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland",
                            "chartNumber": nil,
                            "navArea": "XVIII",
                            "harborSize": "S",
                            "harborType": "CN",
                            "shelter": "G",
                            "erTide": "N",
                            "erSwell": "N",
                            "erIce": "Y",
                            "erOther": "Y",
                            "overheadLimits": "U",
                            "chDepth": "23",
                            "anDepth": "23",
                            "cpDepth": "8",
                            "otDepth": nil,
                            "tide": 3,
                            "maxVesselLength": nil,
                            "maxVesselBeam": nil,
                            "maxVesselDraft": nil,
                            "goodHoldingGround": "N",
                            "turningArea": "U",
                            "firstPortOfEntry": "N",
                            "usRep": "N",
                            "ptCompulsory": "N",
                            "ptAvailable": nil,
                            "ptLocalAssist": nil,
                            "ptAdvisable": "Y",
                            "tugsSalvage": "N",
                            "tugsAssist": "N",
                            "qtPratique": "U",
                            "qtOther": "U",
                            "cmTelephone": "U",
                            "cmTelegraph": "U",
                            "cmRadio": "Y",
                            "cmRadioTel": "U",
                            "cmAir": "Y",
                            "cmRail": "U",
                            "loWharves": "Y",
                            "loAnchor": "U",
                            "loMedMoor": "U",
                            "loBeachMoor": "U",
                            "loIceMoor": "U",
                            "medFacilities": "Y",
                            "garbageDisposal": "N",
                            "degauss": "U",
                            "dirtyBallast": "N",
                            "crFixed": "U",
                            "crMobile": "Y",
                            "crFloating": "U",
                            "lifts100": "U",
                            "lifts50": "U",
                            "lifts25": "U",
                            "lifts0": "Y",
                            "srLongshore": "U",
                            "srElectrical": "U",
                            "srSteam": "U",
                            "srNavigEquip": "U",
                            "srElectRepair": "U",
                            "suProvisions": "Y",
                            "suWater": "Y",
                            "suFuel": "Y",
                            "suDiesel": "U",
                            "suDeck": "U",
                            "suEngine": "U",
                            "repairCode": "C",
                            "drydock": "U",
                            "railway": "S",
                            "qtSanitation": "U",
                            "suAviationFuel": "U",
                            "harborUse": "UNK",
                            "ukcMgmtSystem": "U",
                            "portSecurity": "U",
                            "etaMessage": "Y",
                            "searchAndRescue": "U",
                            "tss": "U",
                            "vts": "U",
                            "cht": "U",
                            "globalId": "{2C117765-0922-4542-A2B9-333253552952}",
                            "loRoro": "U",
                            "loSolidBulk": "U",
                            "loContainer": "U",
                            "loBreakBulk": "U",
                            "loOilTerm": "U",
                            "loLongTerm": "U",
                            "loOther": "U",
                            "loDangCargo": "U",
                            "loLiquidBulk": "U",
                            "srIceBreaking": "U",
                            "srDiving": "U",
                            "cranesContainer": "U",
                            "unloCode": "GL JEG",
                            "dnc": "a2800670, coa28e, gen28b, h2800670",
                            "s121WaterBody": "",
                            "s57Enc": nil,
                            "s101Enc": "",
                            "dodWaterBody": "Baffin Bay; Arctic Ocean",
                            "alternateName": "Egedesminde",
                            "entranceWidth": nil,
                            "lngTerminalDepth": nil,
                            "offMaxVesselLength": nil,
                            "offMaxVesselBeam": nil,
                            "offMaxVesselDraft": nil,
                            "ycoord": 68.70000000000005,
                            "xcoord": -52.86666699999995
                        ],
                        [
                            "portNumber": 48430,
                            "portName": "Abadan",
                            "regionNumber": 48410,
                            "regionName": "IRAN",
                            "countryCode": "IR",
                            "countryName": "Iran",
                            "latitude": "30°20'00\"N",
                            "longitude": "48°17'00\"E",
                            "publicationNumber": "Sailing Directions Pub. 172 (Enroute) - Red Sea and the Persian Gulf",
                            "chartNumber": "62594",
                            "navArea": "IX",
                            "harborSize": "M",
                            "harborType": "RN",
                            "shelter": "G",
                            "erTide": "Y",
                            "erSwell": "N",
                            "erIce": "N",
                            "erOther": "Y",
                            "overheadLimits": "U",
                            "chDepth": "9",
                            "anDepth": "9",
                            "cpDepth": "9",
                            "otDepth": nil,
                            "tide": 1,
                            "maxVesselLength": nil,
                            "maxVesselBeam": nil,
                            "maxVesselDraft": nil,
                            "goodHoldingGround": "U",
                            "turningArea": "Y",
                            "firstPortOfEntry": "Y",
                            "usRep": "N",
                            "ptCompulsory": "Y",
                            "ptAvailable": nil,
                            "ptLocalAssist": nil,
                            "ptAdvisable": "Y",
                            "tugsSalvage": "N",
                            "tugsAssist": "Y",
                            "qtPratique": "Y",
                            "qtOther": "U",
                            "cmTelephone": "Y",
                            "cmTelegraph": "Y",
                            "cmRadio": "Y",
                            "cmRadioTel": "U",
                            "cmAir": "Y",
                            "cmRail": "U",
                            "loWharves": "Y",
                            "loAnchor": "U",
                            "loMedMoor": "U",
                            "loBeachMoor": "U",
                            "loIceMoor": "U",
                            "medFacilities": "Y",
                            "garbageDisposal": "U",
                            "degauss": "U",
                            "dirtyBallast": "N",
                            "crFixed": "U",
                            "crMobile": "Y",
                            "crFloating": "Y",
                            "lifts100": "Y",
                            "lifts50": "U",
                            "lifts25": "U",
                            "lifts0": "Y",
                            "srLongshore": "Y",
                            "srElectrical": "U",
                            "srSteam": "U",
                            "srNavigEquip": "U",
                            "srElectRepair": "U",
                            "suProvisions": "U",
                            "suWater": "Y",
                            "suFuel": "Y",
                            "suDiesel": "Y",
                            "suDeck": "U",
                            "suEngine": "U",
                            "repairCode": "C",
                            "drydock": "S",
                            "railway": "S",
                            "qtSanitation": "Y",
                            "suAviationFuel": "U",
                            "harborUse": "UNK",
                            "ukcMgmtSystem": "U",
                            "portSecurity": "U",
                            "etaMessage": "Y",
                            "searchAndRescue": "U",
                            "tss": "U",
                            "vts": "U",
                            "cht": "U",
                            "globalId": "{361E3AAE-91D3-4564-B99A-A14B52D7E21B}",
                            "loRoro": "U",
                            "loSolidBulk": "U",
                            "loContainer": "U",
                            "loBreakBulk": "U",
                            "loOilTerm": "U",
                            "loLongTerm": "U",
                            "loOther": "U",
                            "loDangCargo": "U",
                            "loLiquidBulk": "U",
                            "srIceBreaking": "U",
                            "srDiving": "U",
                            "cranesContainer": "U",
                            "unloCode": "IR ABD",
                            "dnc": "coa10n, gen10a, h1048385",
                            "s121WaterBody": "",
                            "s57Enc": nil,
                            "s101Enc": "",
                            "dodWaterBody": "Persian Gulf; Indian Ocean",
                            "alternateName": nil,
                            "entranceWidth": nil,
                            "lngTerminalDepth": nil,
                            "offMaxVesselLength": nil,
                            "offMaxVesselBeam": nil,
                            "offMaxVesselDraft": nil,
                            "ycoord": 30.33333300000004,
                            "xcoord": 48.28333300000003
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Port.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Marlin.Port.decodableRoot, dataType: Marlin.Port.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidPortNoLatitude() throws {
        for seedDataFile in Port.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                    "ports": [
                        [
                            "portNumber": 760,
                            "portName": "Aasiaat",
                            "regionNumber": 545,
                            "regionName": "GREENLAND  WEST COAST",
                            "countryCode": "GL",
                            "countryName": "Greenland",
                            "latitude": "68°42'00\"N",
                            "longitude": "52°52'00\"W",
                            "publicationNumber": "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland",
                            "chartNumber": nil,
                            "navArea": "XVIII",
                            "harborSize": "S",
                            "harborType": "CN",
                            "shelter": "G",
                            "erTide": "N",
                            "erSwell": "N",
                            "erIce": "Y",
                            "erOther": "Y",
                            "overheadLimits": "U",
                            "chDepth": "23",
                            "anDepth": "23",
                            "cpDepth": "8",
                            "otDepth": nil,
                            "tide": 3,
                            "maxVesselLength": nil,
                            "maxVesselBeam": nil,
                            "maxVesselDraft": nil,
                            "goodHoldingGround": "N",
                            "turningArea": "U",
                            "firstPortOfEntry": "N",
                            "usRep": "N",
                            "ptCompulsory": "N",
                            "ptAvailable": nil,
                            "ptLocalAssist": nil,
                            "ptAdvisable": "Y",
                            "tugsSalvage": "N",
                            "tugsAssist": "N",
                            "qtPratique": "U",
                            "qtOther": "U",
                            "cmTelephone": "U",
                            "cmTelegraph": "U",
                            "cmRadio": "Y",
                            "cmRadioTel": "U",
                            "cmAir": "Y",
                            "cmRail": "U",
                            "loWharves": "Y",
                            "loAnchor": "U",
                            "loMedMoor": "U",
                            "loBeachMoor": "U",
                            "loIceMoor": "U",
                            "medFacilities": "Y",
                            "garbageDisposal": "N",
                            "degauss": "U",
                            "dirtyBallast": "N",
                            "crFixed": "U",
                            "crMobile": "Y",
                            "crFloating": "U",
                            "lifts100": "U",
                            "lifts50": "U",
                            "lifts25": "U",
                            "lifts0": "Y",
                            "srLongshore": "U",
                            "srElectrical": "U",
                            "srSteam": "U",
                            "srNavigEquip": "U",
                            "srElectRepair": "U",
                            "suProvisions": "Y",
                            "suWater": "Y",
                            "suFuel": "Y",
                            "suDiesel": "U",
                            "suDeck": "U",
                            "suEngine": "U",
                            "repairCode": "C",
                            "drydock": "U",
                            "railway": "S",
                            "qtSanitation": "U",
                            "suAviationFuel": "U",
                            "harborUse": "UNK",
                            "ukcMgmtSystem": "U",
                            "portSecurity": "U",
                            "etaMessage": "Y",
                            "searchAndRescue": "U",
                            "tss": "U",
                            "vts": "U",
                            "cht": "U",
                            "globalId": "{2C117765-0922-4542-A2B9-333253552952}",
                            "loRoro": "U",
                            "loSolidBulk": "U",
                            "loContainer": "U",
                            "loBreakBulk": "U",
                            "loOilTerm": "U",
                            "loLongTerm": "U",
                            "loOther": "U",
                            "loDangCargo": "U",
                            "loLiquidBulk": "U",
                            "srIceBreaking": "U",
                            "srDiving": "U",
                            "cranesContainer": "U",
                            "unloCode": "GL JEG",
                            "dnc": "a2800670, coa28e, gen28b, h2800670",
                            "s121WaterBody": "",
                            "s57Enc": nil,
                            "s101Enc": "",
                            "dodWaterBody": "Baffin Bay; Arctic Ocean",
                            "alternateName": "Egedesminde",
                            "entranceWidth": nil,
                            "lngTerminalDepth": nil,
                            "offMaxVesselLength": nil,
                            "offMaxVesselBeam": nil,
                            "offMaxVesselDraft": nil,
                            "ycoord": 68.70000000000005,
                            "xcoord": nil
                        ],
                        [
                            "portNumber": 48430,
                            "portName": "Abadan",
                            "regionNumber": 48410,
                            "regionName": "IRAN",
                            "countryCode": "IR",
                            "countryName": "Iran",
                            "latitude": "30°20'00\"N",
                            "longitude": "48°17'00\"E",
                            "publicationNumber": "Sailing Directions Pub. 172 (Enroute) - Red Sea and the Persian Gulf",
                            "chartNumber": "62594",
                            "navArea": "IX",
                            "harborSize": "M",
                            "harborType": "RN",
                            "shelter": "G",
                            "erTide": "Y",
                            "erSwell": "N",
                            "erIce": "N",
                            "erOther": "Y",
                            "overheadLimits": "U",
                            "chDepth": "9",
                            "anDepth": "9",
                            "cpDepth": "9",
                            "otDepth": nil,
                            "tide": 1,
                            "maxVesselLength": nil,
                            "maxVesselBeam": nil,
                            "maxVesselDraft": nil,
                            "goodHoldingGround": "U",
                            "turningArea": "Y",
                            "firstPortOfEntry": "Y",
                            "usRep": "N",
                            "ptCompulsory": "Y",
                            "ptAvailable": nil,
                            "ptLocalAssist": nil,
                            "ptAdvisable": "Y",
                            "tugsSalvage": "N",
                            "tugsAssist": "Y",
                            "qtPratique": "Y",
                            "qtOther": "U",
                            "cmTelephone": "Y",
                            "cmTelegraph": "Y",
                            "cmRadio": "Y",
                            "cmRadioTel": "U",
                            "cmAir": "Y",
                            "cmRail": "U",
                            "loWharves": "Y",
                            "loAnchor": "U",
                            "loMedMoor": "U",
                            "loBeachMoor": "U",
                            "loIceMoor": "U",
                            "medFacilities": "Y",
                            "garbageDisposal": "U",
                            "degauss": "U",
                            "dirtyBallast": "N",
                            "crFixed": "U",
                            "crMobile": "Y",
                            "crFloating": "Y",
                            "lifts100": "Y",
                            "lifts50": "U",
                            "lifts25": "U",
                            "lifts0": "Y",
                            "srLongshore": "Y",
                            "srElectrical": "U",
                            "srSteam": "U",
                            "srNavigEquip": "U",
                            "srElectRepair": "U",
                            "suProvisions": "U",
                            "suWater": "Y",
                            "suFuel": "Y",
                            "suDiesel": "Y",
                            "suDeck": "U",
                            "suEngine": "U",
                            "repairCode": "C",
                            "drydock": "S",
                            "railway": "S",
                            "qtSanitation": "Y",
                            "suAviationFuel": "U",
                            "harborUse": "UNK",
                            "ukcMgmtSystem": "U",
                            "portSecurity": "U",
                            "etaMessage": "Y",
                            "searchAndRescue": "U",
                            "tss": "U",
                            "vts": "U",
                            "cht": "U",
                            "globalId": "{361E3AAE-91D3-4564-B99A-A14B52D7E21B}",
                            "loRoro": "U",
                            "loSolidBulk": "U",
                            "loContainer": "U",
                            "loBreakBulk": "U",
                            "loOilTerm": "U",
                            "loLongTerm": "U",
                            "loOther": "U",
                            "loDangCargo": "U",
                            "loLiquidBulk": "U",
                            "srIceBreaking": "U",
                            "srDiving": "U",
                            "cranesContainer": "U",
                            "unloCode": "IR ABD",
                            "dnc": "coa10n, gen10a, h1048385",
                            "s121WaterBody": "",
                            "s57Enc": nil,
                            "s101Enc": "",
                            "dodWaterBody": "Persian Gulf; Indian Ocean",
                            "alternateName": nil,
                            "entranceWidth": nil,
                            "lngTerminalDepth": nil,
                            "offMaxVesselLength": nil,
                            "offMaxVesselBeam": nil,
                            "offMaxVesselDraft": nil,
                            "ycoord": 30.33333300000004,
                            "xcoord": 48.28333300000003
                        ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Port.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Marlin.Port.decodableRoot, dataType: Marlin.Port.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidPortNoLongitude() throws {
        for seedDataFile in Port.seedDataFiles ?? [] {
            stub(condition: isScheme("file") && pathEndsWith("\(seedDataFile).json")) { request in
                let jsonObject = [
                        "ports": [
                            [
                                "portNumber": 760,
                                "portName": "Aasiaat",
                                "regionNumber": 545,
                                "regionName": "GREENLAND  WEST COAST",
                                "countryCode": "GL",
                                "countryName": "Greenland",
                                "latitude": "68°42'00\"N",
                                "longitude": "52°52'00\"W",
                                "publicationNumber": "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland",
                                "chartNumber": nil,
                                "navArea": "XVIII",
                                "harborSize": "S",
                                "harborType": "CN",
                                "shelter": "G",
                                "erTide": "N",
                                "erSwell": "N",
                                "erIce": "Y",
                                "erOther": "Y",
                                "overheadLimits": "U",
                                "chDepth": "23",
                                "anDepth": "23",
                                "cpDepth": "8",
                                "otDepth": nil,
                                "tide": 3,
                                "maxVesselLength": nil,
                                "maxVesselBeam": nil,
                                "maxVesselDraft": nil,
                                "goodHoldingGround": "N",
                                "turningArea": "U",
                                "firstPortOfEntry": "N",
                                "usRep": "N",
                                "ptCompulsory": "N",
                                "ptAvailable": nil,
                                "ptLocalAssist": nil,
                                "ptAdvisable": "Y",
                                "tugsSalvage": "N",
                                "tugsAssist": "N",
                                "qtPratique": "U",
                                "qtOther": "U",
                                "cmTelephone": "U",
                                "cmTelegraph": "U",
                                "cmRadio": "Y",
                                "cmRadioTel": "U",
                                "cmAir": "Y",
                                "cmRail": "U",
                                "loWharves": "Y",
                                "loAnchor": "U",
                                "loMedMoor": "U",
                                "loBeachMoor": "U",
                                "loIceMoor": "U",
                                "medFacilities": "Y",
                                "garbageDisposal": "N",
                                "degauss": "U",
                                "dirtyBallast": "N",
                                "crFixed": "U",
                                "crMobile": "Y",
                                "crFloating": "U",
                                "lifts100": "U",
                                "lifts50": "U",
                                "lifts25": "U",
                                "lifts0": "Y",
                                "srLongshore": "U",
                                "srElectrical": "U",
                                "srSteam": "U",
                                "srNavigEquip": "U",
                                "srElectRepair": "U",
                                "suProvisions": "Y",
                                "suWater": "Y",
                                "suFuel": "Y",
                                "suDiesel": "U",
                                "suDeck": "U",
                                "suEngine": "U",
                                "repairCode": "C",
                                "drydock": "U",
                                "railway": "S",
                                "qtSanitation": "U",
                                "suAviationFuel": "U",
                                "harborUse": "UNK",
                                "ukcMgmtSystem": "U",
                                "portSecurity": "U",
                                "etaMessage": "Y",
                                "searchAndRescue": "U",
                                "tss": "U",
                                "vts": "U",
                                "cht": "U",
                                "globalId": "{2C117765-0922-4542-A2B9-333253552952}",
                                "loRoro": "U",
                                "loSolidBulk": "U",
                                "loContainer": "U",
                                "loBreakBulk": "U",
                                "loOilTerm": "U",
                                "loLongTerm": "U",
                                "loOther": "U",
                                "loDangCargo": "U",
                                "loLiquidBulk": "U",
                                "srIceBreaking": "U",
                                "srDiving": "U",
                                "cranesContainer": "U",
                                "unloCode": "GL JEG",
                                "dnc": "a2800670, coa28e, gen28b, h2800670",
                                "s121WaterBody": "",
                                "s57Enc": nil,
                                "s101Enc": "",
                                "dodWaterBody": "Baffin Bay; Arctic Ocean",
                                "alternateName": "Egedesminde",
                                "entranceWidth": nil,
                                "lngTerminalDepth": nil,
                                "offMaxVesselLength": nil,
                                "offMaxVesselBeam": nil,
                                "offMaxVesselDraft": nil,
                                "ycoord": nil,
                                "xcoord": -52.86666699999995
                            ],
                            [
                                "portNumber": 48430,
                                "portName": "Abadan",
                                "regionNumber": 48410,
                                "regionName": "IRAN",
                                "countryCode": "IR",
                                "countryName": "Iran",
                                "latitude": "30°20'00\"N",
                                "longitude": "48°17'00\"E",
                                "publicationNumber": "Sailing Directions Pub. 172 (Enroute) - Red Sea and the Persian Gulf",
                                "chartNumber": "62594",
                                "navArea": "IX",
                                "harborSize": "M",
                                "harborType": "RN",
                                "shelter": "G",
                                "erTide": "Y",
                                "erSwell": "N",
                                "erIce": "N",
                                "erOther": "Y",
                                "overheadLimits": "U",
                                "chDepth": "9",
                                "anDepth": "9",
                                "cpDepth": "9",
                                "otDepth": nil,
                                "tide": 1,
                                "maxVesselLength": nil,
                                "maxVesselBeam": nil,
                                "maxVesselDraft": nil,
                                "goodHoldingGround": "U",
                                "turningArea": "Y",
                                "firstPortOfEntry": "Y",
                                "usRep": "N",
                                "ptCompulsory": "Y",
                                "ptAvailable": nil,
                                "ptLocalAssist": nil,
                                "ptAdvisable": "Y",
                                "tugsSalvage": "N",
                                "tugsAssist": "Y",
                                "qtPratique": "Y",
                                "qtOther": "U",
                                "cmTelephone": "Y",
                                "cmTelegraph": "Y",
                                "cmRadio": "Y",
                                "cmRadioTel": "U",
                                "cmAir": "Y",
                                "cmRail": "U",
                                "loWharves": "Y",
                                "loAnchor": "U",
                                "loMedMoor": "U",
                                "loBeachMoor": "U",
                                "loIceMoor": "U",
                                "medFacilities": "Y",
                                "garbageDisposal": "U",
                                "degauss": "U",
                                "dirtyBallast": "N",
                                "crFixed": "U",
                                "crMobile": "Y",
                                "crFloating": "Y",
                                "lifts100": "Y",
                                "lifts50": "U",
                                "lifts25": "U",
                                "lifts0": "Y",
                                "srLongshore": "Y",
                                "srElectrical": "U",
                                "srSteam": "U",
                                "srNavigEquip": "U",
                                "srElectRepair": "U",
                                "suProvisions": "U",
                                "suWater": "Y",
                                "suFuel": "Y",
                                "suDiesel": "Y",
                                "suDeck": "U",
                                "suEngine": "U",
                                "repairCode": "C",
                                "drydock": "S",
                                "railway": "S",
                                "qtSanitation": "Y",
                                "suAviationFuel": "U",
                                "harborUse": "UNK",
                                "ukcMgmtSystem": "U",
                                "portSecurity": "U",
                                "etaMessage": "Y",
                                "searchAndRescue": "U",
                                "tss": "U",
                                "vts": "U",
                                "cht": "U",
                                "globalId": "{361E3AAE-91D3-4564-B99A-A14B52D7E21B}",
                                "loRoro": "U",
                                "loSolidBulk": "U",
                                "loContainer": "U",
                                "loBreakBulk": "U",
                                "loOilTerm": "U",
                                "loLongTerm": "U",
                                "loOther": "U",
                                "loDangCargo": "U",
                                "loLiquidBulk": "U",
                                "srIceBreaking": "U",
                                "srDiving": "U",
                                "cranesContainer": "U",
                                "unloCode": "IR ABD",
                                "dnc": "coa10n, gen10a, h1048385",
                                "s121WaterBody": "",
                                "s57Enc": nil,
                                "s101Enc": "",
                                "dodWaterBody": "Persian Gulf; Indian Ocean",
                                "alternateName": nil,
                                "entranceWidth": nil,
                                "lngTerminalDepth": nil,
                                "offMaxVesselLength": nil,
                                "offMaxVesselBeam": nil,
                                "offMaxVesselDraft": nil,
                                "ycoord": 30.33333300000004,
                                "xcoord": 48.28333300000003
                            ]
                    ]
                ]
                return HTTPStubsResponse(jsonObject: jsonObject, statusCode: 200, headers: ["Content-Type":"application/json"])
            }
        }
        
        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[Port.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .NSManagedObjectContextDidSave, object: nil) { notification in
            let count = try? self.persistentStore.countOfObjects(Port.self)
            XCTAssertEqual(count, 1)
            return true
        }
        
        MSI.shared.loadInitialData(type: Marlin.Port.decodableRoot, dataType: Marlin.Port.self)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        let requests = Port.dataRequest()
        XCTAssertEqual(requests.count, 1)
        let request = requests[0]
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 1)
        XCTAssertEqual(parameters?["output"] as? String, "json")
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(Port.key)DataSourceEnabled")
        XCTAssertFalse(Port.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(Port.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(Port.key)LastSyncTime")
        XCTAssertTrue(Port.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(Port.key)LastSyncTime")
        XCTAssertFalse(Port.shouldSync())
    }
    
}
