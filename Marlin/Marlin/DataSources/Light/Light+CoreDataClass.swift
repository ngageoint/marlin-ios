//
//  Light+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import Foundation
import CoreData
import MapKit
import OSLog
import SwiftUI

struct LightVolume {
    var volumeQuery: String
    var volumeNumber: String
}

class Light: NSManagedObject {
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    static let lightVolumes = [
        LightVolume(volumeQuery: "110", volumeNumber: "PUB 110"),
        LightVolume(volumeQuery: "111", volumeNumber: "PUB 111"),
        LightVolume(volumeQuery: "112", volumeNumber: "PUB 112"),
        LightVolume(volumeQuery: "113", volumeNumber: "PUB 113"),
        LightVolume(volumeQuery: "114", volumeNumber: "PUB 114"),
        LightVolume(volumeQuery: "115", volumeNumber: "PUB 115"),
        LightVolume(volumeQuery: "116", volumeNumber: "PUB 116")
    ]
    
    static let whiteLight = UIColor(argbValue: 0xffffff00)
    static let greenLight = UIColor(argbValue: 0xff0de319)
    static let redLight = UIColor(argbValue: 0xfffa0000)
    static let yellowLight = UIColor(argbValue: 0xffffff00)
    static let blueLight = UIColor(argbValue: 0xff0000ff)
    static let violetLight = UIColor(argbValue: 0xffaf52de)
    static let orangeLight = UIColor(argbValue: 0xffff9500)
    static let raconColor = UIColor(argbValue: 0xffb52bb5)

    var color: UIColor {
        return Light.color
    }
    
    var isLight: Bool {
        guard let name = self.name else {
            return false
        }
        let remarks = remarks ?? ""
        return !name.contains("RACON") && !remarks.contains("(3 & 10cm)")
    }
    
    var isRacon: Bool {
        guard let name = self.name else {
            return false
        }
        let remarks = remarks ?? ""
        return name.contains("RACON") || remarks.contains("(3 & 10cm)")
    }
    
    var isBuoy: Bool {
        let structure = structure ?? ""
        return structure.lowercased().contains("pillar") ||
        structure.lowercased().contains("spar") ||
        structure.lowercased().contains("conical") ||
        structure.lowercased().contains("can")
    }

    
    var expandedCharacteristic: String? {
        var expanded = characteristic
        expanded = expanded?.replacingOccurrences(of: "Al.", with: "Alternating ")
        expanded = expanded?.replacingOccurrences(of: "lt.", with: "Lit ")
        expanded = expanded?.replacingOccurrences(of: "bl.", with: "Blast ")
        expanded = expanded?.replacingOccurrences(of: "Mo.", with: "Morse code ")
        expanded = expanded?.replacingOccurrences(of: "Bu.", with: "Blue ")
        expanded = expanded?.replacingOccurrences(of: "min.", with: "Minute ")
        expanded = expanded?.replacingOccurrences(of: "Dir.", with: "Directional ")
        expanded = expanded?.replacingOccurrences(of: "obsc.", with: "Obscured ")
        expanded = expanded?.replacingOccurrences(of: "ec.", with: "Eclipsed ")
        expanded = expanded?.replacingOccurrences(of: "Oc.", with: "Occulting ")
        expanded = expanded?.replacingOccurrences(of: "ev.", with: "Every ")
        expanded = expanded?.replacingOccurrences(of: "Or.", with: "Orange ")
        expanded = expanded?.replacingOccurrences(of: "F.", with: "Fixed ")
        expanded = expanded?.replacingOccurrences(of: "Q.", with: "Quick Flashing ")
        expanded = expanded?.replacingOccurrences(of: "L.Fl.", with: "Long Flashing ")
        expanded = expanded?.replacingOccurrences(of: "Fl.", with: "Flashing ")
        expanded = expanded?.replacingOccurrences(of: "R.", with: "Red ")
        expanded = expanded?.replacingOccurrences(of: "fl.", with: "Flash ")
        expanded = expanded?.replacingOccurrences(of: "s.", with: "Seconds ")
        expanded = expanded?.replacingOccurrences(of: "G.", with: "Green ")
        expanded = expanded?.replacingOccurrences(of: "si.", with: "Silent ")
        expanded = expanded?.replacingOccurrences(of: "horiz.", with: "Horizontal ")
        expanded = expanded?.replacingOccurrences(of: "U.Q.", with: "Ultra Quick ")
        expanded = expanded?.replacingOccurrences(of: "flashing intes.", with: "Intensified ")
        expanded = expanded?.replacingOccurrences(of: "I.Q.", with: "Interrupted Quick ")
        expanded = expanded?.replacingOccurrences(of: "flashing unintens.", with: "Unintensified ")
        expanded = expanded?.replacingOccurrences(of: "vert.", with: "Vertical ")
        expanded = expanded?.replacingOccurrences(of: "Iso.", with: "Isophase ")
        expanded = expanded?.replacingOccurrences(of: "Vi.", with: "Violet ")
        expanded = expanded?.replacingOccurrences(of: "I.V.Q.", with: "Interrupted Very Quick Flashing ")
        expanded = expanded?.replacingOccurrences(of: "vis.", with: "Visible ")
        expanded = expanded?.replacingOccurrences(of: "V.Q.", with: "Very Quick ")
        expanded = expanded?.replacingOccurrences(of: "Km.", with: "Kilometer ")
        expanded = expanded?.replacingOccurrences(of: "W.", with: "White ")
        expanded = expanded?.replacingOccurrences(of: "Y.", with: "Yellow ")
        return expanded
    }
    
