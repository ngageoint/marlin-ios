//
//  TestHelper.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/6/22.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

@testable import Marlin

class TestHelpers {
    let scheme = MarlinScheme()
    
    public static func createGradientImage(startColor: UIColor, endColor: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = rect
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return UIImage() }
        return UIImage(cgImage: cgImage)
    }
    
    public static func getKeyWindowVisible() -> UIWindow {
        guard let window = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first else {
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.backgroundColor = .systemBackground
            window.makeKeyAndVisible()
            return window
        }
        
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        return window
    }
    
    @discardableResult
    public static func asyncGetKeyWindowVisible() async -> UIWindow {
        guard let window = await UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({ $0 }).first?.windows.first else {
            let window = await UIWindow(frame: UIScreen.main.bounds)
            await window.makeKeyAndVisible()
            return window
        }
        
        await window.makeKeyAndVisible()
        return window
    }
    
    public static func getAllAccessibilityLabels(_ viewRoot: UIView) -> [String]! {
        var array = [String]()
        for view in viewRoot.subviews {
            if let lbl = view.accessibilityLabel {
                array += [lbl]
            }
            
            array += getAllAccessibilityLabels(view)
        }
        
        return array
    }
    
    public static func getAllAccessibilityLabelsInWindows() -> [String]! {
        var labelArray = [String]()
        for  window in UIApplication.shared.windowsWithKeyWindow() {
            print("window \(window)")
            labelArray += getAllAccessibilityLabels(window as! UIWindow )
        }
        
        return labelArray
    }
    
    public static func printAllAccessibilityLabelsInWindows() {
        let labelArray = TestHelpers.getAllAccessibilityLabelsInWindows();
        NSLog("labelArray = \(labelArray ?? [])")
    }
    
    static func clearData() {
        let persistentStore: PersistentStore = PersistenceController.shared
        persistentStore.viewContext.performAndWait {
            if let items = persistentStore.viewContext.fetchAll(Asam.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(DFRS.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(DFRSArea.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(DifferentialGPSStation.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(ElectronicPublication.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(Light.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(LightRange.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(MapLayer.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(Modu.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(NavigationalWarning.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(NoticeToMariners.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(Port.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            if let items = persistentStore.viewContext.fetchAll(RadioBeacon.self) {
                for item in items {
                    persistentStore.viewContext.delete(item)
                }
            }
            

        }
        do {
            try persistentStore.viewContext.save()
            print("Cleared data")
        } catch {
            print("Error clearing data \(error)")
        }
    }
    
    static func createOneOfEachType(_ context: NSManagedObjectContext) -> (asam: Asam, modu: Modu, port: Marlin.Port, dfrs: DFRS, radioBeacon: RadioBeacon, light: Light, navigationalWarningPolygon: NavigationalWarning, navigationalWarningLine: NavigationalWarning, navigationalWarningPoint: NavigationalWarning, navigationalWarningMultipoint: NavigationalWarning, navigationalWarningCircle: NavigationalWarning, differentialGPSStation: DifferentialGPSStation)? {
        guard let asam = TestHelpers.createAsam(context) else {
            XCTFail()
            return nil
        }
        guard let modu = TestHelpers.createModu(context) else {
            XCTFail()
            return nil
        }
        guard let port = TestHelpers.createPort(context) else {
            XCTFail()
            return nil
        }
        guard let dfrs = TestHelpers.createDFRS(context) else {
            XCTFail()
            return nil
        }
        guard let radioBeacon = TestHelpers.createRadioBeacon(context) else {
            XCTFail()
            return nil
        }
        guard let light = TestHelpers.createLight(context) else {
            XCTFail()
            return nil
        }
        guard let navigationalWarningPolygon = TestHelpers.createNavigationalWarningPolygon(context) else {
            XCTFail()
            return nil
        }
        guard let navigationalWarningLine = TestHelpers.createNavigationalWarningLine(context) else {
            XCTFail()
            return nil
        }
        guard let navigationalWarningPoint = TestHelpers.createNavigationalWarningPoint(context) else {
            XCTFail()
            return nil
        }
        guard let navigationalWarningMultipoint = TestHelpers.createNavigationalWarningMultiPoint(context) else {
            XCTFail()
            return nil
        }
        guard let navigationalWarningCircle = TestHelpers.createNavigationalWarningCircle(context) else {
            XCTFail()
            return nil
        }
        guard let differentialGPSStation = TestHelpers.createDifferentialGPSStation(context) else {
            XCTFail()
            return nil
        }
        return (
        asam: asam, modu: modu, port: port, dfrs: dfrs, radioBeacon: radioBeacon, light: light, navigationalWarningPolygon: navigationalWarningPolygon, navigationalWarningLine: navigationalWarningLine, navigationalWarningPoint: navigationalWarningPoint, navigationalWarningMultipoint: navigationalWarningMultipoint, navigationalWarningCircle: navigationalWarningCircle, differentialGPSStation: differentialGPSStation
        )
    }
    
    static func createAsam(_ context: NSManagedObjectContext) -> Asam? {
        var newItem: Asam?
        context.performAndWait {
            let asam = Asam(context: context)
            asam.asamDescription = "description"
            asam.longitude = 1.0
            asam.latitude = 1.0
            asam.date = Date(timeIntervalSince1970: 0)
            asam.navArea = "XI"
            asam.reference = "2022-100"
            asam.subreg = "71"
            asam.position = "1°00'00\"N \n1°00'00\"E"
            asam.hostility = "Boarding"
            asam.victim = "Boat"
            
            newItem = asam
            try? context.save()
        }
        return newItem
    }
    
    static func createModu(_ context: NSManagedObjectContext) -> Modu? {
        var newItem: Modu?
        context.performAndWait {
            let modu = Modu(context: context)
            
            modu.name = "ABAN II"
            modu.date = Date(timeIntervalSince1970: 0)
            modu.rigStatus = "Active"
            modu.specialStatus = "Wide Berth Requested"
            modu.distance = 5
            modu.latitude = 1.0
            modu.longitude = 2.0
            modu.position = "16°20'30.6\"N \n81°55'27\"E"
            modu.navArea = "HYDROPAC"
            modu.region = 6
            modu.subregion = 63
            
            newItem = modu
            try? context.save()
        }
        return newItem
    }
    
    static func createPort(_ context: NSManagedObjectContext) -> Marlin.Port? {
        var newItem: Marlin.Port?
        context.performAndWait {
            let port = Marlin.Port(context: context)
            port.portNumber = 760
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
            
            newItem = port
            try? context.save()
        }
        return newItem
    }
    
    static func createDFRS(_ context: NSManagedObjectContext) -> DFRS? {
        var dfrs: DFRS?
        context.performAndWait {
            let area = DFRSArea(context: context)
            area.areaName = "CANADA"
            area.areaIndex = 30
            area.areaNote = "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:"
            area.index = 1
            area.indexNote = "A. Ch.16."
            let area2 = DFRSArea(context: context)
            area2.areaName = "CANADA"
            area2.areaIndex = 30
            area2.areaNote = "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:"
            area2.index = 2
            area2.indexNote = "B. Ch.16 (distress only)."
            let area3 = DFRSArea(context: context)
            area3.areaName = "CANADA"
            area3.areaIndex = 30
            area3.areaNote = "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:"
            area3.index = 3
            area3.indexNote = "C. Ch.16 (distress only)."
            
            let newItem = DFRS(context: context)
            newItem.stationNumber = "1188.61\n2-1282"
            newItem.stationName = "Nos Galata Lt."
            newItem.stationType = "RDF"
            newItem.rxPosition = nil
            newItem.rxLongitude = -190.0
            newItem.rxLatitude = -190.0
            newItem.txPosition = "1°00'00\"N \n2°00'00\"E"
            newItem.txLongitude = 2.0
            newItem.txLatitude = 1.0
            newItem.frequency = "297.5 kHz, A2A."
            newItem.range = 5
            newItem.procedureText = "On request to Hydrographic Service, Varna."
            newItem.remarks = "Transmits !DG$."
            newItem.notes = "notes"
            newItem.areaName = "CANADA"
            
            dfrs = newItem
            try? context.save()
        }
        return dfrs
    }
    
    static func createRadioBeacon(_ context: NSManagedObjectContext) -> RadioBeacon? {
        var newItem: RadioBeacon?
        context.performAndWait {
            let rb = RadioBeacon(context: context)
            
            rb.volumeNumber = "PUB 110"
            rb.aidType = "Radiobeacons"
            rb.geopoliticalHeading = "GREENLAND"
            rb.regionHeading = "region heading"
            rb.precedingNote = "preceding note"
            rb.featureNumber = 10
            rb.name = "Ittoqqortoormit, Scoresbysund"
            rb.position = "70°29'11.99\"N \n21°58'20\"W"
            rb.characteristic = "SC\n(• • •  - • - • ).\n"
            rb.range = 200
            rb.sequenceText = "sequence text"
            rb.frequency = "343\nNON, A2A."
            rb.stationRemark = "Aeromarine."
            rb.postNote = "post note"
            rb.noticeNumber = 199706
            rb.removeFromList = "N"
            rb.deleteFlag = "N"
            rb.noticeWeek = "06"
            rb.noticeYear = "1997"
            rb.latitude = 1.0
            rb.longitude = 2.0
            rb.sectionHeader = "section"
            
            newItem = rb
            try? context.save()
        }
        return newItem
    }
    
    static func createLight(_ context: NSManagedObjectContext) -> Light? {
        var newItem: Light?
        context.performAndWait {
            let light = Light(context: context)
            
            light.volumeNumber = "PUB 114"
            light.aidType = "Lighted Aids"
            light.geopoliticalHeading = "ENGLAND-SCILLY ISLES"
            light.regionHeading = nil
            light.subregionHeading = nil
            light.localHeading = nil
            light.precedingNote = nil
            light.featureNumber = "4"
            light.internationalFeature = "A0002"
            light.name = "Bishop Rock."
            light.position = "49°52'21.4\"N \n6°26'44\"W"
            light.characteristicNumber = 1
            light.characteristic = "Fl.(2)W.\nperiod 15s \nfl. 0.1s, ec. 2.2s \n"
            light.heightFeet = 144
            light.heightMeters = 44
            light.range = "20"
            light.structure = "Gray round granite tower; 161.\nHelicopter platform. \n"
            light.remarks = "Visible 233°-236° and 259°-204°.  Partially obscured 204°-211°.  AIS (MMSI No 992351137).\n"
            light.postNote = nil
            light.noticeNumber = 201516
            light.removeFromList = "N"
            light.deleteFlag = "Y"
            light.noticeWeek = "16"
            light.noticeYear = "2015"
            light.latitude = 1.0
            light.longitude = 2.0
            light.sectionHeader = "Section"
            
            newItem = light
            try? context.save()
        }
        return newItem
    }
    
    static func createNavigationalWarningPolygon(_ context: NSManagedObjectContext) -> NavigationalWarning? {
        var newItem: NavigationalWarning?
        context.performAndWait {
            let nw = NavigationalWarning(context: context)
            
            nw.authority = "EASTERN RANGE 0/23 141502Z APR 23."
            nw.issueDate = NavigationalWarningModel.apiToDateFormatter.date(from: "150429Z APR 2023")
            nw.msgNumber = 418
            nw.msgYear = 2023
            nw.navArea = "4"
            nw.status = "A"
            nw.subregion = "11,26"
            nw.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   191218Z TO 191647Z APR, ALTERNATE\n   201153Z TO 201622Z, 211128Z TO 211556Z,\n   221102Z TO 221531Z, 231037Z TO 231506Z,\n   241012Z TO 241441Z AND 250947Z TO 251416Z APR\n   IN AREAS BOUND BY:\n   A. 28-38.47N 080-37.31W, 28-38.00N 080-32.00W,\n      28-37.00N 080-23.00W, 28-20.00N 079-55.00W,\n      28-16.00N 079-57.00W, 28-31.21N 080-33.38W.\n   B. 26-26.00N 076-00.00W, 25-40.00N 074-06.00W,\n      25-24.00N 073-52.00W, 25-04.00N 074-14.00W,\n      25-13.00N 074-45.00W, 26-03.00N 076-00.00W.\n2. CANCEL NAVAREA IV 414/23.\n3. CANCEL THIS MSG 251516Z APR 23.\n"
            if let mappedLocation = nw.mappedLocation {
                if let region = mappedLocation.region {
                    nw.latitude = region.center.latitude
                    nw.longitude = region.center.longitude
                    nw.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
                    nw.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
                    nw.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
                    nw.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
                }
                nw.locations = mappedLocation.wktDistance
            }
            
            newItem = nw
            try? context.save()
        }
        return newItem
    }
    
    static func createNavigationalWarningLine(_ context: NSManagedObjectContext) -> NavigationalWarning? {
        var newItem: NavigationalWarning?
        context.performAndWait {
            let nw = NavigationalWarning(context: context)
            
            nw.authority = "NAVAREA II 360/22 261001Z DEC 22."
            nw.issueDate = NavigationalWarningModel.apiToDateFormatter.date(from: "261430Z DEC 2022")
            nw.msgNumber = 1396
            nw.msgYear = 2022
            nw.navArea = "4"
            nw.status = "A"
            nw.subregion = "24,25,51"
            nw.text = "EASTERN CARIBBEAN SEA.\nNORTH ATLANTIC.\nCANARY ISLANDS TO ANTIGUA AND BARBUDA.\n1. TALISKAR WHISKEY ATLANTIC CHALLENGE IN\n   PROGRESS UNTIL FURTHER NOTICE BY 43 ROWBOATS\n   IN VICINITY OF TRACKLINE JOINING SAN SEBASTIAN\n   DE LA GOMERA (28-05.53N 017-06.60W) AND\n   ENGLISH HARBOUR (17-00.00N 061-46.00W).\n   WIDE BERTH REQUESTED.\n2. MORE INFORMATION AND POSITIONS OF PARTICIPANTS\n   AT: WWW.TALISKERWHISKYATLANTICCHALLENGE.COM.\n"
            
            if let mappedLocation = nw.mappedLocation {
                if let region = mappedLocation.region {
                    nw.latitude = region.center.latitude
                    nw.longitude = region.center.longitude
                    nw.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
                    nw.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
                    nw.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
                    nw.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
                }
                nw.locations = mappedLocation.wktDistance
            }
            
            newItem = nw
            try? context.save()
        }
        return newItem
    }
    
    static func createNavigationalWarningMultiPoint(_ context: NSManagedObjectContext) -> NavigationalWarning? {
        var newItem: NavigationalWarning?
        context.performAndWait {
            let nw = NavigationalWarning(context: context)
            
            nw.authority = "COGARD COMMUNICATIONS COMMAND 0/23 141801Z APR 23."
            nw.issueDate = NavigationalWarningModel.apiToDateFormatter.date(from: "142132Z APR 2023")
            nw.msgNumber = 417
            nw.msgYear = 2023
            nw.navArea = "4"
            nw.status = "A"
            nw.subregion = "GEN"
            nw.text = "1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:\n   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n2. CANCEL THIS MSG 191500Z APR 23.\n"
            
            if let mappedLocation = nw.mappedLocation {
                if let region = mappedLocation.region {
                    nw.latitude = region.center.latitude
                    nw.longitude = region.center.longitude
                    nw.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
                    nw.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
                    nw.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
                    nw.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
                }
                nw.locations = mappedLocation.wktDistance
            }
            
            newItem = nw
            try? context.save()
        }
        return newItem
    }
    
    static func createNavigationalWarningCircle(_ context: NSManagedObjectContext) -> NavigationalWarning? {
        var newItem: NavigationalWarning?
        context.performAndWait {
            let nw = NavigationalWarning(context: context)
            
            nw.authority = "NAVAREA II 0/23 070918Z APR 23."
            nw.issueDate = NavigationalWarningModel.apiToDateFormatter.date(from: "090315Z APR 2023")
            nw.msgNumber = 396
            nw.msgYear = 2023
            nw.navArea = "4"
            nw.status = "A"
            nw.subregion = "14,51"
            nw.text = "NORTH ATLANTIC.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   0030Z TO 1000Z DAILY 14 APR THRU 07 MAY\n   IN AREA WITHIN 150 MILES OF 37-35.15N 045-40.37W.\n2. CANCEL THIS MSG 071100Z MAY 23.\n"
            
            if let mappedLocation = nw.mappedLocation {
                if let region = mappedLocation.region {
                    nw.latitude = region.center.latitude
                    nw.longitude = region.center.longitude
                    nw.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
                    nw.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
                    nw.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
                    nw.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
                }
                nw.locations = mappedLocation.wktDistance
            }
            
            newItem = nw
            try? context.save()
        }
        return newItem
    }
    
    static func createNavigationalWarningPoint(_ context: NSManagedObjectContext) -> NavigationalWarning? {
        var newItem: NavigationalWarning?
        context.performAndWait {
            let nw = NavigationalWarning(context: context)
            
            nw.authority = "COLOMBIA 89/23 272234Z MAR 23."
            nw.issueDate = NavigationalWarningModel.apiToDateFormatter.date(from: "272241Z MAR 2023")
            nw.msgNumber = 358
            nw.msgYear = 2023
            nw.navArea = "4"
            nw.status = "A"
            nw.subregion = "24"
            nw.text = "CARIBBEAN SEA.\nCOLOMBIA.\nCHART 24480\nISLA DE LOS MUERTOS LIGHT 08-07.90N 076-48.80W\nUNLIT.\n"
            
            if let mappedLocation = nw.mappedLocation {
                if let region = mappedLocation.region {
                    nw.latitude = region.center.latitude
                    nw.longitude = region.center.longitude
                    nw.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
                    nw.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
                    nw.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
                    nw.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
                }
                nw.locations = mappedLocation.wktDistance
            }
            
            newItem = nw
            try? context.save()
        }
        return newItem
    }
    
    static func createDifferentialGPSStation(_ context: NSManagedObjectContext) -> DifferentialGPSStation? {
        var newItem: DifferentialGPSStation?
        context.performAndWait {
            let dgps = DifferentialGPSStation(context: context)
            dgps.volumeNumber = "PUB 112"
            dgps.aidType = "Differential GPS Stations"
            dgps.geopoliticalHeading = "KOREA"
            dgps.regionHeading = "region heading"
            dgps.sectionHeader = "KOREA: region heading"
            dgps.precedingNote = "preceeding note"
            dgps.featureNumber = 6
            dgps.name = "Chojin Dan Lt"
            dgps.position = "1°00'00\"N \n2°00'00.00\"E"
            dgps.latitude = 1.0
            dgps.longitude = 2.0
            dgps.stationID = "T670\nR740\nR741"
            dgps.range = 100
            dgps.frequency = 292
            dgps.transferRate = 200
            dgps.remarks = "Message types: 3, 5, 7, 9, 16."
            dgps.postNote = "post note"
            dgps.noticeNumber = 201134
            dgps.removeFromList = "N"
            dgps.deleteFlag = "N"
            dgps.noticeWeek = "34"
            dgps.noticeYear = "2011"
            
            newItem = dgps
            try? context.save()
        }
        return newItem
    }

}

class MockLocationManager: LocationManager {
//    @Published override var locationStatus: CLAuthorizationStatus?
    public var requestAuthorizationCalled = false
    override func requestAuthorization() {
        requestAuthorizationCalled = true
        NotificationCenter.default.post(Notification(name: .LocationAuthorizationStatusChanged, object: CLAuthorizationStatus.authorizedAlways))
    }
    
    override func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    override internal init(locationManager: CLLocationManager) {
        super.init(locationManager: locationManager)
    }
}

class MockCLLocationManager: CLLocationManager {
    public var requestAuthorizationCalled = false
    public var overriddenAuthStatus: CLAuthorizationStatus = .notDetermined
    
    override var authorizationStatus: CLAuthorizationStatus {
        return overriddenAuthStatus
    }
    
    override func requestWhenInUseAuthorization() {
        requestAuthorizationCalled = true
    }
    
    override func startUpdatingHeading() {
        
    }
    
    override func startUpdatingLocation() {
        
    }
}
