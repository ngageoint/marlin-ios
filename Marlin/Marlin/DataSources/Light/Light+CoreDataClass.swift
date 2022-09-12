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

extension Light: DataSource {
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Lights", comment: "Lights data source display name")
    static var key: String = "light"
    static var imageName: String? = nil
    static var systemImageName: String? = "lightbulb.fill"
    static var color: UIColor = UIColor(argbValue: 0xFFFFC500)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.66
    static var seedDataFiles: [String]? = ["light110","light111","light112","light113","light114","light115","light116"]
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? LightsPropertyContainer else {
            return
        }
        let count = value.ngalol.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Light.batchImport(from: value.ngalol, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        var requests: [MSIRouter] = []
        
        for lightVolume in Light.lightVolumes {
            let newestLight = try? PersistenceController.shared.container.viewContext.fetchFirst(Light.self, sortBy: [NSSortDescriptor(keyPath: \Light.noticeNumber, ascending: false)], predicate: NSPredicate(format: "volumeNumber = %@", lightVolume.volumeNumber))
            
            let noticeWeek = Int(newestLight?.noticeWeek ?? "0") ?? 0
            
            print("Query for lights in volume \(lightVolume) after year:\(newestLight?.noticeYear ?? "") week:\(noticeWeek)")
            
            requests.append(MSIRouter.readLights(volume: lightVolume.volumeQuery, noticeYear: newestLight?.noticeYear, noticeWeek: String(format: "%02d", noticeWeek + 1)))
        }
            
        return requests
    }
}

extension Light: DataSourceViewBuilder {
    var detailView: AnyView {
        if let featureNumber = self.featureNumber, let volumeNumber = self.volumeNumber {
            return AnyView(LightDetailView(featureNumber: featureNumber, volumeNumber: volumeNumber).navigationTitle("\(name ?? Light.dataSourceName)" ))
        }
        return AnyView(EmptyView())
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(LightSummaryView(light: self, showMoreDetails: showMoreDetails))
    }
}

class Light: NSManagedObject, MKAnnotation, AnnotationWithView, MapImage {
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    var clusteringIdentifier: String? = nil
    
    static let lightVolumes = [
        LightVolume(volumeQuery: "110", volumeNumber: "PUB 110"),
        LightVolume(volumeQuery: "111", volumeNumber: "PUB 111"),
        LightVolume(volumeQuery: "112", volumeNumber: "PUB 112"),
        LightVolume(volumeQuery: "113", volumeNumber: "PUB 113"),
        LightVolume(volumeQuery: "114", volumeNumber: "PUB 114"),
        LightVolume(volumeQuery: "115", volumeNumber: "PUB 115"),
        LightVolume(volumeQuery: "116", volumeNumber: "PUB 116")
    ]
    
