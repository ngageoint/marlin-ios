//
//  DFRS+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import OSLog

class DFRS: NSManagedObject {

    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: stationNumber),
            KeyValue(key: "Name", value: stationName),
            KeyValue(key: "Area Name", value: areaName),
            KeyValue(key: "Type", value: stationType),
            KeyValue(key: "Rx Position", value: rxPosition),
            KeyValue(key: "Tx Position", value: txPosition),
            KeyValue(key: "Frequency (kHz)", value: frequency),
            KeyValue(key: "Range (nmi)", value: range == 0.0 ? "" : "\(range)"),
            KeyValue(key: "Procedure", value: procedureText),
            KeyValue(key: "Remarks", value: remarks),
            KeyValue(key: "Notes", value: notes)
        ]
    }
    
    var txCoordinate: CLLocationCoordinate2D {
        if txPosition == nil {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: txLatitude, longitude: txLongitude)
    }
    
    var rxCoordinate: CLLocationCoordinate2D {
        if rxPosition == nil {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: rxLatitude, longitude: rxLongitude)
    }
    
    var annotationView: MKAnnotationView?
    
    override var description: String {
        return "DFRS\n\n" +
        "Area Name: \(areaName ?? "")\n" +
        "frequency: \(frequency ?? "")\n" +
        "notes: \(notes ?? "")\n" +
        "procedure text: \(procedureText ?? "")\n" +
        "range: \(range)\n" +
        "remarks: \(remarks ?? "")\n" +
        "rx position: \(rxPosition ?? "")\n" +
        "station name: \(stationName ?? "")\n" +
        "station number: \(stationNumber ?? "")\n" +
        "station type: \(stationType ?? "")\n" +
        "tx position: \(txPosition ?? "")\n"
    }
}

class DFRSArea: NSManagedObject {
    
}
