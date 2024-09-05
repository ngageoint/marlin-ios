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
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.port)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    override func tearDown() {
    }
    
    func testLoadInitialData() throws {

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
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

        expectation(forNotification: .BatchUpdateComplete,
                    object: nil) { notification in
            guard let updatedNotification = notification.object as? BatchUpdateComplete else {
                XCTFail("Incorrect notification")
                return false
            }
            let updates = updatedNotification.dataSourceUpdates
            if updates.isEmpty {
                XCTFail("should be some updates")
                return false
            }
            XCTAssertFalse(updates.isEmpty)
            let update = updates[0]
            XCTAssertEqual(2, update.inserts)
            XCTAssertEqual(0, update.updates)
            return true
        }

        let bundle = MockBundle()
        bundle.mockPath = "portMockData.json"

        let operation = PortInitialDataLoadOperation(localDataSource: PortCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)

    }
    
    func testRejectInvalidPortNoPortNumber() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = PortInitialDataLoadOperation(localDataSource: PortCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidPortNoLatitude() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = PortInitialDataLoadOperation(localDataSource: PortCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRejectInvalidPortNoLongitude() throws {
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

        expectation(forNotification: .DataSourceLoading,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }
        
        expectation(forNotification: .DataSourceLoaded,
                    object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
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
        
        let bundle = MockBundle()
        bundle.tempFileContents = jsonObject

        let operation = PortInitialDataLoadOperation(localDataSource: PortCoreDataDataSource(), bundle: bundle)
        operation.start()

        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testDataRequest() {
        let request = PortService.getPorts
        XCTAssertEqual(request.method, .get)
        let parameters = request.parameters
        XCTAssertEqual(parameters?.count, 1)
        XCTAssertEqual(parameters?["output"] as? String, "json")
    }
    
    func testShouldSync() {
        UserDefaults.standard.setValue(false, forKey: "\(DataSources.port.key)DataSourceEnabled")
        XCTAssertFalse(DataSources.port.shouldSync())
        UserDefaults.standard.setValue(true, forKey: "\(DataSources.port.key)DataSourceEnabled")
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) - 10, forKey: "\(DataSources.port.key)LastSyncTime")
        XCTAssertTrue(DataSources.port.shouldSync())
        UserDefaults.standard.setValue(Date().timeIntervalSince1970 - (60 * 60 * 24 * 7) + (60 * 10), forKey: "\(DataSources.port.key)LastSyncTime")
        XCTAssertFalse(DataSources.port.shouldSync())
    }
    
    func testDescription() {
        let newItem = Port(context: persistentStore.viewContext)
        newItem.portNumber = 5
        
        let description = "Port\n\n" +
        "World Port Index Number: 5\n"
        
        XCTAssertEqual(description, newItem.description)
    }
    
    func testMapImage() {
        let newItem = PortModel(portNumber: 5)

        var circleSize: CGSize = .zero
        var imageSize: CGSize = .zero
        
        for i in 1...18 {
            let image = PortImage(port: newItem)
            let images = image.image(context: nil, zoom: i, tileBounds: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), tileSize: 512.0)
            XCTAssertNotNil(images)
            XCTAssertEqual(images.count, 2)
            XCTAssertGreaterThan(images[0].size.height, circleSize.height)
            XCTAssertGreaterThan(images[0].size.width, circleSize.width)
            circleSize = images[0].size
            XCTAssertGreaterThan(images[0].size.height, imageSize.height)
            XCTAssertGreaterThan(images[0].size.width, imageSize.width)
            imageSize = images[0].size
        }
    }
    
}
