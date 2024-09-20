//
//  PortRepositoryTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/14/24.
//

import XCTest
import Combine
import CoreData
import OHHTTPStubs

@testable import Marlin

final class PortRepositoryTests: XCTestCase {

    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()

        UserDefaults.standard.initialDataLoaded = false
        UserDefaults.standard.clearLastSyncTimeSeconds(DataSources.port)
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)

        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
    }

    override func tearDown() {
    }

    func testFetch() async {
        var models: [PortModel] = []
        let portData: [[String: AnyHashable?]] = [
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
                "xcoord": 48.28333300000003
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

        let jsonData = try! JSONSerialization.data(withJSONObject: portData)
        let decoded: [PortModel] = try! JSONDecoder().decode([PortModel].self, from: jsonData)

        models.append(contentsOf: decoded)

        let loadingExpectation = expectation(forNotification: .DataSourceLoading,
                                             object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
                XCTAssertTrue(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let loadedExpectation = expectation(forNotification: .DataSourceLoaded,
                                            object: nil) { notification in
            if let loading = MSI.shared.appState.loadingDataSource[DataSources.port.key] {
                XCTAssertFalse(loading)
            } else {
                XCTFail("Loading is not set")
            }
            return true
        }

        let updatedExpectation = expectation(forNotification: .DataSourceUpdated,
                                             object: nil) { notification in
            if let notificationObject = notification.object as? DataSourceUpdatedNotification {
                XCTAssertEqual(notificationObject.key, DataSources.port.key)
                XCTAssertEqual(notificationObject.inserts, 2)
            }
            return true
        }
        let localDataSource = PortStaticLocalDataSource()
        let remoteDataSource = PortStaticRemoteDataSource()
        InjectedValues[\.portLocalDataSource] = localDataSource
        InjectedValues[\.portRemoteDataSource] = remoteDataSource
        await remoteDataSource.setList(models)
        let repository = PortRepository()

        let ports = await repository.fetchPorts()
        XCTAssertEqual(2, ports.count)

        await fulfillment(of: [loadingExpectation, loadedExpectation, updatedExpectation])

        let repoPort = await repository.getPort(portNumber: 760)
        XCTAssertNotNil(repoPort)
        XCTAssertEqual(repoPort, localDataSource.getPort(portNumber: 760))

        let repoPorts = await repository.getPorts(filters: nil)
        let localPorts = await localDataSource.getPorts(filters: nil)
        XCTAssertNotNil(repoPorts)
        XCTAssertEqual(repoPorts.count, localPorts.count)

        let repoCount = await repository.getCount(filters: nil)
        XCTAssertEqual(repoCount, localDataSource.getCount(filters: nil))
    }

    func testCreateOperation() async {
        let localDataSource = PortStaticLocalDataSource()
        let remoteDataSource = PortStaticRemoteDataSource()
        InjectedValues[\.portLocalDataSource] = localDataSource
        InjectedValues[\.portRemoteDataSource] = remoteDataSource
        let repository = PortRepository()
        let operation = await repository.createOperation()
        XCTAssertNotNil(operation)
    }

}
