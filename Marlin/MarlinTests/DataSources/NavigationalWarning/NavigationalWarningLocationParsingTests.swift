//
//  NavigationalWarningLocationParsingTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 4/18/23.
//

import XCTest
import OHHTTPStubs

@testable import Marlin
final class NavigationalWarningLocationParsingTests: XCTestCase {
    struct NavWarningTextToExpectedLocation {
        var text: String
        var expected: String
    }

    var testDataAndExpected: [NavWarningTextToExpectedLocation] = [
        NavWarningTextToExpectedLocation(
            text: "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   191218Z TO 191647Z APR, ALTERNATE\n   201153Z TO 201622Z, 211128Z TO 211556Z,\n   221102Z TO 221531Z, 231037Z TO 231506Z,\n   241012Z TO 241441Z AND 250947Z TO 251416Z APR\n   IN AREAS BOUND BY:\n   A. 28-38.47N 080-37.31W, 28-38.00N 080-32.00W,\n      28-37.00N 080-23.00W, 28-20.00N 079-55.00W,\n      28-16.00N 079-57.00W, 28-31.21N 080-33.38W.\n   B. 26-26.00N 076-00.00W, 25-40.00N 074-06.00W,\n      25-24.00N 073-52.00W, 25-04.00N 074-14.00W,\n      25-13.00N 074-45.00W, 26-03.00N 076-00.00W.\n2. CANCEL NAVAREA IV 414/23.\n3. CANCEL THIS MSG 251516Z APR 23.\n",
            expected: ""),
        NavWarningTextToExpectedLocation(
            text: "1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:\n   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n2. CANCEL THIS MSG 191500Z APR 23.\n",
            expected: ""),
        NavWarningTextToExpectedLocation(
            text: "1. NAVAREA IV MOBILE OFFSHORE DRILLING UNITS\n   POSITIONS AT 131200Z APR:\n   A. ARGOS 27-10.4N 090-21.9W.\n   B. BLACKFORD DOLPHIN 18-54.9N 093-21.8W.\n   C. BLAKE 1007 27-22.0N 094-28.1W.\n   D. COATZACOALCOS 18-49.8N 091-50.5W.\n   E. COSLHUNTER 19-15.9N 092-26.2W.\n   F. DEEPWATER ASGARD 27-34.7N 090-06.8W.\n   G. DEEPWATER ATLAS 26-54.2N 091-35.4W.\n   H. DEEPWATER CONQUEROR 27-09.1N 091-12.7W.\n   I. DEEPWATER INVICTUS 27-22.2N 090-08.7W.\n   J. DEEPWATER PONTUS 28-01.6N 089-09.8W.\n   K. DEEPWATER POSEIDON 27-02.1N 092-13.4W.\n   L. DEEPWATER PROTEUS 28-01.8N 089-03.6W.\n   M. DEEPWATER THALASSA 26-27.5N 090-46.5W.\n   N. DEVELOPMENT DRILLER III 07-13.5N 055-51.3W.\n   O. DISCOVERER INSPIRATION 27-45.7N 092-00.4W.\n   P. ENTERPRISE 264 29-11.5N 088-57.0W.\n   Q. ENTERPRISE 351 29-27.7N 088-39.0W.\n   R. FRIDA I 19-36.1N 092-31.7W.\n   S. GALAR 18-30.5N 093-26.5W.\n   T. GERSEMI 18-29.1N 093-21.6W.\n   U. GRID 18-26.7N 094-08.2W.\n   V. GSP ORIZONT 19-36.0N 090-58.0W.\n   W. H&P RIG 100 28-56.8N 088-35.3W.\n   X. H&P RIG 201 28-09.5N 089-12.7W.\n   Y. H&P RIG 205 26-06.6N 094-53.1W.\n   Z. H&P RIG 406 27-33.8N 092-25.0W.\n   AA. HELIX Q4000 27-42.7N 090-15.6W.\n   AB. HOLSTEIN SPAR 27-19.6N 090-31.0W.\n   AC. ISLAND INTERVENTION 27-15.0N 090-02.0W.\n   AD. ISLAND VENTURE 28-10.0N 088-28.7W.\n   AE. JOE DOUGLAS 09-60.0N 060-31.9W.\n   AF. LIZA DESTINY 08-00.0N 057-00.0W.\n   AG. LIZA UNITY 08-00.5N 056-54.8W.\n   AH. MAD DOG 27-11.3N 090-16.4W.\n   AI. MAERSK DISCOVERER 10-38.9N 060-14.1W.\n   AJ. MAERSK VALIANT 07-19.4N 055-52.6W.\n   AK. NABORS MODS 140 28-12.4N 088-46.4W.\n   AL. NABORS MODS 200 28-06.2N 090-12.1W.\n   AM. NABORS MODS 400 26-55.8N 090-31.2W.\n   AN. NJORD 18-28.8N 093-27.6W.\n   AO. NOBLE BOB DOUGLAS 08-04.1N 056-58.9W.\n   AP. NOBLE DON TAYLOR 08-13.5N 057-05.0W.\n   AQ. NOBLE FAYE KOZACK 27-59.4N 088-46.1W.\n   AR. NOBLE GERRY DE SOUZA 10-39.0N 061-39.0W.\n   AS. NOBLE GLOBETROTTER II 28-20.6N 087-56.2W.\n   AT. NOBLE REGINA ALLEN 10-39.1N 061-37.4W.\n   AU. NOBLE SAM CROFT 08-15.1N 056-56.8W.\n   AV. NOBLE STANLEY LAFOSSE 27-32.2N 090-10.0W.\n   AW. NOBLE TOM MADDEN 08-03.3N 056-56.4W.\n   AX. OCEAN BLACKHORNET 28-28.5N 088-11.0W.\n   AY. OCEAN BLACKLION 27-06.4N 090-22.1W.\n   AZ. ODIN 18-30.1N 093-31.4W.\n   AAA. OLYMPUS N88 28-09.6N 089-12.8W.\n   AAB. PAPALOAPAN 18-26.7N 094-08.2W.\n   AAC. (NEW RIG) PROSPERITY 08-11.5N 057-00.0W.\n   AAD. RALPH COFFMAN 18-20.4N 093-53.6W.\n   AAE. ROWAN EXL II 28-22.0N 091-27.7W.\n   AAF. ROWAN RELENTLESS 26-12.2N 091-27.3W.\n   AAG. SAIPEM SANTORINI 28-27.8N 089-04.3W.\n   AAH. SEADRILL WEST VELA 28-11.1N 089-24.3W.\n   AAI. SEVAN BRASIL 12-04.3N 068-51.9W.\n   AAJ. SEVAN LOUISIANA 28-49.2N 088-29.2W.\n   AAK. STENA CARRON 08-04.5N 057-01.5W.\n   AAL. STENA DRILLMAX 08-46.4N 057-33.7W.\n   AAM. THUNDERHORSE PDQ 28-11.5N 088-29.7W.\n   AAN. VALARIS DS-16 28-54.5N 088-11.6W.\n   AAO. WELL SERVICES RIG 110 10-10.5N 061-45.4W.\n   AAP. WELL SERVICES RIG 50 10-13.7N 061-45.5W.\n   AAQ. WEST AURIGA 27-13.5N 090-00.8W.\n   AAR. WEST COURAGEOUS 19-43.1N 092-20.0W.\n   AAS. WEST DEFENDER 18-25.5N 094-15.4W.\n   AAT. WEST INTREPID 19-35.4N 092-13.2W.\n   AAU. WEST NEPTUNE 26-14.5N 092-22.7W.\n   AAV. WFD 250 28-58.3N 090-26.8W.\n2. TO REPORT A MOBILE OFFSHORE DRILLING UNIT AS\n   PER IMO RESOLUTION A.1023(26), PARAGRAPH 11.5.1,\n   CONTACT NAVSAFETY@NGA.MIL SUBJ: MODU REPORT.\n3. CANCEL NAVAREA IV 380/23.\n",
            expected: ""),
        NavWarningTextToExpectedLocation(
            text: "WESTERN NORTH ATLANTIC.\nTRINIDAD AND TOBAGO.\n1. UNDERWATER OPERATIONS 12 THRU 25 APR\n   BY M/V BOURBON EVOLUTION 802 IN 10-15.89N 060-33.25W.\n   500 METER BERTH REQUESTED.\n2. CANCEL THIS MSG 260001Z APR 23.\n",
            expected: ""),
        NavWarningTextToExpectedLocation(
            text: "NORTH ATLANTIC.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   0030Z TO 1000Z DAILY 14 APR THRU 07 MAY\n   IN AREA WITHIN 150 MILES OF 37-35.15N 045-40.37W.\n2. CANCEL THIS MSG 071100Z MAY 23.\n",
            expected: "")
    ]
    
