//
//  DifferentialGPSStation+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import UIKit
import CoreData
import MapKit
import OSLog
import SwiftUI

class DifferentialGPSStation: NSManagedObject {
        
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: "\(featureNumber)"),
            KeyValue(key: "Name & Location", value: name),
            KeyValue(key: "Geopolitical Heading", value: geopoliticalHeading),
            KeyValue(key: "Position", value: position),
            KeyValue(key: "Station ID", value: stationID),
            KeyValue(key: "Range (nmi)", value: "\(range)"),
            KeyValue(key: "Frequency (kHz)", value: "\(frequency)"),
            KeyValue(key: "Transfer Rate", value: "\(transferRate)"),
            KeyValue(key: "Remarks", value: "\(remarks ?? "")"),
            KeyValue(key: "Notice Number", value: "\(noticeNumber)"),
            KeyValue(key: "Preceding Note", value: precedingNote),
            KeyValue(key: "Post Note", value: postNote)
        ]
    }
    
    var annotationView: MKAnnotationView?
    
    override var description: String {
        return "Differential GPS Station\n\n" +
        "aidType \(aidType ?? "")\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber)\n" +
        "frequency \(frequency)\n" +
        "geopoliticalHeading \(geopoliticalHeading ?? "")\n" +
        "latitude \(latitude)\n" +
        "longitude \(longitude)\n" +
        "name \(name ?? "")\n" +
        "noticeNumber \(noticeNumber)\n" +
        "noticeWeek \(noticeWeek ?? "")\n" +
        "noticeYear \(noticeYear ?? "")\n" +
        "position \(position ?? "")\n" +
        "postNote \(postNote ?? "")\n" +
        "precedingNote \(precedingNote ?? "")\n" +
        "range \(range)\n" +
        "remarks \(remarks ?? "")\n" +
        "regionHeading \(regionHeading ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "stationID \(stationID ?? "")\n" +
        "transferRate \(transferRate)\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}