    var lightSectors: [ImageSector]? {
        guard let remarks = remarks else {
            return nil
        }
        var sectors: [ImageSector] = []
        
        let pattern = #"(?<visible>(Visible)?)(?<fullLightObscured>(Partially obscured)?)((?<color>[A-Z]+)?)\.?(?<unintensified>(\(unintensified\))?)(?<obscured>(\(partially obscured\))?)( (?<startdeg>(\d*))°)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))°)(?<endminutes>[0-9]*)[\`']?"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0

        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, flags, stop in
            guard let match = match else {
                return
            }
            var color: String = ""
            var end: Double = 0.0
            var start: Double?
            var visibleColor: UIColor?
            var obscured: Bool = false
            var fullLightObscured: Bool = false
            for component in ["visible", "fullLightObscured", "color", "unintensified", "obscured", "startdeg", "startminutes", "enddeg", "endminutes"] {

                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks),
                   !range.isEmpty
                {
                    if component == "visible" {
                        visibleColor = lightColors?[0]
                    } else if component == "fullLightObscured" {
                        visibleColor = lightColors?[0]
                        fullLightObscured = true
                    } else if component == "color" {
                        color = "\(remarks[range])"
                    } else if component == "obscured" {
                        obscured = true
                    } else if component == "startdeg" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) + 90.0
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) + 90.0
                        }
                    } else if component == "startminutes" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) / 60
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) / 60
                        }
                    } else if component == "enddeg" {
                        end = (Double(remarks[range]) ?? 0.0) + 90.0
                    } else if component == "endminutes" {
                        end += (Double(remarks[range]) ?? 0.0) / 60
                    }
                }
            }
            let uicolor: UIColor = {
                if obscured || fullLightObscured {
                    return visibleColor ?? (lightColors?[0] ?? .black)
                } else if color == "W" {
                    return Light.whiteLight
                } else if color == "R" {
                    return Light.redLight
                } else if color == "G" {
                    return Light.greenLight
                }
                return visibleColor ?? (lightColors?[0] ?? UIColor.clear)
            }()
            var sectorRange: Double? = nil
            if let rangeString = range {
                for split in rangeString.split(separator: "\n") {
                    if split.starts(with: color) {
                        let pattern = #"[0-9]+$"#
                        let regex = try? NSRegularExpression(pattern: pattern, options: [])
                        let rangePart = "\(split)".trimmingCharacters(in: .whitespacesAndNewlines)
                        let match = regex?.firstMatch(in: rangePart, range: NSRange(rangePart.startIndex..<rangePart.endIndex, in: rangePart))
                        
                        if let nsrange = match?.range, nsrange.location != NSNotFound,
                           let matchRange = Range(nsrange, in: rangePart),
                           !matchRange.isEmpty
                        {
                            let colorRange = rangePart[matchRange]
                            if !colorRange.isEmpty {
                                sectorRange = Double(colorRange)
                            }
                        }
                    }
                }
            }
            if let start = start {
                if end < start {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: uicolor, text: color, obscured: obscured || fullLightObscured, range: sectorRange))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: uicolor, text: color, obscured: obscured || fullLightObscured, range: sectorRange))
            }
            if fullLightObscured {
                // add the sector for the part of the light which is not obscured
                sectors.append(ImageSector(startDegrees: end, endDegrees: (start ?? 0) + 360, color: visibleColor ?? (lightColors?[0] ?? UIColor.clear), range: sectorRange))
            }
            previousEnd = end
        })
        if sectors.isEmpty {
            return nil
        }
        return sectors
    }
    
    var morseCode: String? {
        guard !isLight, let characteristic = characteristic, let leftParen = characteristic.firstIndex(of: "("), let lastIndex = characteristic.lastIndex(of: ")") else {
            return nil
        }
        
        let firstIndex = characteristic.index(after: leftParen)
        return "\(String(characteristic[firstIndex..<lastIndex]))"
    }
    
    var morseLetter: String {
        if isLight {
            return ""
        }
        if let first = characteristic?.first {
            return String(first)
        }
        return ""
    }

    let TILE_SIZE = 512.0
    
    var azimuthCoverage: [ImageSector]? {
        guard let remarks = remarks else {
            return nil
        }
        var sectors: [ImageSector] = []
        //        Azimuth coverage 270^-170^.
        let pattern = #"(?<azimuth>(Azimuth coverage)?).?((?<startdeg>(\d*))\°)?((?<startminutes>[0-9]*)[\`'])?(-(?<enddeg>(\d*))\°)?(?<endminutes>[0-9]*)[\`']?\..*"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(remarks.startIndex..<remarks.endIndex,
                              in: remarks)
        var previousEnd: Double = 0.0
        
        regex?.enumerateMatches(in: remarks, range: nsrange, using: { match, flags, stop in
            guard let match = match else {
                return
            }
            var end: Double = 0.0
            var start: Double?
            for component in ["startdeg", "startminutes", "enddeg", "endminutes"] {
                
                
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: remarks)
                {
                    if component == "startdeg" {
                        if start != nil {
                            start = start! + ((Double(remarks[range]) ?? 0.0) + 90)
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) + 90
                        }
                    } else if component == "startminutes" {
                        if start != nil {
                            start = start! + (Double(remarks[range]) ?? 0.0) / 60
                        } else {
                            start = (Double(remarks[range]) ?? 0.0) / 60
                        }
                    } else if component == "enddeg" {
                        end = (Double(remarks[range]) ?? 0.0) + 90
                    } else if component == "endminutes" {
                        end += (Double(remarks[range]) ?? 0.0) / 60
                    }
                }
            }
            if let start = start {
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: Light.raconColor))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: Light.raconColor))
            }
            previousEnd = end
        })
        if sectors.isEmpty {
            return nil
        }
        return sectors
    }
    
    var isFogSignal: Bool {
        guard let remarks = remarks else {
            return false
        }
        return remarks.lowercased().contains("bl.")
    }
    
    var lightColors: [UIColor]? {
        var lightColors: [UIColor] = []
        guard let characteristic = characteristic else {
            return nil
        }
        
        if characteristic.contains("W.") {
            lightColors.append(Light.whiteLight)
        }
        if characteristic.contains("R.") {
            lightColors.append(Light.redLight)
        }
        // why does green have so many variants without a .?
        if characteristic.contains("G.") || characteristic.contains("Oc.G") || characteristic.contains("G\n") || characteristic.contains("F.G") || characteristic.contains("Fl.G") || characteristic.contains("(G)") {
            lightColors.append(Light.greenLight)
        }
        if characteristic.contains("Y.") {
            lightColors.append(Light.yellowLight)
        }
        if characteristic.contains("Bu.") {
            lightColors.append(Light.blueLight)
        }
        if characteristic.contains("Vi.") {
            lightColors.append(Light.violetLight)
        }
        if characteristic.contains("Or.") {
            lightColors.append(Light.orangeLight)
        }
        
        if lightColors.isEmpty {
            if characteristic.lowercased().contains("lit") {
                lightColors.append(Light.whiteLight)
            }
        }
        
        if lightColors.isEmpty {
            return nil
        }
        return lightColors
    }
    
    func isSame(_ other: Light) -> Bool {
        return other.featureNumber == featureNumber && other.volumeNumber == volumeNumber
    }
    
    var annotationView: MKAnnotationView?
    
    override var description: String {
        return "LIGHT\n\n" +
        "aidType \(aidType ?? "")\n" +
        "characteristic \(characteristic ?? "")\n" +
        "characteristicNumber \(characteristicNumber)\n" +
        "deleteFlag \(deleteFlag ?? "")\n" +
        "featureNumber \(featureNumber ?? "")\n" +
        "geopoliticalHeading \(geopoliticalHeading ?? "")\n" +
        "heightFeet \(heightFeet)\n" +
        "heightMeters \(heightMeters)\n" +
        "internationalFeature \(internationalFeature ?? "")\n" +
        "localHeading \(localHeading ?? "")\n" +
        "name \(name ?? "")\n" +
        "noticeNumber \(noticeNumber)\n" +
        "noticeWeek \(noticeWeek ?? "")\n" +
        "noticeYear \(noticeYear ?? "")\n" +
        "position \(position ?? "")\n" +
        "postNote \(postNote ?? "")\n" +
        "precedingNote \(precedingNote ?? "")\n" +
        "range \(range ?? "")\n" +
        "regionHeading \(regionHeading ?? "")\n" +
        "remarks \(remarks ?? "")\n" +
        "removeFromList \(removeFromList ?? "")\n" +
        "structure \(structure ?? "")\n" +
        "subregionHeading \(subregionHeading ?? "")\n" +
        "volumeNumber \(volumeNumber ?? "")"
    }
}
