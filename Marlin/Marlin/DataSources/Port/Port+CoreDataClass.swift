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
    override var description: String {
        return "Port\n\n" +
        "World Port Index Number: \(portNumber)\n"
    }
}

// disable linting as these case names come from the MSI data
// swiftlint:disable identifier_name
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
// swiftlint:enable identifier_name

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