    static let whiteLight = UIColor(argbValue: 0xdeffff00)
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
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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
            if let start = start {
                if end < start {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: start, endDegrees: end, color: uicolor, text: color, obscured: obscured || fullLightObscured))
            } else {
                if end <= previousEnd {
                    end += 360
                }
                sectors.append(ImageSector(startDegrees: previousEnd, endDegrees: end, color: uicolor, text: color, obscured: obscured || fullLightObscured))
            }
            if fullLightObscured {
                // add the sector for the part of the light which is not obscured
                sectors.append(ImageSector(startDegrees: end, endDegrees: (start ?? 0) + 360, color: visibleColor ?? (lightColors?[0] ?? UIColor.clear)))
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
    
    func toRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    
    func toDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }

    func circleCoordinates(center: CLLocationCoordinate2D, radiusMeters: Double) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        let centerLatRad = toRadians(degrees: center.latitude)
        let centerLonRad = toRadians(degrees: center.longitude)
        let dRad = radiusMeters / 6378137
        
        for i in 0...360 {
            let radial = toRadians(degrees: Double(i))
            let latRad = asin(sin(centerLatRad) * cos(dRad) + cos(centerLatRad) * sin(dRad) * cos(radial))
            let dlonRad = atan2(sin(radial) * sin(dRad) * cos(centerLatRad), cos(dRad) - sin(centerLatRad) * sin(latRad))
            let lonRad = fmod((centerLonRad + dlonRad + .pi), 2.0 * .pi) - .pi
            coordinates.append(CLLocationCoordinate2D(latitude: toDegrees(radians: latRad), longitude: toDegrees(radians: lonRad)))
        }
        
        return coordinates
    }
    
    let TILE_SIZE = 512.0
    
    func coordinateToPixel(c: CLLocationCoordinate2D, zoomLevel: Int, tileBounds3857: MapBoundingBox) -> CGPoint {
        let object3857Location = coord4326To3857(longitude: c.longitude, latitude: c.latitude)
        let xPosition = (((object3857Location.x - tileBounds3857.swCorner.x) / (tileBounds3857.neCorner.x - tileBounds3857.swCorner.x)) * TILE_SIZE)
        let yPosition = TILE_SIZE - (((object3857Location.y - tileBounds3857.swCorner.y) / (tileBounds3857.neCorner.y - tileBounds3857.swCorner.y)) * TILE_SIZE)
        return CGPoint(x:xPosition, y: yPosition)
    }
    
    func coord4326To3857(longitude: Double, latitude: Double) -> (x: Double, y: Double) {
        let a = 6378137.0
        let lambda = longitude / 180 * Double.pi;
        let phi = latitude / 180 * Double.pi;
        let x = a * lambda;
        let y = a * log(tan(Double.pi / 4 + phi / 2));
        
        return (x:x, y:y);
    }
    
    func mapImage(marker: Bool = false, zoomLevel: Int, tileBounds3857: MapBoundingBox? = nil) -> [UIImage] {
        var images: [UIImage] = []
        
        if UserDefaults.standard.lifeSizeLights, let stringRange = range, let range = Double(stringRange), let tileBounds3857 = tileBounds3857, let lightColors = lightColors {
            let nauticalMilesMeasurement = NSMeasurement(doubleValue: range, unit: UnitLength.nauticalMiles)
            let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)

            let circleCoordinates = circleCoordinates(center: self.coordinate, radiusMeters: metersMeasurement.value)
            let size = CGSize(width: TILE_SIZE, height: TILE_SIZE)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { _ in
                let lightPixel = coordinateToPixel(c: coordinate, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857)
                let path = UIBezierPath()
                
                var pixel = coordinateToPixel(c: circleCoordinates[0], zoomLevel: zoomLevel, tileBounds3857: tileBounds3857)
                pixel.x = lightPixel.x - pixel.x + (size.width / 2.0)
                pixel.y = lightPixel.y - pixel.y + (size.height / 2.0)
                
                path.move(to: pixel)
                for circleCoordinate in circleCoordinates {
                    pixel = coordinateToPixel(c: circleCoordinate, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857)
                    pixel.x = lightPixel.x - pixel.x + (size.width / 2.0)
                    pixel.y = lightPixel.y - pixel.y + (size.height / 2.0)
                    path.addLine(to: pixel)
                }
                path.close()
                lightColors[0].withAlphaComponent(0.2).setFill()
                lightColors[0].setStroke()
                path.fill()
                path.stroke()
            }
            
            images.append(image)
        } else {
            images.append(contentsOf: LightImage.image(light: self, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857))
        }
        
        return images
    }
    
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
    
    func raconImage(scale: Int, sectors: [ImageSector]? = nil, zoomLevel: Int) -> UIImage {
        if zoomLevel > 12 {
            return RaconImage(frame: CGRect(x: 0, y: 0, width: 100 * scale, height: 100 * scale), sectors: sectors, arcWidth: Double(2 * scale), arcRadius: Double(8 * scale), text: "Racon (\(morseLetter))\n\(remarks?.replacingOccurrences(of: "\n", with: "") ?? "")", darkMode: false) ?? clearImage
        } else if zoomLevel > 7 {
            return CircleImage(color: Light.raconColor, radius: CGFloat(2.5 * Double(scale)), fill: false, arcWidth: 1 * CGFloat(scale)) ?? clearImage

        } else {
            return CircleImage(color: Light.raconColor, radius: CGFloat(scale), fill: false, arcWidth: 1 * CGFloat(scale)) ?? clearImage
        }
    }
    
    func sectorImage(lightSectors: [ImageSector], scale: Int, zoomLevel: Int) -> UIImage {
        if zoomLevel > 12 {
            return CircleImage(suggestedFrame: CGRect(x: 0, y: 0, width: 100 * scale, height: 100 * scale), sectors: lightSectors, radius: 25 * CGFloat(scale), fill: false, arcWidth: 3 * CGFloat(scale)) ?? clearImage
        } else if zoomLevel > 7 {
            var sectors: [ImageSector] = []
            if let lightColors = lightColors {
                var count = 0
                let degreesPerColor = 360.0 / CGFloat(lightColors.count)
                for color in lightColors {
                    sectors.append(ImageSector(startDegrees: degreesPerColor * CGFloat(count), endDegrees: degreesPerColor * (CGFloat(count) + 1.0), color: color))
                    count += 1
                }
            }
            return CircleImage(suggestedFrame: CGRect(x: 0, y: 0, width: 5 * scale, height: 5 * scale), sectors: sectors, fill: true, sectorSeparator: false) ?? clearImage
        } else {
            var sectors: [ImageSector] = []
            if let lightColors = lightColors {
                var count = 0
                let degreesPerColor = 360.0 / CGFloat(lightColors.count)
                for color in lightColors {
                    sectors.append(ImageSector(startDegrees: degreesPerColor * CGFloat(count), endDegrees: degreesPerColor * (CGFloat(count) + 1.0), color: color))
                    count += 1
                }
            }
            return CircleImage(suggestedFrame: CGRect(x: 0, y: 0, width: 2 * scale, height: 2 * scale), sectors: sectors, fill: true, sectorSeparator: false) ?? clearImage
        }
    }
    
    func colorImage(lightColors: [UIColor], scale: Int, zoomLevel: Int) -> UIImage {
        
        if zoomLevel > 12 {
            return LightColorImage(frame: CGRect(x: 0, y: 0, width: 10 * scale, height: 10 * scale), colors: lightColors, arcWidth: 1.5 * CGFloat(scale), darkMode: false) ?? clearImage
        } else if zoomLevel > 7 {
            var sectors: [ImageSector] = []
            var count = 0
            let degreesPerColor = 360.0 / CGFloat(lightColors.count)
            for color in lightColors {
                sectors.append(ImageSector(startDegrees: degreesPerColor * CGFloat(count), endDegrees: degreesPerColor * (CGFloat(count) + 1.0), color: color))
                count += 1
            }
            return CircleImage(suggestedFrame: CGRect(x: 0, y: 0, width: 5 * scale, height: 5 * scale), sectors: sectors, fill: true, sectorSeparator: false) ?? clearImage
        } else {
            var sectors: [ImageSector] = []
            var count = 0
            let degreesPerColor = 360.0 / CGFloat(lightColors.count)
            for color in lightColors {
                sectors.append(ImageSector(startDegrees: degreesPerColor * CGFloat(count), endDegrees: degreesPerColor * (CGFloat(count) + 1.0), color: color))
                count += 1
            }
            return CircleImage(suggestedFrame: CGRect(x: 0, y: 0, width: 2 * scale, height: 2 * scale), sectors: sectors, fill: true, sectorSeparator: false) ?? clearImage
        }
    }
    
    var clearImage: UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
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
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: Light.key, for: self)
        let images = self.mapImage(marker: true, zoomLevel: on.zoomLevel)
        
        let largestSize = images.reduce(CGSize(width: 0, height: 0)) { partialResult, image in
            return CGSize(width: max(partialResult.width, image.size.width), height: max(partialResult.height, image.size.height))
        }
        
        UIGraphicsBeginImageContext(largestSize)
        for image in images {
            image.draw(at: CGPoint(x: (largestSize.width / 2.0) - (image.size.width / 2.0), y: (largestSize.height / 2.0) - (image.size.height / 2.0)))
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        guard let cgImage = newImage.cgImage else {
            return annotationView
        }
        let image = UIImage(cgImage: cgImage)
        
        if let lav = annotationView as? ImageAnnotationView {
            lav.combinedImage = image
        } else {
            annotationView.image = image
        }
        self.annotationView = annotationView
        return annotationView
    }
    
    var annotationView: MKAnnotationView?
    
    static func newBatchInsertRequest(with propertyList: [LightsProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        NSLog("Creating batch insert request of lights for \(total) lights")
        
        var previousRegionHeading: String?
        var previousSubregionHeading: String?
        var previousLocalHeading: String?
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Light.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            let propertyDictionary = propertyList[index].dictionaryValue
            let region = propertyDictionary["regionHeading"] as? String ?? previousRegionHeading
            let subregion = propertyDictionary["subregionHeading"] as? String ?? previousSubregionHeading
            let local = propertyDictionary["localHeading"] as? String ?? previousSubregionHeading
            
            var correctedLocationDictionary: [String:String?] = [
                "regionHeading": propertyDictionary["regionHeading"] as? String ?? previousRegionHeading,
                "subregionHeading": propertyDictionary["subregionHeading"] as? String ?? previousSubregionHeading,
                "localHeading": propertyDictionary["localHeading"] as? String ?? previousSubregionHeading
            ]
            correctedLocationDictionary["sectionHeader"] = "\(propertyDictionary["geopoliticalHeading"] as? String ?? "")\(correctedLocationDictionary["regionHeading"] != nil ? ": \(correctedLocationDictionary["regionHeading"] as? String ?? "")" : "")"

            
            if previousRegionHeading != region {
                previousRegionHeading = region
                previousSubregionHeading = nil
                previousLocalHeading = nil
            } else if previousSubregionHeading != subregion {
                previousSubregionHeading = subregion
                previousLocalHeading = nil
            } else if previousLocalHeading != local {
                previousLocalHeading = local
            }
            
            dictionary.addEntries(from: propertyDictionary.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            dictionary.addEntries(from: correctedLocationDictionary.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [LightsProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importLight"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Light.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            do {
                let fetchResult = try taskContext.execute(batchInsertRequest)
                if let batchInsertResult = fetchResult as? NSBatchInsertResult {
                    if let count = batchInsertResult.result as? Int, count > 0 {
                          NSLog("Inserted \(count) Light records")
                          NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: Light.self))
                    } else {
                        NSLog("No new Light records")
                    }
                    // if there were already lights in the db for this volume and this was an update and we got back a light we have to go redo the query due to regions not being populated on all returned objects
                    return
                }
            } catch {
                print("error was \(error)")
            }
            throw MSIError.batchInsertError
        }
    }
    
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

