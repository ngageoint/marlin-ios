//
//  Port+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/16/22.
//

import Foundation
import MapKit
import CoreData
import OSLog
import SwiftUI

class Port: NSManagedObject {
    var annotationView: MKAnnotationView?
    
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    func distanceTo(_ location: CLLocation) -> Double {
        location.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    var nameAndLocationKeyValues: [KeyValue] {
        return [
            KeyValue(key: "World Port Index Number", value: "\(portNumber)"),
            KeyValue(key: "Region Name", value: "\(regionName ?? "") - \(regionNumber)"),
            KeyValue(key: "Main Port Name", value: portName),
            KeyValue(key: "Alternate Port Name", value: alternateName),
            KeyValue(key: "UN/LOCODE", value: unloCode),
            KeyValue(key: "Country", value: countryName),
            KeyValue(key: "World Water Body", value: dodWaterBody),
            KeyValue(key: "Sailing Directions or Publication", value: publicationNumber),
            KeyValue(key: "Standard Nautical Chart", value: chartNumber),
            KeyValue(key: "IHO S-57 Electronic Navigational Chart", value: s57Enc),
            KeyValue(key: "IHO S-101 Electronic Navigational Chart", value: s101Enc),
            KeyValue(key: "Digital Nautical Chart", value: dnc)
        ]
    }
    
    var depthKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Tidal Range (m)", value: "\(tide.zeroIsEmptyString)"),
            KeyValue(key: "Entrance Width (m)", value: "\(entranceWidth.zeroIsEmptyString)"),
            KeyValue(key: "Channel Depth (m)", value: "\(channelDepth.zeroIsEmptyString)"),
            KeyValue(key: "Anchorage Depth (m)", value: "\(anchorageDepth.zeroIsEmptyString)"),
            KeyValue(key: "Cargo Pier Depth (m)", value: "\(cargoPierDepth.zeroIsEmptyString)"),
            KeyValue(key: "Oil Terminal Depth (m)", value: "\(oilTerminalDepth.zeroIsEmptyString)"),
            KeyValue(key: "Liquified Natural Gas Terminal Depth (m)", value: "\(liquifiedNaturalGasTerminalDepth.zeroIsEmptyString)")
        ]
    }
    
    var maximumVesselSizeKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Maximum Vessel Length (m)", value: "\(maxVesselLength.zeroIsEmptyString)"),
            KeyValue(key: "Maximum Vessel Beam (m)", value: "\(maxVesselBeam.zeroIsEmptyString)"),
            KeyValue(key: "Maximum Vessel Draft (m)", value: "\(maxVesselDraft.zeroIsEmptyString)"),
            KeyValue(key: "Offshore Maximum Vessel Length (m)", value: "\(offshoreMaxVesselLength.zeroIsEmptyString)"),
            KeyValue(key: "Offshore Maximum Vessel Beam (m)", value: "\(offshoreMaxVesselBeam.zeroIsEmptyString)"),
            KeyValue(key: "Offshore Maximum Vessel Draft (m)", value: "\(offshoreMaxVesselDraft.zeroIsEmptyString)")
        ]
    }
    
    var physicalEnvironmentKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Harbor Size", value: "\(SizeEnum.fromValue(harborSize))"),
            KeyValue(key: "Harbor Type", value: "\(HarborTypeEnum.fromValue(harborType))"),
            KeyValue(key: "Harbor Use", value: "\(HarborUseEnum.fromValue(harborUse))"),
            KeyValue(key: "Shelter", value: "\(ConditionEnum.fromValue(shelter))"),
            KeyValue(key: "Entrance Restriction - Tide", value: "\(DecisionEnum.fromValue(erTide))"),
            KeyValue(key: "Entrance Restriction - Heavy Swell", value: "\(DecisionEnum.fromValue(erSwell))"),
            KeyValue(key: "Entrance Restriction - Ice", value: "\(DecisionEnum.fromValue(erIce))"),
            KeyValue(key: "Entrance Restriction - Other", value: "\(DecisionEnum.fromValue(erOther))"),
            KeyValue(key: "Overhead Limits", value: "\(DecisionEnum.fromValue(overheadLimits))"),
            KeyValue(key: "Underkeel Clearance Management System", value: "\(UnderkeelClearanceEnum.fromValue(ukcMgmtSystem))"),
            KeyValue(key: "Good Holding Ground", value: "\(DecisionEnum.fromValue(goodHoldingGround))"),
            KeyValue(key: "Turning Area", value: "\(DecisionEnum.fromValue(turningArea))")
        ]
    }
    
    var approachKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Port Security", value: "\(DecisionEnum.fromValue(portSecurity))"),
            KeyValue(key: "Estimated Time Of Arrival Message", value: "\(DecisionEnum.fromValue(etaMessage))"),
            KeyValue(key: "Quarantine - Pratique", value: "\(DecisionEnum.fromValue(qtPratique))"),
            KeyValue(key: "Quarantine - Sanitation", value: "\(DecisionEnum.fromValue(qtSanitation))"),
            KeyValue(key: "Quarantine - Other", value: "\(DecisionEnum.fromValue(qtOther))"),
            KeyValue(key: "Traffic Separation Scheme", value: "\(DecisionEnum.fromValue(trafficSeparationScheme))"),
            KeyValue(key: "Vessel Traffic Service", value: "\(DecisionEnum.fromValue(vesselTrafficService))"),
            KeyValue(key: "First Port Of Entry", value: "\(DecisionEnum.fromValue(firstPortOfEntry))"),
        ]
    }
    
    var pilotsTugsCommunicationsKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Pilotage - Compulsory", value: "\(DecisionEnum.fromValue(ptCompulsory))"),
            KeyValue(key: "Pilotage - Available", value: "\(DecisionEnum.fromValue(ptAvailable))"),
            KeyValue(key: "Pilotage - Local Assistance", value: "\(DecisionEnum.fromValue(ptLocalAssist))"),
            KeyValue(key: "Pilotage - Advisable", value: "\(DecisionEnum.fromValue(ptAdvisable))"),
            KeyValue(key: "Tugs - Salvage", value: "\(DecisionEnum.fromValue(tugsSalvage))"),
            KeyValue(key: "Tugs - Assistance", value: "\(DecisionEnum.fromValue(tugsAssist))"),
            KeyValue(key: "Communications - Telephone", value: "\(DecisionEnum.fromValue(cmTelephone))"),
            KeyValue(key: "Communications - Telefax", value: "\(DecisionEnum.fromValue(cmTelegraph))"),
            KeyValue(key: "Communications - Radio", value: "\(DecisionEnum.fromValue(cmRadio))"),
            KeyValue(key: "Communications - Radiotelephone", value: "\(DecisionEnum.fromValue(cmRadioTel))"),
            KeyValue(key: "Communications - Airport", value: "\(DecisionEnum.fromValue(cmAir))"),
            KeyValue(key: "Communications - Rail", value: "\(DecisionEnum.fromValue(cmRail))"),
            KeyValue(key: "Search and Rescue", value: "\(DecisionEnum.fromValue(searchAndRescue))"),
            KeyValue(key: "NAVAREA", value: navArea),
        ]
    }
    
    var facilitiesKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Facilities - Wharves", value: "\(DecisionEnum.fromValue(loWharves))"),
            KeyValue(key: "Facilities - Anchorage", value: "\(DecisionEnum.fromValue(loAnchor))"),
            KeyValue(key: "Facilities - Dangerous Cargo Anchorage", value: "\(DecisionEnum.fromValue(loDangCargo))"),
            KeyValue(key: "Facilities - Med Mooring", value: "\(DecisionEnum.fromValue(loMedMoor))"),
            KeyValue(key: "Facilities - Beach Mooring", value: "\(DecisionEnum.fromValue(loBeachMoor))"),
            KeyValue(key: "Facilities - Ice Mooring", value: "\(DecisionEnum.fromValue(loIceMoor))"),
            KeyValue(key: "Facilities - RoRo", value: "\(DecisionEnum.fromValue(loRoro))"),
            KeyValue(key: "Facilities - Solid Bulk", value: "\(DecisionEnum.fromValue(loSolidBulk))"),
            KeyValue(key: "Facilities - Liquid Bulk", value: "\(DecisionEnum.fromValue(loLiquidBulk))"),
            KeyValue(key: "Facilities - Container", value: "\(DecisionEnum.fromValue(loContainer))"),
            KeyValue(key: "Facilities - Breakbulk", value: "\(DecisionEnum.fromValue(loBreakBulk))"),
            KeyValue(key: "Facilities - Oil Terminal", value: "\(DecisionEnum.fromValue(loOilTerm))"),
            KeyValue(key: "Facilities - LNG Terminal", value: "\(DecisionEnum.fromValue(loLongTerm))"),
            KeyValue(key: "Facilities - Other", value: "\(DecisionEnum.fromValue(loOther))"),
            KeyValue(key: "Medical Facilities", value: "\(DecisionEnum.fromValue(medFacilities))"),
            KeyValue(key: "Garbage Disposal", value: "\(DecisionEnum.fromValue(garbageDisposal))"),
            KeyValue(key: "Chemical Holding Tank Disposal", value: "\(DecisionEnum.fromValue(chemicalHoldingTank))"),
            KeyValue(key: "Degaussing", value: "\(DecisionEnum.fromValue(degauss))"),
            KeyValue(key: "Dirty Ballast Disposal", value: "\(DecisionEnum.fromValue(dirtyBallast))"),
        ]
    }
    
    var cranesKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Cranes - Fixed", value: "\(DecisionEnum.fromValue(craneFixed))"),
            KeyValue(key: "Cranes - Mobile", value: "\(DecisionEnum.fromValue(craneMobile))"),
            KeyValue(key: "Cranes - Floating", value: "\(DecisionEnum.fromValue(craneFloating))"),
            KeyValue(key: "Cranes - Container", value: "\(DecisionEnum.fromValue(craneContainer))"),
            KeyValue(key: "Lifts - 100+ Tons", value: "\(DecisionEnum.fromValue(lifts100))"),
            KeyValue(key: "Lifts - 50-100 Tons", value: "\(DecisionEnum.fromValue(lifts50))"),
            KeyValue(key: "Lifts - 25-49 Tons", value: "\(DecisionEnum.fromValue(lifts25))"),
            KeyValue(key: "Lifts - 0-24 Tons", value: "\(DecisionEnum.fromValue(lifts0))"),
        ]
    }
    
    var servicesSuppliesKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Services - Longshoremen", value: "\(DecisionEnum.fromValue(srLongshore))"),
            KeyValue(key: "Services - Electricity", value: "\(DecisionEnum.fromValue(srElectrical))"),
            KeyValue(key: "Services - Steam", value: "\(DecisionEnum.fromValue(srSteam))"),
            KeyValue(key: "Services - Navigational Equipment", value: "\(DecisionEnum.fromValue(srNavigationalEquipment))"),
            KeyValue(key: "Services - Electrical Repair", value: "\(DecisionEnum.fromValue(srElectricalRepair))"),
            KeyValue(key: "Services - Ice Breaking", value: "\(DecisionEnum.fromValue(srIceBreaking))"),
            KeyValue(key: "Services - Diving", value: "\(DecisionEnum.fromValue(srDiving))"),
            KeyValue(key: "Supplies - Provisions", value: "\(DecisionEnum.fromValue(suProvisions))"),
            KeyValue(key: "Supplies - Potable Water", value: "\(DecisionEnum.fromValue(suWater))"),
            KeyValue(key: "Supplies - Fuel Oil", value: "\(DecisionEnum.fromValue(suFuel))"),
            KeyValue(key: "Supplies - Diesel Oil", value: "\(DecisionEnum.fromValue(suDiesel))"),
            KeyValue(key: "Supplies - Aviation Fuel", value: "\(DecisionEnum.fromValue(suAviationFuel))"),
            KeyValue(key: "Supplies - Deck", value: "\(DecisionEnum.fromValue(suDeck))"),
            KeyValue(key: "Supplies - Engine", value: "\(DecisionEnum.fromValue(suEngine))"),
            KeyValue(key: "Repair Code", value: "\(RepairCodeEnum.fromValue(repairCode))"),
            KeyValue(key: "Dry Dock", value: "\(DecisionEnum.fromValue(drydock))"),
            KeyValue(key: "Railway", value: "\(SizeEnum.fromValue(railway))"),
        ]
    }
    
    override var description: String {
        return "Port\n\n" +
        "World Port Index Number: \(portNumber)\n"
    }
}