    var areaSurroundingPoint = NavWarningTextToExpectedLocation(
        text: "NORTH ATLANTIC.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   0030Z TO 1000Z DAILY 14 APR THRU 07 MAY\n   IN AREA WITHIN 150 MILES OF 37-35.15N 045-40.37W.\n2. CANCEL THIS MSG 071100Z MAY 23.\n",
        expected: "fail")
    
    var polygonWithTimes = NavWarningTextToExpectedLocation(
        text: "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   191218Z TO 191647Z APR, ALTERNATE\n   201153Z TO 201622Z, 211128Z TO 211556Z,\n   221102Z TO 221531Z, 231037Z TO 231506Z,\n   241012Z TO 241441Z AND 250947Z TO 251416Z APR\n   IN AREAS BOUND BY:\n   A. 28-38.47N 080-37.31W, 28-38.00N 080-32.00W,\n      28-37.00N 080-23.00W, 28-20.00N 079-55.00W,\n      28-16.00N 079-57.00W, 28-31.21N 080-33.38W.\n   B. 26-26.00N 076-00.00W, 25-40.00N 074-06.00W,\n      25-24.00N 073-52.00W, 25-04.00N 074-14.00W,\n      25-13.00N 074-45.00W, 26-03.00N 076-00.00W.\n2. CANCEL NAVAREA IV 414/23.\n3. CANCEL THIS MSG 251516Z APR 23.\n",
        expected: "")
    
