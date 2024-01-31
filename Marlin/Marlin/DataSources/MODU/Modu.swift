//
//  Modu+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import Foundation
import CoreData
import OSLog
import MapKit
import SwiftUI

class Modu: NSManagedObject {
    var clusteringIdentifierWhenShrunk: String? = "msi"
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifier: String? = "msi"
    
    var color: UIColor {
        return DataSources.modu.color
    }
    
    var annotationView: MKAnnotationView?
    
    var dateString: String? {
        if let date = date {
            return DataSources.modu.dateFormatter.string(from: date)
        }
        return nil
    }
    
    override var description: String {
        return "MODU\n\n" +
        "Name: \(name ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Position: \(position ?? "")\n" +
        "Rig Status: \(rigStatus ?? "")\n" +
        "Special Status: \(specialStatus ?? "")\n" +
        "distance: \(distance)\n" +
        "Navigation Area: \(navArea ?? "")\n" +
        "Region: \(region)\n" +
        "Sub Region: \(subregion)\n"
    }
}