struct LightsPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ngalol
    }
    let ngalol: [LightsProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ngalol = try container.decode([Throwable<LightsProperties>].self, forKey: .ngalol).compactMap { try? $0.result.get() }
    }
}

struct LightsProperties: Decodable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case volumeNumber
        case aidType
        case geopoliticalHeading
        case regionHeading
        case subregionHeading
        case localHeading
        case precedingNote
        case featureNumber
        case name
        case position
        case charNo
        case characteristic
        case heightFeetMeters
        case range
        case structure
        case remarks
        case postNote
        case noticeNumber
        case removeFromList
        case deleteFlag
        case noticeWeek
        case noticeYear
    }
    
    let aidType: String?
    let characteristic: String?
    let characteristicNumber: Int?
    let deleteFlag: String?
    let featureNumber: String?
    let geopoliticalHeading: String?
    let heightFeet: Float?
    let heightMeters: Float?
    let internationalFeature: String?
    let localHeading: String?
    let name: String?
    let noticeNumber: Int?
    let noticeWeek: String?
    let noticeYear: String?
    let position: String?
    let postNote: String?
    let precedingNote: String?
    let range: String?
    let regionHeading: String?
    let remarks: String?
    let removeFromList: String?
    let structure: String?
    let subregionHeading: String?
    let volumeNumber: String?
    let latitude: Double?
    let longitude: Double?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // this potentially is US and international feature number combined with a new line
        let rawFeatureNumber = try? values.decode(String.self, forKey: .featureNumber)
        let rawVolumeNumber = try? values.decode(String.self, forKey: .volumeNumber)
        let rawPosition = try? values.decode(String.self, forKey: .position)
        
        guard let featureNumber = rawFeatureNumber,
              let volumeNumber = rawVolumeNumber,
              let position = rawPosition
        else {
            let values = "featureNumber = \(rawFeatureNumber?.description ?? "nil"), "
            + "volumeNumber = \(rawVolumeNumber?.description ?? "nil"), "
            + "position = \(rawPosition?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.volumeNumber = volumeNumber
        self.position = position
        self.aidType = try? values.decode(String.self, forKey: .aidType)
        self.characteristic = try? values.decode(String.self, forKey: .characteristic)
        self.characteristicNumber = try? values.decode(Int.self, forKey: .charNo)
        self.deleteFlag = try? values.decode(String.self, forKey: .deleteFlag)
        let featureNumberSplit = featureNumber.split(separator: "\n")
        self.featureNumber = "\(featureNumberSplit[0])"
        if featureNumberSplit.count == 2 {
            self.internationalFeature = "\(featureNumberSplit[1])"
        } else {
            self.internationalFeature = nil
        }
        self.geopoliticalHeading = try? values.decode(String.self, forKey: .geopoliticalHeading)
        let heightFeetMeters = try? values.decode(String.self, forKey: .heightFeetMeters)
        let heightFeetMetersSplit = heightFeetMeters?.split(separator: "\n")
        self.heightFeet = Float(heightFeetMetersSplit?[0] ?? "0.0")
        self.heightMeters = Float(heightFeetMetersSplit?[1] ?? "0.0")
        self.localHeading = try? values.decode(String.self, forKey: .localHeading)
        self.name = try? values.decode(String.self, forKey: .name)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.noticeWeek = try? values.decode(String.self, forKey: .noticeWeek)
        self.noticeYear = try? values.decode(String.self, forKey: .noticeYear)
        self.postNote = try? values.decode(String.self, forKey: .postNote)
        self.precedingNote = try? values.decode(String.self, forKey: .precedingNote)
        self.range = try? values.decode(String.self, forKey: .range)
        if var rawRegionHeading = try? values.decode(String.self, forKey: .regionHeading) {
            if rawRegionHeading.last == ":" {
                rawRegionHeading.removeLast()
            }
            self.regionHeading = rawRegionHeading
        } else {
            self.regionHeading = nil
        }
        self.remarks = try? values.decode(String.self, forKey: .remarks)
        self.removeFromList = try? values.decode(String.self, forKey: .removeFromList)
        self.structure = try? values.decode(String.self, forKey: .structure)
        self.subregionHeading = try? values.decode(String.self, forKey: .subregionHeading)

        if let position = self.position {
            let coordinate = LightsProperties.parsePosition(position: position)
            self.longitude = coordinate.longitude
            self.latitude = coordinate.latitude
        } else {
            self.longitude = 0.0
            self.latitude = 0.0
        }
        
        if characteristic == "" && remarks == nil && name == "" {
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored \(featureNumber ) \(volumeNumber ) due to no name, remarks, and characteristic")
            
            throw MSIError.missingData
        }
    }
    
    static func parsePosition(position: String) -> CLLocationCoordinate2D {
        var latitude = 0.0
        var longitude = 0.0
        
        let pattern = #"(?<latdeg>[0-9]*)°(?<latminutes>[0-9]*)'(?<latseconds>[0-9]*\.?[0-9]*)\"(?<latdirection>[NS]) \n(?<londeg>[0-9]*)°(?<lonminutes>[0-9]*)'(?<lonseconds>[0-9]*\.?[0-9]*)\"(?<londirection>[EW])"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(position.startIndex..<position.endIndex,
                              in: position)
        if let match = regex?.firstMatch(in: position,
                                        options: [],
                                        range: nsrange)
        {
            for component in ["latdeg", "latminutes", "latseconds", "latdirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position)
                {
                    if component == "latdeg" {
                        latitude = Double(position[range]) ?? 0.0
                    } else if component == "latminutes" {
                        latitude += (Double(position[range]) ?? 0.0) / 60
                    } else if component == "latseconds" {
                        latitude += (Double(position[range]) ?? 0.0) / 3600
                    } else if component == "latdirection", position[range] == "S" {
                        latitude *= -1
                    }
                }
            }
            for component in ["londeg", "lonminutes", "lonseconds", "londirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position)
                {
                    if component == "londeg" {
                        longitude = Double(position[range]) ?? 0.0
                    } else if component == "lonminutes" {
                        longitude += (Double(position[range]) ?? 0.0) / 60
                    } else if component == "lonseconds" {
                        longitude += (Double(position[range]) ?? 0.0) / 3600
                    } else if component == "londirection", position[range] == "W" {
                        longitude *= -1
                    }
                }
            }
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // The keys must have the same name as the attributes of the Lights entity.
    var dictionaryValue: [String: Any?] {
        [
            "aidType": aidType,
            "characteristic": characteristic,
            "characteristicNumber": characteristicNumber,
            "deleteFlag": deleteFlag,
            "featureNumber": featureNumber,
            "geopoliticalHeading": geopoliticalHeading,
            "heightFeet": heightFeet,
            "heightMeters": heightMeters,
            "internationalFeature": internationalFeature,
            "localHeading": localHeading,
            "name": name,
            "noticeNumber": noticeNumber,
            "noticeWeek": noticeWeek,
            "noticeYear": noticeYear,
            "position": position,
            "postNote": postNote,
            "precedingNote": precedingNote,
            "range": range,
            "regionHeading": regionHeading,
            "remarks": remarks,
            "removeFromList": removeFromList,
            "structure": structure,
            "subregionHeading": subregionHeading,
            "volumeNumber": volumeNumber,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}


