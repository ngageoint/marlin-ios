//
//  NavigationalWarning+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/22.
//

import Foundation
import CoreData
import OSLog
import MapKit
import SwiftUI

struct NavigationalWarningNavArea: Equatable {
    let name: String
    let display: String
    let color: UIColor
}

extension NavigationalWarningNavArea {
    static let HYDROPAC = NavigationalWarningNavArea(name: "P", display: "HYDROPAC", color: UIColor(argbValue: 0xFFF5F481))
    static let HYDROARC = NavigationalWarningNavArea(name: "C", display: "HYDROARC", color: UIColor(argbValue: 0xFF77DFFC))
    static let HYDROLANT = NavigationalWarningNavArea(name: "A", display: "HYDROLANT", color: UIColor(argbValue: 0xFF7C91F2))
    static let NAVAREA_IV = NavigationalWarningNavArea(name: "4", display: "NAVAREA IV", color: UIColor(argbValue: 0xFFFDBFBF))
    static let NAVAREA_XII = NavigationalWarningNavArea(name: "12", display: "NAVAREA XII", color: UIColor(argbValue: 0xFF8BCC6B))
    
    static func areas() -> [NavigationalWarningNavArea] {
        return [NavigationalWarningNavArea.HYDROPAC, NavigationalWarningNavArea.HYDROARC, NavigationalWarningNavArea.HYDROLANT, NavigationalWarningNavArea.NAVAREA_IV, NavigationalWarningNavArea.NAVAREA_XII]
    }
    
    static func fromId(id: String) -> NavigationalWarningNavArea? {
        for area in NavigationalWarningNavArea.areas() {
            if id == area.name {
                return area
            }
        }
        return nil
    }
}

class NavigationalWarning: NSManagedObject {
    
    var primaryKey: String {
        return "\(self.navArea ?? "") \(self.msgNumber)/\(self.msgYear)"
    }
    
    var dateString: String? {
        if let date = issueDate {
            return NavigationalWarningProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var cancelDateString: String? {
        if let date = cancelDate {
            return NavigationalWarningProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    var navAreaName: String {
        guard let navArea = navArea else {
            return ""
        }
        
        if let navAreaEnum = NavigationalWarningNavArea.fromId(id: navArea) {
            return navAreaEnum.display
        }
        return ""
    }
    
    override var description: String {
        return "Navigational Warning\n\n" +
        "\(dateString ?? "")}\n\n" +
        "\(navAreaName) \(msgNumber)/\(msgYear) (\(subregion ?? ""))\n\n" +
        "\(text ?? "")\n\n" +
        "Status: \(status ?? "")\n" +
        "Authority: \(authority ?? "")\n" +
        "Cancel Date: \(cancelDateString ?? "")\n" +
        "Cancel Year: \(cancelMsgNumber)\n" +
        "Cancel Year: \(cancelMsgYear)\n"

    }
}