    var chart = NavWarningTextToExpectedLocation(
        text: "GULF OF MEXICO.\nCUBA.\nCHART 27100\n1. LA TABLA LIGHT 22-18.20N 084-39.90W\n   CHANGED TO FL W 5 SEC 11 METERS 12 MILES.\n2. ZORRITA LIGHT 22-22.30N 084-34.90W\n   CHANGED TO FL W 7 SEC 11 METERS 12 MILES.\n3. CANCEL NAVAREA IV 54/23.\n",
        expected: "")
    
    func testAreaSurroundingPoint() {
        let nw = NavigationalWarning(context: PersistenceController.shared.viewContext)
        nw.msgYear = 2023
        nw.msgNumber = 396
        nw.navArea = "4"
        nw.subregion = "14,51"
        nw.text = chart.text
        nw.status = "A"
        nw.issueDate = NavigationalWarning.dateFormatter.date(from: "090315Z APR 2023")
        nw.authority = "NAVAREA II 0/23 070918Z APR 23."
        nw.cancelDate = nil
        nw.cancelNavArea = nil
        
//        let wkt = nw.parseToMappedLocation()
        
//        print("wkt \(wkt)")
        
//        XCTAssertEqual(areaSurroundingPoint.expected, wkt.locationName)
    }
    
    func importTestData() -> [String: Any] {
        let path = URL(fileURLWithPath: OHPathForFile("navwarnings.json", type(of: self))!)
        let data = try! Data(contentsOf: path)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return json
    }
    
    func parseTestDataForText(warnings: [String: Any]) -> [String] {
        let broadcastWarns = warnings["broadcast-warn"] as! [[String: Any]]
        return broadcastWarns.compactMap { $0["text"] as? String }
    }
    
    func testAll() {
        for text in parseTestDataForText(warnings: importTestData()) {
            let parser = NAVTEXTextParser(text: text)
            print("------------------ Parsed --------------\n")
            print("\n\(text)\n")
            print("\n------------------- into ---------------\n")
            print("\n\(parser.parseToMappedLocation())\n\n")
            print("---------------------------------------\n")
        }
    }
    
    func testIt() {
        let parser = NAVTEXTextParser(text: "QUEEN MAUD GULF.\nCANADA.\nDNC 28.\n13.7 METER SHOAL IN 69-01.48N 100-58.36W.\n")
        print("\(parser.parseToMappedLocation())\n\n")

        let parser2 = NAVTEXTextParser(text: "PERSIAN GULF.\nU.A.E.\nDNC 10.\n1. UNDERWATER OPERATIONS IN PROGRESS UNTIL\n   FURTHER NOTICE IN AREAS BOUND BY:\n   A. 24-40.22N 052-52.61E, 24-39.08N 053-00.18E,\n      24-30.79N 053-03.24E, 24-26.33N 052-56.63E,\n      24-30.70N 052-52.08E.\n   B. 24-24.56N 053-21.72E, 24-24.46N 053-28.22E,\n      24-17.96N 053-28.09E, 24-18.07N 053-21.60E.\n   WIDE BERTH REQUESTED.\n2. CANCEL HYDROPAC 1742/19.\n")
        print("\(parser2.parseToMappedLocation())\n\n")

        let parser3 = NAVTEXTextParser(text: "1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:\n   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n2. CANCEL THIS MSG 191500Z APR 23.\n")
        print("\(parser3.parseToMappedLocation())\n\n")

        let parser4 = NAVTEXTextParser(text: "BARENTS SEA.\nSVALBARD.\nDNC 22.\nSURVEY OPERATIONS IN PROGRESS UNTIL FURTHER NOTICE BY\nM/V RAMFORD HYPERION TOWING 12 4050 METER LONG CABLES\nIN AREA BOUND BY\n73-44.50N 023-04.50E, 73-41.60N 025-52.40E,\n73-13.10N 025-45.00E, 73-15.80N 023-01.40E.\nFOUR MILE BERTH REQUESTED.\n")
        print("\(parser4.parseToMappedLocation())\n\n")
        
        let parser5 = NAVTEXTextParser(text: "CORONATION GULF.\nCANADA.\nDNC 28.\nSCIENTIFIC MOORING, TOP FLOAT 15 METERS BELOW\nSURFACE, ESTABLISHED IN:\nA. 67-40.09N 107-57.28W.\nB. 67-40.36N 107-57.86W.\n")
        print("\(parser5.parseToMappedLocation())\n\n")
        
        let parser6 = NAVTEXTextParser(text: "KARA SEA.\nDNC 22.\nSUB-SURFACE SCIENTIFIC MOORING, LEAST DEPTH\n15 METERS, ESTABLISHED UNTIL FURTHER NOTICE\nIN 73-00.82N 066-03.29E.\nWIDE BERTH REQUESTED.\n")
        print("\(parser6.parseToMappedLocation())\n\n")
    }
}
