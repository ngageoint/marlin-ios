//
//  Asam+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/2/22.
//
//

import Foundation
import CoreData
import MapKit
import CoreData
import GeoJSON

class Asam: NSManagedObject, EnlargableAnnotation {
    var clusteringIdentifierWhenShrunk: String? = "msi"
    
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifier: String? = "msi"
    
    var color: UIColor {
        return Asam.color
    }
    
    var annotationView: MKAnnotationView?
    
    var dateString: String? {
        if let date = date {
            return Asam.dateFormatter.string(from: date)
        }
        return nil
    }
    
    override var description: String {
        return "ASAM\n\n" +
        "Reference: \(reference ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Navigation Area: \(navArea ?? "")\n" +
        "Subregion: \(subreg ?? "")\n" +
        "Description: \(asamDescription ?? "")\n" +
        "Hostility: \(hostility ?? "")\n" +
        "Victim: \(victim ?? "")\n"
    }
}
