//
//  PortSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class PortSummaryViewTests: XCTestCase {
    
    func testLoading() {
        var port = PortModel(portNumber: 760)
            port.portName = "Aasiaat"
            port.regionNumber = 54
            port.regionName = "GREENLAND  WEST COAST"
            port.countryCode = "GL"
            port.countryName = "Greenland"
            port.latitude = 1.0
            port.longitude = 2.0
            port.publicationNumber = "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland"
            port.chartNumber = nil
            port.navArea = "XVIII"
            port.harborSize = "S"
            port.harborType = "CN"
            port.shelter = "G"
            port.erTide = "N"
            port.erSwell = "N"
            port.erIce = "Y"
            port.erOther = "Y"
            port.overheadLimits = "U"
            port.channelDepth = 23
            port.anchorageDepth = 23
            port.cargoPierDepth = 8
            port.oilTerminalDepth = 1
            port.tide = 3
            port.maxVesselLength = 2
            port.maxVesselBeam = 3
            port.maxVesselDraft = 4
            port.goodHoldingGround = "N"
            port.turningArea = "U"
            port.firstPortOfEntry = "N"
            port.usRep = "N"
            port.ptCompulsory = "N"
            port.ptAvailable = nil
            port.ptLocalAssist = nil
            port.ptAdvisable = "Y"
            port.tugsSalvage = "N"
            port.tugsAssist = "N"
            port.qtPratique = "U"
            port.qtOther = "U"
            port.cmTelephone = "U"
            port.cmTelegraph = "U"
            port.cmRadio = "Y"
            port.cmRadioTel = "U"
            port.cmAir = "Y"
            port.cmRail = "U"
            port.loWharves = "Y"
            port.loAnchor = "U"
            port.loMedMoor = "U"
            port.loBeachMoor = "U"
            port.loIceMoor = "U"
            port.medFacilities = "Y"
            port.garbageDisposal = "N"
            port.degauss = "U"
            port.dirtyBallast = "N"
            port.craneFixed = "U"
            port.craneMobile = "Y"
            port.craneFloating = "U"
            port.lifts100 = "U"
            port.lifts50 = "U"
            port.lifts25 = "U"
            port.lifts0 = "Y"
            port.srLongshore = "U"
            port.srElectrical = "U"
            port.srSteam = "U"
            port.srNavigationalEquipment = "U"
            port.srElectricalRepair = "U"
            port.suProvisions = "Y"
            port.suWater = "Y"
            port.suFuel = "Y"
            port.suDiesel = "U"
            port.suDeck = "U"
            port.suEngine = "U"
            port.repairCode = "C"
            port.drydock = "U"
            port.railway = "S"
            port.qtSanitation = "U"
            port.suAviationFuel = "U"
            port.harborUse = "UNK"
            port.ukcMgmtSystem = "U"
            port.portSecurity = "U"
            port.etaMessage = "Y"
            port.searchAndRescue = "U"
            port.trafficSeparationScheme = "U"
            port.vesselTrafficService = "U"
            port.chemicalHoldingTank = "U"
            port.globalId = "{2C117765-0922-4542-A2B9-333253552952}"
            port.loRoro = "U"
            port.loSolidBulk = "U"
            port.loContainer = "U"
            port.loBreakBulk = "U"
            port.loOilTerm = "U"
            port.loLongTerm = "U"
            port.loOther = "U"
            port.loDangCargo = "U"
            port.loLiquidBulk = "U"
            port.srIceBreaking = "U"
            port.srDiving = "U"
            port.craneContainer = "U"
            port.unloCode = "GL JEG"
            port.dnc = "a2800670, coa28e, gen28b, h2800670"
            port.dodWaterBody = ""
            port.s57Enc = nil
            port.s101Enc = ""
            port.dodWaterBody = "Baffin Bay; Arctic Ocean"
            port.alternateName = "Egedesminde"
            port.entranceWidth = 4
            port.liquifiedNaturalGasTerminalDepth = 5
            port.offshoreMaxVesselLength = 6
            port.offshoreMaxVesselBeam = 7
            port.offshoreMaxVesselDraft = 8
            port.latitude = 1.0
            port.longitude = 2.0
        port.canBookmark = true

        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let localDataSource = PortStaticLocalDataSource()
        localDataSource.list = [port]
        let repository = PortRepository(localDataSource: localDataSource, remoteDataSource: PortRemoteDataSource())
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource, portRepository: repository)
        let router = MarlinRouter()
        let summary = PortSummaryView(port: PortListModel(portModel:port))
            .setShowMoreDetails(false)
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: port.portName)
        tester().waitForView(withAccessibilityLabel: "Alternate Name: \(port.alternateName ?? "")")
        tester().waitForView(withAccessibilityLabel: port.regionName)
        
        expectation(forNotification: .SnackbarNotification,
                    object: nil) { notification in
            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: port.coordinate)) copied to clipboard")
            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: port.coordinate))")
            return true
        }
        tester().tapView(withAccessibilityLabel: "Location")
        
        expectation(forNotification: .TabRequestFocus,
                    object: nil) { notification in
            return true
        }
        
        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
            let portKeys = tapNotification.itemKeys!

            let ports = portKeys[DataSources.port.key]!

            XCTAssertEqual(ports.count, 1)
            XCTAssertEqual(ports[0], port.itemKey)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")
        
        waitForExpectations(timeout: 10, handler: nil)
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkRepository, bookmarkable: port)

        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")
        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapView(withAccessibilityLabel: "dismiss popup")
    }
    
    func testShowMoreDetails() {
        var port = PortModel(portNumber: 760)
        port.portName = "Aasiaat"
        port.regionNumber = 54
        port.regionName = "GREENLAND  WEST COAST"
        port.countryCode = "GL"
        port.countryName = "Greenland"
        port.latitude = 1.0
        port.longitude = 2.0
        port.publicationNumber = "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland"
        port.chartNumber = nil
        port.navArea = "XVIII"
        port.harborSize = "S"
        port.harborType = "CN"
        port.shelter = "G"
        port.erTide = "N"
        port.erSwell = "N"
        port.erIce = "Y"
        port.erOther = "Y"
        port.overheadLimits = "U"
        port.channelDepth = 23
        port.anchorageDepth = 23
        port.cargoPierDepth = 8
        port.oilTerminalDepth = 1
        port.tide = 3
        port.maxVesselLength = 2
        port.maxVesselBeam = 3
        port.maxVesselDraft = 4
        port.goodHoldingGround = "N"
        port.turningArea = "U"
        port.firstPortOfEntry = "N"
        port.usRep = "N"
        port.ptCompulsory = "N"
        port.ptAvailable = nil
        port.ptLocalAssist = nil
        port.ptAdvisable = "Y"
        port.tugsSalvage = "N"
        port.tugsAssist = "N"
        port.qtPratique = "U"
        port.qtOther = "U"
        port.cmTelephone = "U"
        port.cmTelegraph = "U"
        port.cmRadio = "Y"
        port.cmRadioTel = "U"
        port.cmAir = "Y"
        port.cmRail = "U"
        port.loWharves = "Y"
        port.loAnchor = "U"
        port.loMedMoor = "U"
        port.loBeachMoor = "U"
        port.loIceMoor = "U"
        port.medFacilities = "Y"
        port.garbageDisposal = "N"
        port.degauss = "U"
        port.dirtyBallast = "N"
        port.craneFixed = "U"
        port.craneMobile = "Y"
        port.craneFloating = "U"
        port.lifts100 = "U"
        port.lifts50 = "U"
        port.lifts25 = "U"
        port.lifts0 = "Y"
        port.srLongshore = "U"
        port.srElectrical = "U"
        port.srSteam = "U"
        port.srNavigationalEquipment = "U"
        port.srElectricalRepair = "U"
        port.suProvisions = "Y"
        port.suWater = "Y"
        port.suFuel = "Y"
        port.suDiesel = "U"
        port.suDeck = "U"
        port.suEngine = "U"
        port.repairCode = "C"
        port.drydock = "U"
        port.railway = "S"
        port.qtSanitation = "U"
        port.suAviationFuel = "U"
        port.harborUse = "UNK"
        port.ukcMgmtSystem = "U"
        port.portSecurity = "U"
        port.etaMessage = "Y"
        port.searchAndRescue = "U"
        port.trafficSeparationScheme = "U"
        port.vesselTrafficService = "U"
        port.chemicalHoldingTank = "U"
        port.globalId = "{2C117765-0922-4542-A2B9-333253552952}"
        port.loRoro = "U"
        port.loSolidBulk = "U"
        port.loContainer = "U"
        port.loBreakBulk = "U"
        port.loOilTerm = "U"
        port.loLongTerm = "U"
        port.loOther = "U"
        port.loDangCargo = "U"
        port.loLiquidBulk = "U"
        port.srIceBreaking = "U"
        port.srDiving = "U"
        port.craneContainer = "U"
        port.unloCode = "GL JEG"
        port.dnc = "a2800670, coa28e, gen28b, h2800670"
        port.dodWaterBody = ""
        port.s57Enc = nil
        port.s101Enc = ""
        port.dodWaterBody = "Baffin Bay; Arctic Ocean"
        port.alternateName = "Egedesminde"
        port.entranceWidth = 4
        port.liquifiedNaturalGasTerminalDepth = 5
        port.offshoreMaxVesselLength = 6
        port.offshoreMaxVesselBeam = 7
        port.offshoreMaxVesselDraft = 8
        port.latitude = 1.0
        port.longitude = 2.0
        port.canBookmark = true

        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let localDataSource = PortStaticLocalDataSource()
        localDataSource.list = [port]
        let repository = PortRepository(localDataSource: localDataSource, remoteDataSource: PortRemoteDataSource())
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource, portRepository: repository)
        let router = MarlinRouter()
        let summary = PortSummaryView(port: PortListModel(portModel:port))
            .setShowMoreDetails(true)
            .environmentObject(mockLocationManager as LocationManager)
            .environmentObject(repository)
            .environmentObject(bookmarkRepository)
            .environmentObject(router)

        let controller = UIHostingController(rootView: summary)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: port.portName)

        XCTAssertEqual(router.path.count, 0)
        tester().tapView(withAccessibilityLabel: "More Details")
        XCTAssertEqual(router.path.count, 1)

        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkRepository, bookmarkable: port)
    }

}
