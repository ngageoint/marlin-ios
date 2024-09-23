//
//  PortDetailViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

@MainActor
final class PortDetailViewTests: XCTestCase {

    func testLoading() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        print("XXX This test is failing in iOS18")
        var port = PortModel(portNumber: 760)
        port.portName = "Aasiaat"
        port.regionNumber = 54
        port.regionName = "GREENLAND  WEST COAST"
        port.countryCode = "GL"
        port.countryName = "Greenland"
        port.latitude = 1.0
        port.longitude = 2.0
        port.publicationNumber = "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland"
        port.chartNumber = "15"
        port.navArea = "XVIII"
        port.harborSize = "S"
        port.harborType = "CN"
        port.shelter = "G"
        port.erTide = "N"
        port.erSwell = "N"
        port.erIce = "Y"
        port.erOther = "Y"
        port.overheadLimits = "U"
        port.channelDepth = 1
        port.anchorageDepth = 2
        port.cargoPierDepth = 3
        port.oilTerminalDepth = 4
        port.tide = 5
        port.maxVesselLength = 6
        port.maxVesselBeam = 7
        port.maxVesselDraft = 8
        port.goodHoldingGround = "N"
        port.turningArea = "U"
        port.firstPortOfEntry = "N"
        port.usRep = "N"
        port.ptCompulsory = "N"
        port.ptAvailable = "Y"
        port.ptLocalAssist = "N"
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
        port.dodWaterBody = "dodWaterBody"
        port.s57Enc = "s57Enc"
        port.s101Enc = "s101Enc"
        port.dodWaterBody = "Baffin Bay; Arctic Ocean"
        port.alternateName = "Egedesminde"
        port.entranceWidth = 9
        port.liquifiedNaturalGasTerminalDepth = 10
        port.offshoreMaxVesselLength = 11
        port.offshoreMaxVesselBeam = 12
        port.offshoreMaxVesselDraft = 13
        port.latitude = 1.0
        port.longitude = 2.0

        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let localDataSource = PortStaticLocalDataSource()
        let remoteDataSource = PortRemoteDataSourceImpl()
        InjectedValues[\.portLocalDataSource] = localDataSource
        InjectedValues[\.portRemoteDataSource] = remoteDataSource
        localDataSource.list = [port]
        let repository = PortRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let router = MarlinRouter()
        let detailView = await PortDetailView(portNumber: 760)
            .environmentObject(mockLocationManager as LocationManager)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: port.portName)
        tester().waitForView(withAccessibilityLabel: "Alternate Name: \(port.alternateName ?? "")")
        tester().waitForView(withAccessibilityLabel: port.regionName)
        
        // name and location
        tester().waitForView(withAccessibilityLabel: "World Port Index Number")
        tester().waitForView(withAccessibilityLabel: "Region Name")
        tester().waitForView(withAccessibilityLabel: "Main Port Name")
        tester().waitForView(withAccessibilityLabel: "Alternate Port Name")
        tester().waitForView(withAccessibilityLabel: "UN/LOCODE")
        tester().waitForView(withAccessibilityLabel: "Country")
        tester().waitForView(withAccessibilityLabel: "World Water Body")
        tester().waitForView(withAccessibilityLabel: "Sailing Directions or Publication")
        tester().waitForView(withAccessibilityLabel: "Standard Nautical Chart")
        tester().waitForView(withAccessibilityLabel: "IHO S-57 Electronic Navigational Chart")
        tester().waitForView(withAccessibilityLabel: "IHO S-101 Electronic Navigational Chart")
        tester().waitForView(withAccessibilityLabel: "Digital Nautical Chart")
        
        // depth
        tester().waitForView(withAccessibilityLabel: "Tidal Range (m)")
        tester().waitForView(withAccessibilityLabel: "Entrance Width (m)")
        tester().waitForView(withAccessibilityLabel: "Channel Depth (m)")
        tester().waitForView(withAccessibilityLabel: "Anchorage Depth (m)")
        tester().waitForView(withAccessibilityLabel: "Cargo Pier Depth (m)")
        tester().waitForView(withAccessibilityLabel: "Oil Terminal Depth (m)")
        tester().waitForView(withAccessibilityLabel: "Liquified Natural Gas Terminal Depth (m)")
        
        // max vessel
        tester().waitForView(withAccessibilityLabel: "Maximum Vessel Length (m)")
        tester().waitForView(withAccessibilityLabel: "Maximum Vessel Beam (m)")
        tester().waitForView(withAccessibilityLabel: "Maximum Vessel Draft (m)")
        tester().waitForView(withAccessibilityLabel: "Offshore Maximum Vessel Length (m)")
        tester().waitForView(withAccessibilityLabel: "Offshore Maximum Vessel Beam (m)")
        tester().waitForView(withAccessibilityLabel: "Offshore Maximum Vessel Draft (m)")
        
        // physical environment
        tester().waitForView(withAccessibilityLabel: "Harbor Size")
        tester().waitForView(withAccessibilityLabel: "Harbor Type")
        tester().waitForView(withAccessibilityLabel: "Harbor Use")
        tester().waitForView(withAccessibilityLabel: "Shelter")
        tester().waitForView(withAccessibilityLabel: "Entrance Restriction - Tide")
        tester().waitForView(withAccessibilityLabel: "Entrance Restriction - Heavy Swell")
        tester().waitForView(withAccessibilityLabel: "Entrance Restriction - Ice")
        tester().waitForView(withAccessibilityLabel: "Entrance Restriction - Other")
        tester().waitForView(withAccessibilityLabel: "Overhead Limits")
        tester().waitForView(withAccessibilityLabel: "Underkeel Clearance Management System")
        tester().waitForView(withAccessibilityLabel: "Good Holding Ground")
        tester().waitForView(withAccessibilityLabel: "Turning Area")
        
        // approach
        tester().waitForView(withAccessibilityLabel: "Port Security")
        tester().waitForView(withAccessibilityLabel: "Estimated Time Of Arrival Message")
        tester().waitForView(withAccessibilityLabel: "Quarantine - Pratique")
        tester().waitForView(withAccessibilityLabel: "Quarantine - Sanitation")
        tester().waitForView(withAccessibilityLabel: "Quarantine - Other")
        tester().waitForView(withAccessibilityLabel: "Traffic Separation Scheme")
        tester().waitForView(withAccessibilityLabel: "Vessel Traffic Service")
        tester().waitForView(withAccessibilityLabel: "First Port Of Entry")
        
        // pilots tugs communications
        tester().waitForView(withAccessibilityLabel: "Pilotage - Compulsory")
        tester().waitForView(withAccessibilityLabel: "Pilotage - Available")
        tester().waitForView(withAccessibilityLabel: "Pilotage - Local Assistance")
        tester().waitForView(withAccessibilityLabel: "Pilotage - Advisable")
        tester().waitForView(withAccessibilityLabel: "Tugs - Salvage")
        tester().waitForView(withAccessibilityLabel: "Tugs - Assistance")
        tester().waitForView(withAccessibilityLabel: "Communications - Telephone")
        tester().waitForView(withAccessibilityLabel: "Communications - Telefax")
        tester().waitForView(withAccessibilityLabel: "Communications - Radio")
        tester().waitForView(withAccessibilityLabel: "Communications - Radiotelephone")
        tester().waitForView(withAccessibilityLabel: "Communications - Airport")
        tester().waitForView(withAccessibilityLabel: "Communications - Rail")
        tester().waitForView(withAccessibilityLabel: "Search and Rescue")
        tester().waitForView(withAccessibilityLabel: "NAVAREA")
        
        // facilities
        tester().waitForView(withAccessibilityLabel: "Facilities - Wharves")
        tester().waitForView(withAccessibilityLabel: "Facilities - Anchorage")
        tester().waitForView(withAccessibilityLabel: "Facilities - Dangerous Cargo Anchorage")
        tester().waitForView(withAccessibilityLabel: "Facilities - Med Mooring")
        tester().waitForView(withAccessibilityLabel: "Facilities - Beach Mooring")
        tester().waitForView(withAccessibilityLabel: "Facilities - Ice Mooring")
        tester().waitForView(withAccessibilityLabel: "Facilities - RoRo")
        tester().waitForView(withAccessibilityLabel: "Facilities - Solid Bulk")
        tester().waitForView(withAccessibilityLabel: "Facilities - Liquid Bulk")
        tester().waitForView(withAccessibilityLabel: "Facilities - Container")
        tester().waitForView(withAccessibilityLabel: "Facilities - Breakbulk")
        tester().waitForView(withAccessibilityLabel: "Facilities - Oil Terminal")
        tester().waitForView(withAccessibilityLabel: "Facilities - LNG Terminal")
        tester().waitForView(withAccessibilityLabel: "Facilities - Other")
        tester().waitForView(withAccessibilityLabel: "Medical Facilities")
        tester().waitForView(withAccessibilityLabel: "Garbage Disposal")
        tester().waitForView(withAccessibilityLabel: "Chemical Holding Tank Disposal")
        tester().waitForView(withAccessibilityLabel: "Degaussing")
        tester().waitForView(withAccessibilityLabel: "Dirty Ballast Disposal")
        
        // cranes
        tester().waitForView(withAccessibilityLabel: "Cranes - Fixed")
        tester().waitForView(withAccessibilityLabel: "Cranes - Mobile")
        tester().waitForView(withAccessibilityLabel: "Cranes - Floating")
        tester().waitForView(withAccessibilityLabel: "Cranes - Container")
        tester().waitForView(withAccessibilityLabel: "Lifts - 100+ Tons")
        tester().waitForView(withAccessibilityLabel: "Lifts - 50-100 Tons")
        tester().waitForView(withAccessibilityLabel: "Lifts - 25-49 Tons")
        tester().waitForView(withAccessibilityLabel: "Lifts - 0-24 Tons")
        
        // services
        tester().waitForView(withAccessibilityLabel: "Services - Longshoremen")
        tester().waitForView(withAccessibilityLabel: "Services - Electricity")
        tester().waitForView(withAccessibilityLabel: "Services - Steam")
        tester().waitForView(withAccessibilityLabel: "Services - Navigational Equipment")
        tester().waitForView(withAccessibilityLabel: "Services - Electrical Repair")
        tester().waitForView(withAccessibilityLabel: "Services - Ice Breaking")
        tester().waitForView(withAccessibilityLabel: "Services - Diving")
        tester().waitForView(withAccessibilityLabel: "Supplies - Provisions")
        tester().waitForView(withAccessibilityLabel: "Supplies - Potable Water")
        tester().waitForView(withAccessibilityLabel: "Supplies - Fuel Oil")
        tester().waitForView(withAccessibilityLabel: "Supplies - Diesel Oil")
        tester().waitForView(withAccessibilityLabel: "Supplies - Aviation Fuel")
        tester().waitForView(withAccessibilityLabel: "Supplies - Deck")
        tester().waitForView(withAccessibilityLabel: "Supplies - Engine")
        tester().waitForView(withAccessibilityLabel: "Repair Code")
        tester().waitForView(withAccessibilityLabel: "Dry Dock")
        tester().waitForView(withAccessibilityLabel: "Railway")
    }

    func xtestButtons() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var port = PortModel(portNumber: 760)
        port.portName = "Aasiaat"
        port.regionNumber = 54
        port.regionName = "GREENLAND  WEST COAST"
        port.countryCode = "GL"
        port.countryName = "Greenland"
        port.latitude = 1.0
        port.longitude = 2.0
        port.publicationNumber = "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland"
        port.chartNumber = "15"
        port.navArea = "XVIII"
        port.harborSize = "S"
        port.harborType = "CN"
        port.shelter = "G"
        port.erTide = "N"
        port.erSwell = "N"
        port.erIce = "Y"
        port.erOther = "Y"
        port.overheadLimits = "U"
        port.channelDepth = 1
        port.anchorageDepth = 2
        port.cargoPierDepth = 3
        port.oilTerminalDepth = 4
        port.tide = 5
        port.maxVesselLength = 6
        port.maxVesselBeam = 7
        port.maxVesselDraft = 8
        port.goodHoldingGround = "N"
        port.turningArea = "U"
        port.firstPortOfEntry = "N"
        port.usRep = "N"
        port.ptCompulsory = "N"
        port.ptAvailable = "Y"
        port.ptLocalAssist = "N"
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
        port.dodWaterBody = "dodWaterBody"
        port.s57Enc = "s57Enc"
        port.s101Enc = "s101Enc"
        port.dodWaterBody = "Baffin Bay; Arctic Ocean"
        port.alternateName = "Egedesminde"
        port.entranceWidth = 9
        port.liquifiedNaturalGasTerminalDepth = 10
        port.offshoreMaxVesselLength = 11
        port.offshoreMaxVesselBeam = 12
        port.offshoreMaxVesselDraft = 13
        port.latitude = 1.0
        port.longitude = 2.0

        let mockCLLocation = MockCLLocationManager()
        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
        let localDataSource = PortStaticLocalDataSource()
        let remoteDataSource = PortRemoteDataSourceImpl()
        InjectedValues[\.portLocalDataSource] = localDataSource
        InjectedValues[\.portRemoteDataSource] = remoteDataSource
        localDataSource.list = [port]
        let repository = PortRepository()
        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let router = MarlinRouter()
        let detailView = await PortDetailView(portNumber: 760)
            .environmentObject(mockLocationManager as LocationManager)

        let controller = await UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
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
            let port = tapNotification.items as! [PortModel]
            XCTAssertEqual(port.count, 1)
            XCTAssertEqual(port[0].portNumber, 760)
            return true
        }
        tester().tapView(withAccessibilityLabel: "focus")

        waitForExpectations(timeout: 10, handler: nil)

        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")

        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
    }
}
