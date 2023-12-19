//
//  RadioBeacon+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/25/22.
//

import Foundation
import CoreData
import MapKit
import OSLog
import SwiftUI

struct RadioBeaconVolume {
    var volumeQuery: String
    var volumeNumber: String
}

class RadioBeacon: NSManagedObject {
    
    var clusteringIdentifier: String?
    
    static let radioBeaconVolumes = [
        RadioBeaconVolume(volumeQuery: "110", volumeNumber: "PUB 110"),
        RadioBeaconVolume(volumeQuery: "111", volumeNumber: "PUB 111"),
        RadioBeaconVolume(volumeQuery: "112", volumeNumber: "PUB 112"),
        RadioBeaconVolume(volumeQuery: "113", volumeNumber: "PUB 113"),
        RadioBeaconVolume(volumeQuery: "114", volumeNumber: "PUB 114"),
        RadioBeaconVolume(volumeQuery: "115", volumeNumber: "PUB 115"),
        RadioBeaconVolume(volumeQuery: "116", volumeNumber: "PUB 116")
    ]
    
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: "\(featureNumber)"),
            KeyValue(key: "Name & Location", value: name),
            KeyValue(key: "Geopolitical Heading", value: geopoliticalHeading),
            KeyValue(key: "Position", value: "\(position ?? "")"),
            KeyValue(key: "Characteristic", value: expandedCharacteristic),
            KeyValue(key: "Range (nmi)", value: "\(range)"),
            KeyValue(key: "Sequence", value: sequenceText),
            KeyValue(key: "Frequency (kHz)", value: frequency),
            KeyValue(key: "Remarks", value: stationRemark)
        ]
    }
    
    var expandedCharacteristicWithoutCode: String? {
        guard let characteristic = characteristic, let range = characteristic.range(of: ").\\n") else {
            return nil
        }
        
        let lastIndex = range.upperBound
        
        var withoutCode = "\(String(characteristic[lastIndex..<characteristic.endIndex]))"
        withoutCode = withoutCode.replacingOccurrences(of: "aero", with: "aeronautical")
        withoutCode = withoutCode.replacingOccurrences(of: "si", with: "silence")
        withoutCode = withoutCode.replacingOccurrences(of: "tr", with: "transmission")
        return withoutCode
    }
    
    var expandedCharacteristic: String? {
        var expanded = characteristic
        expanded = expanded?.replacingOccurrences(of: "aero", with: "aeronautical")
        expanded = expanded?.replacingOccurrences(of: "si", with: "silence")
        expanded = expanded?.replacingOccurrences(of: "tr", with: "transmission")
        return expanded
    }
    
    var morseCode: String? {
        guard let characteristic = characteristic, let leftParen = characteristic.firstIndex(of: "("), let lastIndex = characteristic.firstIndex(of: ")") else {
            return nil
        }
        
        let firstIndex = characteristic.index(after: leftParen)
        return "\(String(characteristic[firstIndex..<lastIndex]))"
    }
    
    var morseLetter: String {
        guard let characteristic = characteristic, let newline = characteristic.firstIndex(of: "\n") else {
            return ""
        }
        
        return "\(String(characteristic[characteristic.startIndex..<newline]))"
    }
    
    var azimuthCoverage: [ImageSector]? {
        guard let remarks = stationRemark else {
            return nil
        }
        var sectors: [ImageSector] = []
        let pattern = #"(?<azimuth>(Azimuth coverage)?).?((?<startdeg>(\d*))\^)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))\^)?(?<endminutes>[0-9]*)[\`']?\."#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0
        
        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, _, _ in
            guard let match = match else {
                return
            }
            var end: Double = 0.0
            var start: Double?
            for component in ["startdeg", "startminutes", "enddeg", "endminutes"] {
                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks) {
                    if component == "startdeg" {
                        if start != nil {
                            start = start! + ((Double(remarks[range]) ?? 0.0) - 90)
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) - 90
                        }
                    } else if component == "startminutes" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) / 60
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) / 60
                        }
                    } else if component == "enddeg" {
                        end = (Double(remarks[range]) ?? 0.0) - 90
                    } else if component == "endminutes" {
                        end += (Double(remarks[range]) ?? 0.0) / 60
                    }
                }
            }
            if let start = start {
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: RadioBeacon.color))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: RadioBeacon.color))
            }
            previousEnd = end
        })
        if sectors.isEmpty {
            return nil
        }
        return sectors
    }
    
    var annotationView: MKAnnotationView?
    
    override var description: String {
        return "RADIO BEACON\n\n" +
        "aidType \(aidType ?? "")\n" +
        "characteristic \(characteristic ?? "")\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber)\n" +
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
        "regionHeading \(regionHeading ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "sequenceText \(sequenceText ?? "")\n" +
        "stationRemark \(stationRemark ?? "")\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}
