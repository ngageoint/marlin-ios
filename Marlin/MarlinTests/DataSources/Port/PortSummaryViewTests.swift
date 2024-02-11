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
        XCTFail()
    }
//    var cancellable = Set<AnyCancellable>()
//    var persistentStore: PersistentStore = PersistenceController.shared
//    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
//        .receive(on: RunLoop.main)
//    
//    override func setUp(completion: @escaping (Error?) -> Void) {
//        for dataSource in DataSourceDefinitions.allCases {
//            UserDefaults.standard.initialDataLoaded = false
//            UserDefaults.standard.clearLastSyncTimeSeconds(dataSource.definition)
//        }
//        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
//        
//        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
//        persistentStoreLoadedPub
//            .removeDuplicates()
//            .sink { output in
//                completion(nil)
//            }
//            .store(in: &cancellable)
//        persistentStore.reset()
//    }
//    
//    override func tearDown() {
//    }
//    
//    func testLoading() {
//        var savedPort: Marlin.Port?
//        persistentStore.viewContext.performAndWait {
//            let port = Marlin.Port(context: persistentStore.viewContext)
//            port.portNumber = 760
//            port.portName = "Aasiaat"
//            port.regionNumber = 54
//            port.regionName = "GREENLAND  WEST COAST"
//            port.countryCode = "GL"
//            port.countryName = "Greenland"
//            port.latitude = 1.0
//            port.longitude = 2.0
//            port.publicationNumber = "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland"
//            port.chartNumber = nil
//            port.navArea = "XVIII"
//            port.harborSize = "S"
//            port.harborType = "CN"
//            port.shelter = "G"
//            port.erTide = "N"
//            port.erSwell = "N"
//            port.erIce = "Y"
//            port.erOther = "Y"
//            port.overheadLimits = "U"
//            port.channelDepth = 23
//            port.anchorageDepth = 23
//            port.cargoPierDepth = 8
//            port.oilTerminalDepth = 1
//            port.tide = 3
//            port.maxVesselLength = 2
//            port.maxVesselBeam = 3
//            port.maxVesselDraft = 4
//            port.goodHoldingGround = "N"
//            port.turningArea = "U"
//            port.firstPortOfEntry = "N"
//            port.usRep = "N"
//            port.ptCompulsory = "N"
//            port.ptAvailable = nil
//            port.ptLocalAssist = nil
//            port.ptAdvisable = "Y"
//            port.tugsSalvage = "N"
//            port.tugsAssist = "N"
//            port.qtPratique = "U"
//            port.qtOther = "U"
//            port.cmTelephone = "U"
//            port.cmTelegraph = "U"
//            port.cmRadio = "Y"
//            port.cmRadioTel = "U"
//            port.cmAir = "Y"
//            port.cmRail = "U"
//            port.loWharves = "Y"
//            port.loAnchor = "U"
//            port.loMedMoor = "U"
//            port.loBeachMoor = "U"
//            port.loIceMoor = "U"
//            port.medFacilities = "Y"
//            port.garbageDisposal = "N"
//            port.degauss = "U"
//            port.dirtyBallast = "N"
//            port.craneFixed = "U"
//            port.craneMobile = "Y"
//            port.craneFloating = "U"
//            port.lifts100 = "U"
//            port.lifts50 = "U"
//            port.lifts25 = "U"
//            port.lifts0 = "Y"
//            port.srLongshore = "U"
//            port.srElectrical = "U"
//            port.srSteam = "U"
//            port.srNavigationalEquipment = "U"
//            port.srElectricalRepair = "U"
//            port.suProvisions = "Y"
//            port.suWater = "Y"
//            port.suFuel = "Y"
//            port.suDiesel = "U"
//            port.suDeck = "U"
//            port.suEngine = "U"
//            port.repairCode = "C"
//            port.drydock = "U"
//            port.railway = "S"
//            port.qtSanitation = "U"
//            port.suAviationFuel = "U"
//            port.harborUse = "UNK"
//            port.ukcMgmtSystem = "U"
//            port.portSecurity = "U"
//            port.etaMessage = "Y"
//            port.searchAndRescue = "U"
//            port.trafficSeparationScheme = "U"
//            port.vesselTrafficService = "U"
//            port.chemicalHoldingTank = "U"
//            port.globalId = "{2C117765-0922-4542-A2B9-333253552952}"
//            port.loRoro = "U"
//            port.loSolidBulk = "U"
//            port.loContainer = "U"
//            port.loBreakBulk = "U"
//            port.loOilTerm = "U"
//            port.loLongTerm = "U"
//            port.loOther = "U"
//            port.loDangCargo = "U"
//            port.loLiquidBulk = "U"
//            port.srIceBreaking = "U"
//            port.srDiving = "U"
//            port.craneContainer = "U"
//            port.unloCode = "GL JEG"
//            port.dnc = "a2800670, coa28e, gen28b, h2800670"
//            port.dodWaterBody = ""
//            port.s57Enc = nil
//            port.s101Enc = ""
//            port.dodWaterBody = "Baffin Bay; Arctic Ocean"
//            port.alternateName = "Egedesminde"
//            port.entranceWidth = 4
//            port.liquifiedNaturalGasTerminalDepth = 5
//            port.offshoreMaxVesselLength = 6
//            port.offshoreMaxVesselBeam = 7
//            port.offshoreMaxVesselDraft = 8
//            port.latitude = 1.0
//            port.longitude = 2.0
//            
//            try? persistentStore.viewContext.save()
//            savedPort = port
//        }
//        
//        guard let port = savedPort else {
//            XCTFail("Did not save port")
//            return
//        }
//        
//        let repository = PortRepositoryManager(repository: PortCoreDataRepository(context: persistentStore.viewContext))
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        
//        let mockCLLocation = MockCLLocationManager()
//        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
//        let summary = port.summary
//            .setShowMoreDetails(false)
//            .environmentObject(mockLocationManager as LocationManager)
//            .environment(\.managedObjectContext, persistentStore.viewContext)
//            .environmentObject(repository)
//            .environmentObject(bookmarkRepository)
//        
//        let controller = UIHostingController(rootView: summary)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: port.portName)
//        tester().waitForView(withAccessibilityLabel: "Alternate Name: \(port.alternateName ?? "")")
//        tester().waitForView(withAccessibilityLabel: port.regionName)
//        
//        expectation(forNotification: .SnackbarNotification,
//                    object: nil) { notification in
//            let model = try? XCTUnwrap(notification.object as? SnackbarNotification)
//            XCTAssertEqual(model?.snackbarModel?.message, "Location \(UserDefaults.standard.coordinateDisplay.format(coordinate: port.coordinate)) copied to clipboard")
//            XCTAssertEqual(UIPasteboard.general.string, "\(UserDefaults.standard.coordinateDisplay.format(coordinate: port.coordinate))")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "Location")
//        
//        expectation(forNotification: .TabRequestFocus,
//                    object: nil) { notification in
//            return true
//        }
//        
//        expectation(forNotification: .MapItemsTapped, object: nil) { notification in
//            
//            let tapNotification = try! XCTUnwrap(notification.object as? MapItemsTappedNotification)
//            let port = tapNotification.items as! [PortModel]
//            XCTAssertEqual(port.count, 1)
//            XCTAssertEqual(port[0].portName, "Aasiaat")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "focus")
//        
//        waitForExpectations(timeout: 10, handler: nil)
//        
//        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: port)
//        
//        tester().waitForView(withAccessibilityLabel: "share")
//        tester().tapView(withAccessibilityLabel: "share")
//        
//        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
//        tester().tapView(withAccessibilityLabel: "dismiss popup")
//    }
//    
//    func testShowMoreDetails() {
//        let port = Port(context: persistentStore.viewContext)
//        port.portNumber = 760
//        port.portName = "Aasiaat"
//        port.regionNumber = 54
//        port.regionName = "GREENLAND  WEST COAST"
//        port.countryCode = "GL"
//        port.countryName = "Greenland"
//        port.latitude = 1.0
//        port.longitude = 2.0
//        port.publicationNumber = "Sailing Directions Pub. 181 (Enroute) - Greenland and Iceland"
//        port.chartNumber = nil
//        port.navArea = "XVIII"
//        port.harborSize = "S"
//        port.harborType = "CN"
//        port.shelter = "G"
//        port.erTide = "N"
//        port.erSwell = "N"
//        port.erIce = "Y"
//        port.erOther = "Y"
//        port.overheadLimits = "U"
//        port.channelDepth = 23
//        port.anchorageDepth = 23
//        port.cargoPierDepth = 8
//        port.oilTerminalDepth = 1
//        port.tide = 3
//        port.maxVesselLength = 2
//        port.maxVesselBeam = 3
//        port.maxVesselDraft = 4
//        port.goodHoldingGround = "N"
//        port.turningArea = "U"
//        port.firstPortOfEntry = "N"
//        port.usRep = "N"
//        port.ptCompulsory = "N"
//        port.ptAvailable = nil
//        port.ptLocalAssist = nil
//        port.ptAdvisable = "Y"
//        port.tugsSalvage = "N"
//        port.tugsAssist = "N"
//        port.qtPratique = "U"
//        port.qtOther = "U"
//        port.cmTelephone = "U"
//        port.cmTelegraph = "U"
//        port.cmRadio = "Y"
//        port.cmRadioTel = "U"
//        port.cmAir = "Y"
//        port.cmRail = "U"
//        port.loWharves = "Y"
//        port.loAnchor = "U"
//        port.loMedMoor = "U"
//        port.loBeachMoor = "U"
//        port.loIceMoor = "U"
//        port.medFacilities = "Y"
//        port.garbageDisposal = "N"
//        port.degauss = "U"
//        port.dirtyBallast = "N"
//        port.craneFixed = "U"
//        port.craneMobile = "Y"
//        port.craneFloating = "U"
//        port.lifts100 = "U"
//        port.lifts50 = "U"
//        port.lifts25 = "U"
//        port.lifts0 = "Y"
//        port.srLongshore = "U"
//        port.srElectrical = "U"
//        port.srSteam = "U"
//        port.srNavigationalEquipment = "U"
//        port.srElectricalRepair = "U"
//        port.suProvisions = "Y"
//        port.suWater = "Y"
//        port.suFuel = "Y"
//        port.suDiesel = "U"
//        port.suDeck = "U"
//        port.suEngine = "U"
//        port.repairCode = "C"
//        port.drydock = "U"
//        port.railway = "S"
//        port.qtSanitation = "U"
//        port.suAviationFuel = "U"
//        port.harborUse = "UNK"
//        port.ukcMgmtSystem = "U"
//        port.portSecurity = "U"
//        port.etaMessage = "Y"
//        port.searchAndRescue = "U"
//        port.trafficSeparationScheme = "U"
//        port.vesselTrafficService = "U"
//        port.chemicalHoldingTank = "U"
//        port.globalId = "{2C117765-0922-4542-A2B9-333253552952}"
//        port.loRoro = "U"
//        port.loSolidBulk = "U"
//        port.loContainer = "U"
//        port.loBreakBulk = "U"
//        port.loOilTerm = "U"
//        port.loLongTerm = "U"
//        port.loOther = "U"
//        port.loDangCargo = "U"
//        port.loLiquidBulk = "U"
//        port.srIceBreaking = "U"
//        port.srDiving = "U"
//        port.craneContainer = "U"
//        port.unloCode = "GL JEG"
//        port.dnc = "a2800670, coa28e, gen28b, h2800670"
//        port.dodWaterBody = ""
//        port.s57Enc = nil
//        port.s101Enc = ""
//        port.dodWaterBody = "Baffin Bay; Arctic Ocean"
//        port.alternateName = "Egedesminde"
//        port.entranceWidth = 4
//        port.liquifiedNaturalGasTerminalDepth = 5
//        port.offshoreMaxVesselLength = 6
//        port.offshoreMaxVesselBeam = 7
//        port.offshoreMaxVesselDraft = 8
//        port.latitude = 1.0
//        port.longitude = 2.0
//        
//        let repository = PortRepositoryManager(repository: PortCoreDataRepository(context: persistentStore.viewContext))
//        let bookmarkRepository = BookmarkRepositoryManager(repository: BookmarkCoreDataRepository(context: persistentStore.viewContext))
//        
//        let mockCLLocation = MockCLLocationManager()
//        let mockLocationManager = MockLocationManager(locationManager: mockCLLocation)
//        let summary = port.summary
//            .setShowMoreDetails(true)
//            .environmentObject(mockLocationManager as LocationManager)
//            .environment(\.managedObjectContext, persistentStore.viewContext)
//            .environmentObject(repository)
//            .environmentObject(bookmarkRepository)
//        
//        let controller = UIHostingController(rootView: summary)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: port.portName)
//        
//        expectation(forNotification: .ViewDataSource,
//                    object: nil) { notification in
//            let vds = try! XCTUnwrap(notification.object as? ViewDataSource)
//            let port = try! XCTUnwrap(vds.dataSource as? PortModel)
//            XCTAssertEqual(port.portName, "Aasiaat")
//            return true
//        }
//        tester().tapView(withAccessibilityLabel: "More Details")
//        
//        waitForExpectations(timeout: 10, handler: nil)
//        tester().waitForAbsenceOfView(withAccessibilityLabel: "scope")
//        
//        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: port)
//    }

}