enum SizeEnum: String, CaseIterable, CustomStringConvertible {
    case V
    case S
    case M
    case L
    case unknown
    
    static func fromValue(_ value: String?) -> SizeEnum {
        guard let value = value else {
            return .unknown
        }
        return SizeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .V:
            return "Very Small"
        case .S:
            return "Small"
        case .M:
            return "Medium"
        case .L:
            return "Large"
        case .unknown:
            return ""
        }
    }

    static var keyValueMap: [String: [String]] {
        SizeEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

enum DecisionEnum: String, CaseIterable, CustomStringConvertible {
    case Y
    case N
    case U
    case UNK
    case unknown
    
    static func fromValue(_ value: String?) -> DecisionEnum {
        guard let value = value else {
            return .unknown
        }
        return DecisionEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .Y:
            return "Yes"
        case .N:
            return "No"
        default:
            return "Unknown"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        DecisionEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

enum RepairCodeEnum: String, CaseIterable, CustomStringConvertible {
    case A
    case B
    case C
    case D
    case N
    case unknown
    
    static func fromValue(_ value: String?) -> RepairCodeEnum {
        guard let value = value else {
            return .unknown
        }
        return RepairCodeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .A:
            return "Major"
        case .B:
            return "Moderate"
        case .C:
            return "Limited"
        case .D:
            return "Emergency Only"
        case .N:
            return "None"
        default:
            return "Unknown"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        RepairCodeEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

enum HarborTypeEnum: String, CaseIterable, CustomStringConvertible {
    case CB
    case CN
    case CT
    case LC
    case OR
    case RB
    case RN
    case RT
    case TH
    case unknown
    
    static func fromValue(_ value: String?) -> HarborTypeEnum {
        guard let value = value else {
            return .unknown
        }
        return HarborTypeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .CB:
            return "Coastal Breakwater"
        case .CN:
            return "Coastal Natural"
        case .CT:
            return "Coastal Tide Gate"
        case .LC:
            return "Lake or Canal"
        case .OR:
            return "Open Roadstead"
        case .RB:
            return "River Basin"
        case .RN:
            return "River Natural"
        case .RT:
            return "River Tide Gate"
        case .TH:
            return "Typhoon Harbor"
        default:
            return "Unknown"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        HarborTypeEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

enum HarborUseEnum: String, CaseIterable, CustomStringConvertible {
    case FISH
    case MIL
    case CARGO
    case FERRY
    case UNK
    case unknown
    
    static func fromValue(_ value: String?) -> HarborUseEnum {
        guard let value = value else {
            return .unknown
        }
        return HarborUseEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .FISH:
            return "Fishing"
        case .MIL:
            return "Military"
        case .CARGO:
            return "Cargo"
        case .FERRY:
            return "Ferry"
        case .UNK:
            return "Unknown"
        default:
            return "Unknown"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        HarborUseEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

enum UnderkeelClearanceEnum: String, CaseIterable, CustomStringConvertible {
    case S
    case D
    case N
    case U
    case unknown
    
    static func fromValue(_ value: String?) -> UnderkeelClearanceEnum {
        guard let value = value else {
            return .unknown
        }
        return UnderkeelClearanceEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .S:
            return "Static"
        case .D:
            return "Dynamic"
        case .N:
            return "None"
        case .U:
            return "Unknown"
        default:
            return "Unknown"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        UnderkeelClearanceEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

enum ConditionEnum: String, CaseIterable, CustomStringConvertible {
    case E
    case G
    case F
    case P
    case N
    case unknown
    
    static func fromValue(_ value: String?) -> ConditionEnum {
        guard let value = value else {
            return .unknown
        }
        return ConditionEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .E:
            return "Excellent"
        case .G:
            return "Good"
        case .F:
            return "Fair"
        case .P:
            return "Poor"
        case .N:
            return "None"
        default:
            return ""
        }
    }
    
    static var keyValueMap: [String: [String]] {
        ConditionEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append($1.rawValue)
            return $0[$1.description] = array
        }
    }
}

extension Int {
    var zeroIsEmptyString: String {
        if self == 0 {
            return ""
        }
        return "\(self)"
    }
}

extension Int64 {
    var zeroIsEmptyString: String {
        if self == 0 {
            return ""
        }
        return "\(self)"
    }
}

extension Double {
    var zeroIsEmptyString: String {
        if self == 0.0 {
            return ""
        }
        return "\(self)"
    }
}

extension Float {
    var zeroIsEmptyString: String {
        if self == 0.0 {
            return ""
        }
        return "\(self)"
    }
}

