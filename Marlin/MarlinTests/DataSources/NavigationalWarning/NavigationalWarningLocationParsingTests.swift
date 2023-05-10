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
    
    func testParseDistance() {
        let p = NAVTEXTextParser(text: "")
        XCTAssertEqual(p.parseDistance(line: "IN AREA WITHIN 150 MILES OF 37-35.15N 045-40.37W."), "150 MILES")
        
        XCTAssertEqual(p.parseDistance(line: "WESTERN NORTH ATLANTIC.\nTRINIDAD AND TOBAGO.\n1. UNDERWATER OPERATIONS 12 THRU 25 APR\n   BY M/V BOURBON EVOLUTION 802 IN 10-15.89N 060-33.25W.\n   500 METER BERTH REQUESTED.\n2. CANCEL THIS MSG 260001Z APR 23.\n"), "500 METER BERTH")
        
        XCTAssertEqual(p.parseDistance(line: "PERSIAN GULF.\nU.A.E.\nDNC 10.\n1. UNDERWATER OPERATIONS IN PROGRESS UNTIL\n   FURTHER NOTICE IN AREAS BOUND BY:\n   A. 24-40.22N 052-52.61E, 24-39.08N 053-00.18E,\n      24-30.79N 053-03.24E, 24-26.33N 052-56.63E,\n      24-30.70N 052-52.08E.\n   B. 24-24.56N 053-21.72E, 24-24.46N 053-28.22E,\n      24-17.96N 053-28.09E, 24-18.07N 053-21.60E.\n   WIDE BERTH REQUESTED.\n2. CANCEL HYDROPAC 1742/19.\n"), "WIDE BERTH")
        
        XCTAssertEqual(p.parseDistance(line: "BARENTS SEA. SVALBARD. DNC 22. SURVEY OPERATIONS IN PROGRESS UNTIL FURTHER NOTICE BY M/V RAMFORD HYPERION TOWING 12 4050 METER LONG CABLES IN AREA BOUND BY 73-44.50N 023-04.50E, 73-41.60N 025-52.40E, 73-13.10N 025-45.00E, 73-15.80N 023-01.40E. FOUR MILE BERTH REQUESTED."), "FOUR MILE BERTH")
    }
    
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
    
    func testMetersDistance() {
        let location = LocationWithType(location: [""], locationType: "Circle", locationDescription: "", distanceFromLocation: "TWO MILES")
        let distance = location.metersDistance
        print("Distance \(distance)")
        // 1852 meters to nautical mile
        XCTAssertEqual(2 * 1852, distance)
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
//        let parser = NAVTEXTextParser(text: "QUEEN MAUD GULF.\nCANADA.\nDNC 28.\n13.7 METER SHOAL IN 69-01.48N 100-58.36W.\n")
//        print("\(parser.parseToMappedLocation())\n\n")

//        let parser2 = NAVTEXTextParser(text: "PERSIAN GULF.\nU.A.E.\nDNC 10.\n1. UNDERWATER OPERATIONS IN PROGRESS UNTIL\n   FURTHER NOTICE IN AREAS BOUND BY:\n   A. 24-40.22N 052-52.61E, 24-39.08N 053-00.18E,\n      24-30.79N 053-03.24E, 24-26.33N 052-56.63E,\n      24-30.70N 052-52.08E.\n   B. 24-24.56N 053-21.72E, 24-24.46N 053-28.22E,\n      24-17.96N 053-28.09E, 24-18.07N 053-21.60E.\n   WIDE BERTH REQUESTED.\n2. CANCEL HYDROPAC 1742/19.\n")
//        print("\(parser2.parseToMappedLocation())\n\n")
//
//        let parser3 = NAVTEXTextParser(text: "1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:\n   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n2. CANCEL THIS MSG 191500Z APR 23.\n")
//        print("\(parser3.parseToMappedLocation())\n\n")
//
        let parser4 = NAVTEXTextParser(text: "BARENTS SEA.\nSVALBARD.\nDNC 22.\nSURVEY OPERATIONS IN PROGRESS UNTIL FURTHER NOTICE BY\nM/V RAMFORD HYPERION TOWING 12 4050 METER LONG CABLES\nIN AREA BOUND BY\n73-44.50N 023-04.50E, 73-41.60N 025-52.40E,\n73-13.10N 025-45.00E, 73-15.80N 023-01.40E.\nFOUR MILE BERTH REQUESTED.\n")
        let location = parser4.parseToMappedLocation()
        print("\(location)\n\n")
        print("wkt \(location?.wktDistance)\n\n")
//
//        let parser5 = NAVTEXTextParser(text: "CORONATION GULF.\nCANADA.\nDNC 28.\nSCIENTIFIC MOORING, TOP FLOAT 15 METERS BELOW\nSURFACE, ESTABLISHED IN:\nA. 67-40.09N 107-57.28W.\nB. 67-40.36N 107-57.86W.\n")
//        print("\(parser5.parseToMappedLocation())\n\n")
//
//        let parser6 = NAVTEXTextParser(text: "KARA SEA.\nDNC 22.\nSUB-SURFACE SCIENTIFIC MOORING, LEAST DEPTH\n15 METERS, ESTABLISHED UNTIL FURTHER NOTICE\nIN 73-00.82N 066-03.29E.\nWIDE BERTH REQUESTED.\n")
//        print("\(parser6.parseToMappedLocation())\n\n")
//        let parser7 = NAVTEXTextParser(text: "1. NAVAREA IV MOBILE OFFSHORE DRILLING UNITS\n   POSITIONS AT 131200Z APR:\n   A. ARGOS 27-10.4N 090-21.9W.\n   B. BLACKFORD DOLPHIN 18-54.9N 093-21.8W.\n   C. BLAKE 1007 27-22.0N 094-28.1W.\n   D. COATZACOALCOS 18-49.8N 091-50.5W.\n   E. COSLHUNTER 19-15.9N 092-26.2W.\n   F. DEEPWATER ASGARD 27-34.7N 090-06.8W.\n   G. DEEPWATER ATLAS 26-54.2N 091-35.4W.\n   H. DEEPWATER CONQUEROR 27-09.1N 091-12.7W.\n   I. DEEPWATER INVICTUS 27-22.2N 090-08.7W.\n   J. DEEPWATER PONTUS 28-01.6N 089-09.8W.\n   K. DEEPWATER POSEIDON 27-02.1N 092-13.4W.\n   L. DEEPWATER PROTEUS 28-01.8N 089-03.6W.\n   M. DEEPWATER THALASSA 26-27.5N 090-46.5W.\n   N. DEVELOPMENT DRILLER III 07-13.5N 055-51.3W.\n   O. DISCOVERER INSPIRATION 27-45.7N 092-00.4W.\n   P. ENTERPRISE 264 29-11.5N 088-57.0W.\n   Q. ENTERPRISE 351 29-27.7N 088-39.0W.\n   R. FRIDA I 19-36.1N 092-31.7W.\n   S. GALAR 18-30.5N 093-26.5W.\n   T. GERSEMI 18-29.1N 093-21.6W.\n   U. GRID 18-26.7N 094-08.2W.\n   V. GSP ORIZONT 19-36.0N 090-58.0W.\n   W. H&P RIG 100 28-56.8N 088-35.3W.\n   X. H&P RIG 201 28-09.5N 089-12.7W.\n   Y. H&P RIG 205 26-06.6N 094-53.1W.\n   Z. H&P RIG 406 27-33.8N 092-25.0W.\n   AA. HELIX Q4000 27-42.7N 090-15.6W.\n   AB. HOLSTEIN SPAR 27-19.6N 090-31.0W.\n   AC. ISLAND INTERVENTION 27-15.0N 090-02.0W.\n   AD. ISLAND VENTURE 28-10.0N 088-28.7W.\n   AE. JOE DOUGLAS 09-60.0N 060-31.9W.\n   AF. LIZA DESTINY 08-00.0N 057-00.0W.\n   AG. LIZA UNITY 08-00.5N 056-54.8W.\n   AH. MAD DOG 27-11.3N 090-16.4W.\n   AI. MAERSK DISCOVERER 10-38.9N 060-14.1W.\n   AJ. MAERSK VALIANT 07-19.4N 055-52.6W.\n   AK. NABORS MODS 140 28-12.4N 088-46.4W.\n   AL. NABORS MODS 200 28-06.2N 090-12.1W.\n   AM. NABORS MODS 400 26-55.8N 090-31.2W.\n   AN. NJORD 18-28.8N 093-27.6W.\n   AO. NOBLE BOB DOUGLAS 08-04.1N 056-58.9W.\n   AP. NOBLE DON TAYLOR 08-13.5N 057-05.0W.\n   AQ. NOBLE FAYE KOZACK 27-59.4N 088-46.1W.\n   AR. NOBLE GERRY DE SOUZA 10-39.0N 061-39.0W.\n   AS. NOBLE GLOBETROTTER II 28-20.6N 087-56.2W.\n   AT. NOBLE REGINA ALLEN 10-39.1N 061-37.4W.\n   AU. NOBLE SAM CROFT 08-15.1N 056-56.8W.\n   AV. NOBLE STANLEY LAFOSSE 27-32.2N 090-10.0W.\n   AW. NOBLE TOM MADDEN 08-03.3N 056-56.4W.\n   AX. OCEAN BLACKHORNET 28-28.5N 088-11.0W.\n   AY. OCEAN BLACKLION 27-06.4N 090-22.1W.\n   AZ. ODIN 18-30.1N 093-31.4W.\n   AAA. OLYMPUS N88 28-09.6N 089-12.8W.\n   AAB. PAPALOAPAN 18-26.7N 094-08.2W.\n   AAC. (NEW RIG) PROSPERITY 08-11.5N 057-00.0W.\n   AAD. RALPH COFFMAN 18-20.4N 093-53.6W.\n   AAE. ROWAN EXL II 28-22.0N 091-27.7W.\n   AAF. ROWAN RELENTLESS 26-12.2N 091-27.3W.\n   AAG. SAIPEM SANTORINI 28-27.8N 089-04.3W.\n   AAH. SEADRILL WEST VELA 28-11.1N 089-24.3W.\n   AAI. SEVAN BRASIL 12-04.3N 068-51.9W.\n   AAJ. SEVAN LOUISIANA 28-49.2N 088-29.2W.\n   AAK. STENA CARRON 08-04.5N 057-01.5W.\n   AAL. STENA DRILLMAX 08-46.4N 057-33.7W.\n   AAM. THUNDERHORSE PDQ 28-11.5N 088-29.7W.\n   AAN. VALARIS DS-16 28-54.5N 088-11.6W.\n   AAO. WELL SERVICES RIG 110 10-10.5N 061-45.4W.\n   AAP. WELL SERVICES RIG 50 10-13.7N 061-45.5W.\n   AAQ. WEST AURIGA 27-13.5N 090-00.8W.\n   AAR. WEST COURAGEOUS 19-43.1N 092-20.0W.\n   AAS. WEST DEFENDER 18-25.5N 094-15.4W.\n   AAT. WEST INTREPID 19-35.4N 092-13.2W.\n   AAU. WEST NEPTUNE 26-14.5N 092-22.7W.\n   AAV. WFD 250 28-58.3N 090-26.8W.\n2. TO REPORT A MOBILE OFFSHORE DRILLING UNIT AS\n   PER IMO RESOLUTION A.1023(26), PARAGRAPH 11.5.1,\n   CONTACT NAVSAFETY@NGA.MIL SUBJ: MODU REPORT.\n3. CANCEL NAVAREA IV 380/23.\n")
//        print("\(parser7.parseToMappedLocation())\n\n")
//
//        let parser8 = NAVTEXTextParser(text: "CARIBBEAN SEA.\nCOLOMBIA.\nCHART 24480\nISLA DE LOS MUERTOS LIGHT 08-07.90N 076-48.80W\nUNLIT.\n")
//        print("\(parser8.parseToMappedLocation())\n\n")
//
//        let parser9 = NAVTEXTextParser(text: "EASTERN CARIBBEAN SEA.\nNORTH ATLANTIC.\nCANARY ISLANDS TO ANTIGUA AND BARBUDA.\n1. TALISKAR WHISKEY ATLANTIC CHALLENGE IN\n   PROGRESS UNTIL FURTHER NOTICE BY 43 ROWBOATS\n   IN VICINITY OF TRACKLINE JOINING SAN SEBASTIAN\n   DE LA GOMERA (28-05.53N 017-06.60W) AND\n   ENGLISH HARBOUR (17-00.00N 061-46.00W).\n   WIDE BERTH REQUESTED.\n2. MORE INFORMATION AND POSITIONS OF PARTICIPANTS\n   AT: WWW.TALISKERWHISKYATLANTICCHALLENGE.COM.\n")
//        print(" should be a line \(parser9.parseToMappedLocation())\n\n")
//
//        let parser10 = NAVTEXTextParser(text: "NETHERLANDS ANTILLES.\nNAVTEX STATION CURACAO (H)\n12-10.31N 068-51.82W OFF AIR.\n")
//        print("\(parser10.parseToMappedLocation())\n\n")
//
//        let parser11 = NAVTEXTextParser(text: "WESTERN NORTH ATLANTIC.\nHAITI.\nCHART 26141.\nILE DE LA TORTUE W. POINT LIGHT\n20-03-44N 072-58-02W UNLIT.\n")
//        print("\(parser11.parseToMappedLocation())\n\n")
//
//        let parser12 = NAVTEXTextParser(text: "CARIBBEAN SEA.\nHAITI.\nCHART 26203.\nILE VACHE LIGHT 18-03-52N 073-34-31W UNLIT.\n")
//        print("\(parser12.parseToMappedLocation())\n\n")
//
//        let parser13 = NAVTEXTextParser(text: "EASTERN CARIBBEAN SEA.\nANTIGUA TO SINT MAARTIN.\nDNC 14, DNC 16.\nVESSEL DELUXE, WHITE HULL, FOUR PERSONS ON BOARD,\nUNREPORTED ANTIGUA (17-11.59N 061-46.69W) TO\nSINT MAARTIN (18-05.53N 063-05.98W).VESSELS\nIN VICINITY REQUESTED TO KEEP A SHARP LOOKOUT,\nASSIST IF POSSIBLE. REPORTS TO MRCC FORT DE\nFRANCE, INMARSAT: 422799024, TELEX: 42912008,\nPHONE: 5965 9670 9292, FAX: 5965 9663 2450,\nE-MAIL: ANTILLES@MRCCFR.EU.\n")
//        print("should be a line \(parser13.parseToMappedLocation())\n\n")
//
//        let parser14 = NAVTEXTextParser(text: "EASTERN SOUTH ATLANTIC.\nSOUTH AFRICA TO ST. HELENA.\nDNC 01.\nS/V AKEAL II, WHITE HULL, ONE PERSON\nON BOARD, OVERDUE CAPE TOWN\n(33-55.50S 018-25.40E) TO ST. HELENA\n(15-58.00S 005-42.00W). VESSELS IN VICINITY\nREQUESTED TO KEEP A SHARP LOOKOUT,\nASSIST IF POSSIBLE.\nREPORTS TO MRCC CAPE TOWN,\nPHONE: 272 1551 0700, 272 1938 3300,\nE-MAIL: MRCC.CT@SAMSA.ORG.ZA,\nMARITIMERADIO@TELKOM.CO.ZA.\n")
//        print("should be a line, specific area should be South Africa to St. Helena\n\(parser14.parseToMappedLocation())\n\n")
//
//        let parser15 = NAVTEXTextParser(text: "BLACK SEA.\nTURKEY TO UKRAINE.\nDNC 10.\n1. THE BLACK SEA GRAIN INITIATIVE JCC HAS ESTABLISHED A\n   ROUTE FOR VESSELS INBOUND AND OUTBOUND OF UKRAINIAN\n   PORTS. THE ROUTE IS 320NM LONG AND CONNECTS THE LISTED\n   UKRAINIAN PORTS WITH INSPECTION AREAS INSIDE TURKISH\n   TERRITORIAL SEAS.\n   THE MARITIME HUMANITARIAN CORRIDOR (MHC) FORMS PART\n   OF THIS ROUTE AND EXTENDS FROM THE BOUNDARY OF\n   UKRAINIAN TERRITORIAL SEAS TO THE SOUTHERN WAYPOINT\n   OF THE HIGH SEAS TRANSIT CORRIDOR (HSTC).\n   WHILST TRANSITING THE MHC NO MILITARY SHIP, AIRCRAFT\n   OR UAV MAY CLOSE WITHIN A RADIUS 10NM OF ANY VESSEL\n   ENGAGED IN THE INITIATIVE AND TRANSITING THE CORRIDOR.\n   VESSELS ENCOUNTERING PROVOCATIONS OR THREATS WHILE\n   TRANSITING THE MHC SHOULD REPORT IMMEDIATELY TO THE JCC.\n   NO VESSEL SHALL TRANSIT THE MHC WITHOUT THE AUTHORIZATION\n   OF THE JCC.\n   PILOTS WILL EMBARK FOR PASSAGE BETWEEN BERTH AND HOLDING AREA.\n   A. CHORNOMORSK TO HOLDING AREA CHANNEL\n      WITHIN 200M OF TRACKLINE JOINING\n      46-24.00N 030-54.00E, 46-20.50N 030-43.20E,\n      46-20.00N 030-42.70E, 46-18.84N 030-41.81E,\n      46-19.12N 030-40.60E.\n   B. ODESA TO HOLDING AREA CHANNEL\n      WITHIN 200M OF TRACKLINE JOINING\n      46-30.00N 030-54.00E, 46-30.00N 030-46.40E,\n      46-29.90N 030-46.04E, 46-29.99N 030-44.54E.\n   C. PIVDENNYI TO HOLDING AREA CHANNEL\n      WITHIN 200M OF TRACKLINE JOINING\n      46-30.50N 030-57.00E, 46-32.60N 030-57.00E,\n      46-33.34N 031-00.04E, 46-36.19N 031-01.00E.\n   D. HOLDING AREA IN AREA BOUND BY\n      46-30.50N 030-54.00E, 46-30.50N 030-58.20E,\n      46-24.00N 030-58.20E, 46-24.00N 030-54.00E.\n   E. VESSEL MUST TRANSIT BETWEEN THE HOLDING AREA\n      AND MHC THROUGH THE AREA BOUNDED BY\n      46-24.00N 030-54.00E, 46-19.00N 031-05.00E,\n      46-12.00N 031-07.50E, 46-12.00N 031-12.50E,\n      46-27.00N 031-10.50E, 46-28.20N 030-58.20E.\n2. THE HSTC IS 83NM LONG AND 3NM WIDE. WHEN TRANSITING\n   THE HSTC VESSELS ARE CONSIDERED RESTRICTED IN THEIR\n   ABILITY TO MANEUVER AND SHOULD DISPLAY THE APPROPRIATE\n   LIGHTS/SHAPES. VESSELS MUST TRANSIT BETWEEN\n   0500 TO 2100 LOCAL ALONG TRACKLINE JOINING\n   44-53.00N 030-39.50E, 45-37.10N 030-48.10E,\n   46-12.00N 031-10.00E.\n3. A SOUTHERN WAITING AREA IS DESIGNATED AS A\n   TEMPORARY HOLDING AREA FOR VESSELS ENGAGED IN\n   THE INITIATIVE. INBOUND VESSELS MAY USE THE\n   SOUTHERN WAITING AREA TO AWAIT TRANSIT DURING\n   AUTHORIZED HOURS, INFORMING THE JCC THROUGH\n   ISTANBUL TRAFFIC, IN AREA BOUND BY\n   44-50.00N 030-10.00E, 44-50.00N 030-25.00E,\n   44-55.00N 030-25.00E, 45-00.00N 030-10.00E.\n4. VESSELS ON PASSAGE BETWEEN THE MARITIME\n   HUMANITARIAN CORRIDOR AND THE INSPECTION AREA\n   SHALL PASS THROUGH POSITION IN 42-19.15N 029-27.00E.\n   ISTANBUL VTS WILL INFORM AND DIRECT VESSELS TO THE\n   APPROPRIATE INSPECTION AREA.\n   A. INSPECTION AREA N (BLACK SEA) IN AREA BOUND BY\n      41-14.90N 028-59.58E, 41-17.26N 028-59.58E,\n      41-17.26N 029-02.20E, 41-15.50N 029-04.60E,\n      41-15.20N 029-04.60E.\n   B. INSPECTION AREA S (SEA OF MARMARA) IN AREA BOUND BY\n      41-00.36N 028-59.13E, 40-59.33N 028-58.57E,\n      40-58.09N 028-56.47E, 40-59.84N 028-56.47E,\n      40-58.48N 028-53.28E, 40-59.50N 028-56.28E,\n      40-58.06N 028-56.28E, 40-56.46N 028-53.28E.\n5. OTHER THAN IN CASE OF EMERGENCY, PORT CALLS AND\n   PROLONGED STOPS ARE NOT PERMITTED DURING THE\n   TRANSIT. SHIP TO SHIP TRANSFERS ARE NOT AUTHORIZED.\n   VESSELS PARTICIPATING IN THE INITIATIVE MUST TRANSMIT\n   ON AIS AT ALL TIMES. ADDITIONAL PROCEDURES FOR VESSELS\n   WISHING TO PARTICIPATE IN THE INITIATIVE ARE CONTAINED\n   IN IMO CIRCULAR LETTER 4611 (SERIES).\n")
////
//        print("\n\("BLACK SEA.\nTURKEY TO UKRAINE.\nDNC 10.\n1. THE BLACK SEA GRAIN INITIATIVE JCC HAS ESTABLISHED A\n   ROUTE FOR VESSELS INBOUND AND OUTBOUND OF UKRAINIAN\n   PORTS. THE ROUTE IS 320NM LONG AND CONNECTS THE LISTED\n   UKRAINIAN PORTS WITH INSPECTION AREAS INSIDE TURKISH\n   TERRITORIAL SEAS.\n   THE MARITIME HUMANITARIAN CORRIDOR (MHC) FORMS PART\n   OF THIS ROUTE AND EXTENDS FROM THE BOUNDARY OF\n   UKRAINIAN TERRITORIAL SEAS TO THE SOUTHERN WAYPOINT\n   OF THE HIGH SEAS TRANSIT CORRIDOR (HSTC).\n   WHILST TRANSITING THE MHC NO MILITARY SHIP, AIRCRAFT\n   OR UAV MAY CLOSE WITHIN A RADIUS 10NM OF ANY VESSEL\n   ENGAGED IN THE INITIATIVE AND TRANSITING THE CORRIDOR.\n   VESSELS ENCOUNTERING PROVOCATIONS OR THREATS WHILE\n   TRANSITING THE MHC SHOULD REPORT IMMEDIATELY TO THE JCC.\n   NO VESSEL SHALL TRANSIT THE MHC WITHOUT THE AUTHORIZATION\n   OF THE JCC.\n   PILOTS WILL EMBARK FOR PASSAGE BETWEEN BERTH AND HOLDING AREA.\n   A. CHORNOMORSK TO HOLDING AREA CHANNEL\n      WITHIN 200M OF TRACKLINE JOINING\n      46-24.00N 030-54.00E, 46-20.50N 030-43.20E,\n      46-20.00N 030-42.70E, 46-18.84N 030-41.81E,\n      46-19.12N 030-40.60E.\n   B. ODESA TO HOLDING AREA CHANNEL\n      WITHIN 200M OF TRACKLINE JOINING\n      46-30.00N 030-54.00E, 46-30.00N 030-46.40E,\n      46-29.90N 030-46.04E, 46-29.99N 030-44.54E.\n   C. PIVDENNYI TO HOLDING AREA CHANNEL\n      WITHIN 200M OF TRACKLINE JOINING\n      46-30.50N 030-57.00E, 46-32.60N 030-57.00E,\n      46-33.34N 031-00.04E, 46-36.19N 031-01.00E.\n   D. HOLDING AREA IN AREA BOUND BY\n      46-30.50N 030-54.00E, 46-30.50N 030-58.20E,\n      46-24.00N 030-58.20E, 46-24.00N 030-54.00E.\n   E. VESSEL MUST TRANSIT BETWEEN THE HOLDING AREA\n      AND MHC THROUGH THE AREA BOUNDED BY\n      46-24.00N 030-54.00E, 46-19.00N 031-05.00E,\n      46-12.00N 031-07.50E, 46-12.00N 031-12.50E,\n      46-27.00N 031-10.50E, 46-28.20N 030-58.20E.\n2. THE HSTC IS 83NM LONG AND 3NM WIDE. WHEN TRANSITING\n   THE HSTC VESSELS ARE CONSIDERED RESTRICTED IN THEIR\n   ABILITY TO MANEUVER AND SHOULD DISPLAY THE APPROPRIATE\n   LIGHTS/SHAPES. VESSELS MUST TRANSIT BETWEEN\n   0500 TO 2100 LOCAL ALONG TRACKLINE JOINING\n   44-53.00N 030-39.50E, 45-37.10N 030-48.10E,\n   46-12.00N 031-10.00E.\n3. A SOUTHERN WAITING AREA IS DESIGNATED AS A\n   TEMPORARY HOLDING AREA FOR VESSELS ENGAGED IN\n   THE INITIATIVE. INBOUND VESSELS MAY USE THE\n   SOUTHERN WAITING AREA TO AWAIT TRANSIT DURING\n   AUTHORIZED HOURS, INFORMING THE JCC THROUGH\n   ISTANBUL TRAFFIC, IN AREA BOUND BY\n   44-50.00N 030-10.00E, 44-50.00N 030-25.00E,\n   44-55.00N 030-25.00E, 45-00.00N 030-10.00E.\n4. VESSELS ON PASSAGE BETWEEN THE MARITIME\n   HUMANITARIAN CORRIDOR AND THE INSPECTION AREA\n   SHALL PASS THROUGH POSITION IN 42-19.15N 029-27.00E.\n   ISTANBUL VTS WILL INFORM AND DIRECT VESSELS TO THE\n   APPROPRIATE INSPECTION AREA.\n   A. INSPECTION AREA N (BLACK SEA) IN AREA BOUND BY\n      41-14.90N 028-59.58E, 41-17.26N 028-59.58E,\n      41-17.26N 029-02.20E, 41-15.50N 029-04.60E,\n      41-15.20N 029-04.60E.\n   B. INSPECTION AREA S (SEA OF MARMARA) IN AREA BOUND BY\n      41-00.36N 028-59.13E, 40-59.33N 028-58.57E,\n      40-58.09N 028-56.47E, 40-59.84N 028-56.47E,\n      40-58.48N 028-53.28E, 40-59.50N 028-56.28E,\n      40-58.06N 028-56.28E, 40-56.46N 028-53.28E.\n5. OTHER THAN IN CASE OF EMERGENCY, PORT CALLS AND\n   PROLONGED STOPS ARE NOT PERMITTED DURING THE\n   TRANSIT. SHIP TO SHIP TRANSFERS ARE NOT AUTHORIZED.\n   VESSELS PARTICIPATING IN THE INITIATIVE MUST TRANSMIT\n   ON AIS AT ALL TIMES. ADDITIONAL PROCEDURES FOR VESSELS\n   WISHING TO PARTICIPATE IN THE INITIATIVE ARE CONTAINED\n   IN IMO CIRCULAR LETTER 4611 (SERIES).\n")\n")
//        print("this should be lines and also polygons \n\(parser15.parseToMappedLocation())\n\n")
//
//        let parser16 = NAVTEXTextParser(text: "WESTERN SOUTH ATLANTIC.\nBRAZIL.\nDNC 01.\nDEPTHS LESS THAN CHARTED IN:\nA. 01-47.62S 043-51.68W.\nB. 01-57.76S 044-02.45W.\nC. 01-47.66S 043-52.00W.\n")
//        print("\("WESTERN SOUTH ATLANTIC.\nBRAZIL.\nDNC 01.\nDEPTHS LESS THAN CHARTED IN:\nA. 01-47.62S 043-51.68W.\nB. 01-57.76S 044-02.45W.\nC. 01-47.66S 043-52.00W.\n")")
//        print("this should be three separate points \n\(parser16.parseToMappedLocation())\n\n")
//
//        let parser17 = NAVTEXTextParser(text: "NORTH SEA.\nENGLAND.\nDNC 20.\nUNEXPLODED ORDNANCE IN:\nA. 52-25.1N 002-02.1E.\nB. 52-29.4N 002-50.0E.\nC. 52-26.1N 001-47.5E.\n")
//        print("three points\n\(parser17.parseToMappedLocation())\n\n")
        
//        print("\nA. 52-25.1N 002-02.1E.\nB. 52-29.4N 002-50.0E.\nC. 52-26.1N 001-47.5E.\n".splitOnLetterHeadings())
//        print("NORTH SEA.\nENGLAND.\nDNC 20.\nUNEXPLODED ORDNANCE IN:\nA. 52-25.1N 002-02.1E.\nB. 52-29.4N 002-50.0E.\nC. 52-26.1N 001-47.5E.\n".splitOnLetterHeadings())
        
        
//        let parser18 = NAVTEXTextParser(text: "QUEEN MAUD GULF.\nCANADA.\nDNC 28.\n1. 23.8 METER SHOAL IN 68-58.95N 101-08.32W.\n2. CANCEL HYDROARC 206/21.\n")
//        print("\(parser18.parseToMappedLocation())\n\n")
        
//        let parser19 = NAVTEXTextParser(text: "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   191218Z TO 191647Z APR, ALTERNATE\n   201153Z TO 201622Z, 211128Z TO 211556Z,\n   221102Z TO 221531Z, 231037Z TO 231506Z,\n   241012Z TO 241441Z AND 250947Z TO 251416Z APR\n   IN AREAS BOUND BY:\n   A. 28-38.47N 080-37.31W, 28-38.00N 080-32.00W,\n      28-37.00N 080-23.00W, 28-20.00N 079-55.00W,\n      28-16.00N 079-57.00W, 28-31.21N 080-33.38W.\n   B. 26-26.00N 076-00.00W, 25-40.00N 074-06.00W,\n      25-24.00N 073-52.00W, 25-04.00N 074-14.00W,\n      25-13.00N 074-45.00W, 26-03.00N 076-00.00W.\n2. CANCEL NAVAREA IV 414/23.\n3. CANCEL THIS MSG 251516Z APR 23.\n")
//        print("\(parser19.parseToMappedLocation())\n\n")
        
//        let parser20 = NAVTEXTextParser(text: "LANCASTER SOUND.\nCANADA.\nDNC 28.\nSCIENTIFIC MOORINGS ESTABLISHED:\nA. 74-36.37N 091-15.05W, TOP FLOAT 147 METERS.\nB. 74-36.27N 091-15.73W, TOP FLOAT 59 METERS.\nC. 74-36.24N 091-15.17W, TOP FLOAT 44 METERS.\nD. 74-04.85N 090-01.25W, TOP FLOAT 32 METERS.\nE. 74-12.57N 090-49.64W, TOP FLOAT 246 METERS.\nF. 74-11.87N 090-49.04W, TOP FLOAT 26 METERS.\nG. 74-35.73N 091-08.05W, TOP FLOAT 72 METERS.\nH. 74-12.67N 090-46.24W, TOP FLOAT 61 METERS.\nI. 74-11.89N 090-46.29W, TOP FLOAT 36 METERS.\n")
//        print("\(parser20.parseToMappedLocation())\n\n")
    }
    
    func testGetHeadingAndSections() {
        let parser = NAVTEXTextParser(text: "Somewhere.\nSpecific.\nCHART 10\nSubject has something to say.\n1. number 1 thing\n")
        let hs = parser.getHeadingAndSections(string: parser.text)
        XCTAssertEqual("Somewhere.\nSpecific.\nCHART 10\nSubject has something to say.", hs.heading)
        let hs2 = parser.getHeadingAndSections(string: parser.text.replacingOccurrences(of: "\n", with: " "))
        XCTAssertEqual("Somewhere. Specific. CHART 10 Subject has something to say.", hs2.heading)
        
        let parser2 = NAVTEXTextParser(text: "Somewhere.\nSpecific.\nCHART 10\nSubject has something to say.\nA. letter a thing\n")
        let hs3 = parser2.getHeadingAndSections(string: parser2.text.replacingOccurrences(of: "\n", with: " "))
        XCTAssertEqual("Somewhere. Specific. CHART 10 Subject has something to say.", hs3.heading)
        
        let hs4 = parser2.getHeadingAndSections(string: "WESTERN SOUTH ATLANTIC.\nBRAZIL.\nDNC 01.\nDEPTHS LESS THAN CHARTED IN:\nA. 01-47.62S 043-51.68W.\nB. 01-57.76S 044-02.45W.\nC. 01-47.66S 043-52.00W.\n")
        XCTAssertEqual("WESTERN SOUTH ATLANTIC.\nBRAZIL.\nDNC 01.\nDEPTHS LESS THAN CHARTED IN:", hs4.heading)
        XCTAssertEqual("A. 01-47.62S 043-51.68W.\nB. 01-57.76S 044-02.45W.\nC. 01-47.66S 043-52.00W.", hs4.sections)
    }
    
    func testSplitNumbers() {
        let text = "1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:\n   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n2. CANCEL THIS MSG 191500Z APR 23.\n"
        let parser = NAVTEXTextParser(text: text)
        XCTAssertEqual(["1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:\n   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.", "2. CANCEL THIS MSG 191500Z APR 23."], parser.splitNumbers(string: text))
        
        let parser2 = NAVTEXTextParser(text: text.replacingOccurrences(of: "\n", with: " "))
        XCTAssertEqual(["1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE    1200Z TO 1400Z DAILY 18 AND 19 APR    AT USCG REMOTE COMMUNICATION FACILITIES:    A. BOSTON (F) 41-42.8N 070-30.3W.    B. CHARLESTON (E) 32-50.7N 079-57.0W.    C. CHESAPEAKE (N) 36-43.7N 076-00.6W.    D. MIAMI (A) 25-37.4N 080-23.4W.    E. NEW ORLEANS (G) 29-53.1N 089-56.7W.    F. SAN JUAN (R) 18-27.00N 066-06.00W.", "2. CANCEL THIS MSG 191500Z APR 23."], parser2.splitNumbers(string: text.replacingOccurrences(of: "\n", with: " ")))
        
        XCTAssertEqual([], parser2.splitNumbers(string:"A. 01-47.62S 043-51.68W.\nB. 01-57.76S 044-02.45W.\nC. 01-47.66S 043-52.00W."))
    }
    
    func testSplitLetters() {
        let text = "   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n"
        let parser = NAVTEXTextParser(text: text)
        XCTAssertEqual(["A. BOSTON (F) 41-42.8N 070-30.3W.","B. CHARLESTON (E) 32-50.7N 079-57.0W.","C. CHESAPEAKE (N) 36-43.7N 076-00.6W.","D. MIAMI (A) 25-37.4N 080-23.4W.","E. NEW ORLEANS (G) 29-53.1N 089-56.7W.","F. SAN JUAN (R) 18-27.00N 066-06.00W."], parser.splitLetters(string: text))
        
        let parser2 = NAVTEXTextParser(text: text.replacingOccurrences(of: "\n", with: " "))
        XCTAssertEqual(["A. BOSTON (F) 41-42.8N 070-30.3W.","B. CHARLESTON (E) 32-50.7N 079-57.0W.","C. CHESAPEAKE (N) 36-43.7N 076-00.6W.","D. MIAMI (A) 25-37.4N 080-23.4W.","E. NEW ORLEANS (G) 29-53.1N 089-56.7W.","F. SAN JUAN (R) 18-27.00N 066-06.00W."], parser2.splitLetters(string: text.replacingOccurrences(of: "\n", with: " ")))
    }
    
    func testSplitSentences() {
        let parser = NAVTEXTextParser(text: "Somewhere.\nSpecific.\nCHART 10\nSubject has something to say.\n")
        let split = parser.splitSentences(string: parser.text)
        XCTAssertEqual(["Somewhere.","Specific.","CHART 10 Subject has something to say."], split)
        
        let parser2 = NAVTEXTextParser(text: "Somewhere.\nSpecific.\nCHART 10\nSubject has\nsomething to say.\n")
        let split2 = parser.splitSentences(string: parser2.text)
        XCTAssertEqual(["Somewhere.","Specific.","CHART 10 Subject has something to say."], split2)
        
        let parser3 = NAVTEXTextParser(text: "   A. BOSTON (F) 41-42.8N 070-30.3W.\n   B. CHARLESTON (E) 32-50.7N 079-57.0W.\n   C. CHESAPEAKE (N) 36-43.7N 076-00.6W.\n   D. MIAMI (A) 25-37.4N 080-23.4W.\n   E. NEW ORLEANS (G) 29-53.1N 089-56.7W.\n   F. SAN JUAN (R) 18-27.00N 066-06.00W.\n")
        let split3 = parser3.splitSentences(string: parser3.text)
        XCTAssertEqual(["A.","BOSTON (F) 41-42.8N 070-30.3W.","B.","CHARLESTON (E) 32-50.7N 079-57.0W.","C.","CHESAPEAKE (N) 36-43.7N 076-00.6W.","D.","MIAMI (A) 25-37.4N 080-23.4W.","E.","NEW ORLEANS (G) 29-53.1N 089-56.7W.","F.","SAN JUAN (R) 18-27.00N 066-06.00W."], split3)
        
        let parser4 = NAVTEXTextParser(text: "1. BROADCAST AND COMMUNICATION SERVICES UNRELIABLE\n   1200Z TO 1400Z DAILY 18 AND 19 APR\n   AT USCG REMOTE COMMUNICATION FACILITIES:")
        let split4 = parser4.splitSentences(string: parser4.text)
        XCTAssertEqual(["1.","BROADCAST AND COMMUNICATION SERVICES UNRELIABLE 1200Z TO 1400Z DAILY 18 AND 19 APR AT USCG REMOTE COMMUNICATION FACILITIES:."], split4)
    }
    
    func testSplitChart() {
        let parser = NAVTEXTextParser(text: "Somewhere.\nSpecific.\nCHART 10\nSubject has something to say.\n")
        parser.chart = "CHART 10"
        let split = parser.splitChartFromLine(line: "CHART 10 Subject has something to say.")
        XCTAssertEqual("Subject has something to say.", split)
        parser.chart = nil
        let split2 = parser.splitChartFromLine(line: "Subject has something to say.")
        XCTAssertEqual("Subject has something to say.", split2)
        parser.dnc = "DNC 10"
        let split3 = parser.splitChartFromLine(line: "DNC 10. Subject has something to say.")
        XCTAssertEqual("Subject has something to say.", split3)
        parser.dnc = "DNC 10"
        let split4 = parser.splitChartFromLine(line: "DNC 10.")
        XCTAssertEqual("", split4)
    }
    
    func testParseHeading() {
        let parser = NAVTEXTextParser(text: "NETHERLANDS ANTILLES.\nNAVTEX STATION CURACAO (H)\n12-10.31N 068-51.82W OFF AIR.\n")
        parser.parseHeading(heading: ["NETHERLANDS ANTILLES.","NAVTEX STATION CURACAO (H) 12-10.31N 068-51.82W OFF AIR."])
        
        XCTAssertEqual("NETHERLANDS ANTILLES.", parser.areaName)
        XCTAssertEqual("NAVTEX STATION CURACAO (H) 12-10.31N 068-51.82W OFF AIR.", parser.specificArea)
        XCTAssertEqual(1, parser.locations.count)
        XCTAssertEqual("Point", parser.locations[0].locationType)
        XCTAssertEqual("12-10.31N 068-51.82W", parser.locations[0].location[0])
    }
}
