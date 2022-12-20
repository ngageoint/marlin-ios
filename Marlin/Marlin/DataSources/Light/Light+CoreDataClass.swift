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
import Kingfisher

struct LightVolume {
    var volumeQuery: String
    var volumeNumber: String
}

class Light: NSManagedObject, LightProtocol {
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
    
    static func postProcess() {
        DispatchQueue.global(qos: .utility).async {
            let fetchRequest = NSFetchRequest<Light>(entityName: "Light")
            fetchRequest.predicate = NSPredicate(format: "requiresPostProcessing == true")
            let context = PersistenceController.current.newTaskContext()
            
            if let objects = try? context.fetch(fetchRequest) {
                if !objects.isEmpty {
                    context.performAndWait {
                        for light in objects {
                            var ranges: [LightRange] = []
                            light.requiresPostProcessing = false
                            if let rangeString = light.range {
                                for rangeSplit in rangeString.components(separatedBy: CharacterSet(charactersIn: ";\n")) {
                                    let colorSplit = rangeSplit.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ". ")
                                    if colorSplit.count == 2, let doubleRange = Double(colorSplit[1]) {
                                        let lightRange = LightRange(context: context)
                                        lightRange.light = light
                                        lightRange.color = colorSplit[0]
                                        lightRange.range = doubleRange
                                        ranges.append(lightRange)
                                        
                                    }
                                }
                            }
                            light.lightRange = NSSet(array: ranges)
                        }
                        try? context.save()
                    }
                }
            }
        }
    }

    var color: UIColor {
        return Light.color
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
