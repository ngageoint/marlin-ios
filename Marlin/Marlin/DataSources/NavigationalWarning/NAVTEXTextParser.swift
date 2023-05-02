//
//  NavigationalWarningLocationParser.swift
//  Marlin
//
//  Created by Daniel Barela on 4/18/23.
//

import Foundation
import sf_wkt_ios
import sf_geojson_ios
import NaturalLanguage
import MapKit

enum MappedLocationGeoJSONProperties {
    case locationName
    case subject
    case cancelTime
}

struct LocationWithType: CustomStringConvertible {
    var location: [String] = []
    var locationType: String?
    var locationDescription: String?
    var distanceFromLocation: String?

    var description: String {
        return "\(locationDescription ?? "")\n\tDistance:\(distanceFromLocation ?? "")\n\t\(locationType ?? "")\n\t\t [\(location.joined(separator: "; "))]\n"
    }
    
    var metersDistance: Double? {
        let nf = NumberFormatter()
        nf.numberStyle = .spellOut
        nf.isLenient = true
        
        var distance: Double?
        if let distanceFromLocation = distanceFromLocation {
            let range = distanceFromLocation.ranges(of: "(MILE)|(METER)", options: .regularExpression)
            if let first = range.first, first.lowerBound != distanceFromLocation.startIndex {
                let beginingText = distanceFromLocation[...distanceFromLocation.index(before:first.lowerBound)].trimmingCharacters(in: .whitespacesAndNewlines)
                // now split on word boundaries, try to parse each into a number start at the end, then go backwards until
                // it fails to parse to find the extent of the number words
                
                let wordSplit = Array(beginingText.components(separatedBy: " ").reversed())
                var lastParts: [String] = []
                var tempParsedNumber: Double?
                for index in 0..<wordSplit.count {
                    lastParts.insert(wordSplit[index], at: 0)
                    // first see if it is a number anyway
                    if let parsed = Double(lastParts.joined(separator: " ")) {
                        tempParsedNumber = parsed
                    } else if let parsed = nf.number(from:lastParts.joined(separator: " ")) {
                        // see if it is a number in words
                        tempParsedNumber = parsed.doubleValue
                    }
                }
                if let parsedNumber = tempParsedNumber {
                    if distanceFromLocation.contains("MILE") {
                        let milesMeasurement = NSMeasurement(doubleValue: Double(parsedNumber), unit: UnitLength.nauticalMiles)
                        let convertedMeasurement = milesMeasurement.converting(to: UnitLength.meters)
                        distance = convertedMeasurement.value
                    } else {
                        distance = CLLocationDistance(parsedNumber)
                    }
                }
            }
        }
        
        return distance
    }
    
    var mkShape: MKShape? {
        var points: [MKMapPoint] = []
        if locationType == "Polygon" {
            for locationPoint in location {
                if let coordinate = CLLocationCoordinate2D(coordinateString: locationPoint) {
                    points.append(MKMapPoint(coordinate))
                }
            }
            return MKPolygon(points: &points, count: points.count)
        } else if locationType == "LineString" {
            for locationPoint in location {
                if let coordinate = CLLocationCoordinate2D(coordinateString: locationPoint) {
                    points.append(MKMapPoint(coordinate))
                }
            }
            return MKPolyline(points: &points, count: points.count)
        } else if locationType == "Point" {
            if let firstLocation = location.first, let coordinate = CLLocationCoordinate2D(coordinateString: firstLocation) {
                let point = MKPointAnnotation()
                point.coordinate = coordinate
                return point
            }
        } else if locationType == "Circle" {
            if let locationPoint = location.first, let coordinate = CLLocationCoordinate2D(coordinateString: locationPoint) {
                return MKCircle(center: coordinate, radius: metersDistance ?? 1000)
            }
        }
        return nil
    }
}

struct MappedLocation: CustomStringConvertible {
    var locationName: String?
    var specificArea: String?
    var subject: String?
    var cancelTime: String?
    var location: [LocationWithType] = []
    var when: String?
    var extra: String?
    var dnc: String?
    var chart: String?
    
    init(seedData: MappedLocation? = nil, locationName: String? = nil, specificArea: String? = nil, subject: String? = nil, cancelTime: String? = nil, location: [LocationWithType]? = nil, when: String? = nil, extra: String? = nil, dnc: String? = nil, chart: String? = nil) {
        if let seedData = seedData {
            self.locationName = seedData.locationName
            self.specificArea = seedData.specificArea
            self.subject = seedData.subject
            self.cancelTime = seedData.cancelTime
            self.location = seedData.location
            self.when = seedData.when
            self.extra = seedData.extra
            self.dnc = seedData.dnc
            self.chart = seedData.chart
        }
        if let locationName = locationName {
            self.locationName = locationName
        }
        if let specificArea = specificArea {
            self.specificArea = specificArea
        }
        if let subject = subject {
            self.subject = subject
        }
        if let cancelTime = cancelTime {
            self.cancelTime = cancelTime
        }
        if let location = location {
            self.location.append(contentsOf: location)
        }
        if let when = when {
            self.when = when
        }
        if let extra = extra {
            self.extra = extra
        }
        if let dnc = dnc {
            self.dnc = dnc
        }
        if let chart = chart {
            self.chart = chart
        }
    }
    
    var description: String {
        return "Location Name: \(locationName ?? "")\nSpecific Area: \(specificArea ?? "")\nSubject: \(subject ?? "")\nCancelTime: \(cancelTime ?? "")\nLocation: \(location)\nWhen: \(when ?? "")\nExtra: \(extra ?? "")\nDNC: \(dnc ?? "")\nChart: \(chart ?? "")\n"
    }
}

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

extension StringProtocol {
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
              let range = self[startIndex...].range(of: string, options: options) {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

class NAVTEXTextParser {
    var text: String
    var areaName: String?
    var specificArea: String?
    var subject: String?
    var extras: [String] = []
    var chart: String?
    var dnc: String?
    var currentLocationType: String = "Point"
    var firstDistance: String?
    var numberDistance: String?
    
    var heading: String?
    var sections: [String] = []
    var locations: [LocationWithType] = []
    
    init(text: String) {
        self.text = text
    }
    
    func parseDNCAndChart(line: String) -> Bool {
        var found = false
        if dnc == nil {
            let dncRange = line.ranges(of: "(DNC ){1}[0-9]*", options: .regularExpression)
            dnc = dncRange.map { String(line[$0]) }.first
            found = !dncRange.isEmpty
        }
        
        if chart == nil {
            let chartRange = line.ranges(of: "(CHART ){1}[0-9]*", options: .regularExpression)
            chart = chartRange.map { String(line[$0]) }.first
            found = found || !chartRange.isEmpty
        }
        
        return found
    }
    
    func splitChartFromLine(line: String) -> String {
        if let chart = chart {
            return String(line.deletingPrefix(chart).deletingPrefix(".")).trimmingCharacters(in: .whitespaces)
        } else if let dnc = dnc {
            return String(line.deletingPrefix(dnc).deletingPrefix(".")).trimmingCharacters(in: .whitespaces)
        }
        return line
    }
    
    func parseCurrentLocationType(line: String) {
        if !line.ranges(of: "AREA[S]? BOUND", options: .regularExpression).isEmpty {
            currentLocationType = "Polygon"
        } else if !line.ranges(of: "AREA[S]? WITHIN", options: .regularExpression).isEmpty {
            currentLocationType = "Circle"
        } else if line.contains("TRACKLINE") {
            currentLocationType = "LineString"
        } else if line.contains("POSITION") {
            currentLocationType = "Point"
        }
    }

    func parseHeading(heading: [String]) {
        firstDistance = parseDistance(line: heading.joined(separator: " "))
        
        var foundChart: Bool = false
        var stringLocations: [String] = []
        for line in heading {
            var toParse = line
            parseCurrentLocationType(line: toParse)
            foundChart = parseDNCAndChart(line: toParse)
            if foundChart {
                toParse = splitChartFromLine(line: line)
            }
            if !toParse.isEmpty {
                if areaName == nil {
                    areaName = toParse
                } else if specificArea == nil {
                    specificArea = toParse
                } else if subject == nil {
                    subject = toParse
                } else {
                    extras.append(toParse)
                }
            }
            
            let locationRanges = toParse.ranges(of: "[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[NS]{1} {1}[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[EW]", options: .regularExpression)
            stringLocations.append(contentsOf: locationRanges.map { String(toParse[$0]) })
        }
        
        if !stringLocations.isEmpty {
            locations.append(LocationWithType(location: stringLocations, locationType: currentLocationType, locationDescription: subject, distanceFromLocation: firstDistance))
        }
    }
    
    func parseDistance(line: String) -> String? {
        var distance: String?
        if !line.ranges(of: "(?!=\\.)[^\\.]*? BERTH", options: .regularExpression).isEmpty {
            let range = line.ranges(of: "(?!=\\.)[^\\.]*? BERTH", options: .regularExpression)
            distance = range.compactMap { String(line[$0]) }.first?.trimmingCharacters(in: .whitespacesAndNewlines)
        } else if !line.ranges(of: "WITHIN", options: .regularExpression).isEmpty {
            let range = line.ranges(of: "(?<=WITHIN ).*(?= OF)", options: .regularExpression)
            distance = range.compactMap { String(line[$0]) }.first
        }
        
        return distance
    }

    func parseNumber(numberSection: String) {
        var headingAndLetters = splitLettersFromHeading(text: numberSection)
        if let heading = headingAndLetters.heading {
            numberDistance = parseDistance(line: heading)
            let distance = numberDistance ?? firstDistance
            extras.append(heading)
            let descriptionAndLocations = splitDescriptionFromLocation(text: heading)
            if let description = descriptionAndLocations.description {
                parseCurrentLocationType(line: description)
                if subject == nil {
                    subject = description
                }
            }
            if let parsedLocations = descriptionAndLocations.locations, !parsedLocations.isEmpty {
                locations.append(LocationWithType(location: parsedLocations, locationType: currentLocationType, locationDescription: descriptionAndLocations.description != nil ? descriptionAndLocations.description : heading, distanceFromLocation: distance))
            }
        }
        if let letters = headingAndLetters.letters {
            for letter in splitLetters(string: letters) {
                parseLetter(letterSection: letter, numberSectionDescription: headingAndLetters.heading)
            }
        }
    }
    
    func parseLetter(letterSection: String, numberSectionDescription: String? = nil) {
        var currentLetterDescription: [String] = []
        if let numberSectionDescription = numberSectionDescription {
            currentLetterDescription.append(numberSectionDescription)
        }
        var currentLocations: [String] = []
        let distance = parseDistance(line: letterSection) ?? numberDistance ?? firstDistance
        let sentences = splitSentences(string: letterSection)
        extras.append(contentsOf: sentences)
        for sentence in sentences {
            // this will be the letter
            if !sentence.contains(" ") {
                if !currentLocations.isEmpty {
                    locations.append(LocationWithType(location: currentLocations, locationType: currentLocationType, locationDescription: currentLetterDescription.compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " "), distanceFromLocation: distance))
                    currentLocations = []
                    currentLetterDescription = []
                }
            } else {
                let descriptionAndLocations = splitDescriptionFromLocation(text: sentence)
                if let description = descriptionAndLocations.description {
                    parseCurrentLocationType(line: description)
                    currentLetterDescription.append(description)
                }
                if let parsedLocations = descriptionAndLocations.locations, !parsedLocations.isEmpty {
                    currentLocations.append(contentsOf: parsedLocations)
                }
            }
        }
        
        // add the final parsed locations
        if !currentLocations.isEmpty {
            locations.append(LocationWithType(location: currentLocations, locationType: currentLocationType, locationDescription: currentLetterDescription.compactMap { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " "), distanceFromLocation: distance))
        }
    }
    
    func splitDescriptionFromLocation(text: String) -> (description: String?, locations: [String]?) {
        let locationRanges = text.ranges(of: "[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[NS]{1} {1}[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[EW]", options: .regularExpression)
        if locationRanges.isEmpty {
            return (text, nil)
        } else {
            var description: String?
            var locations: [String]?
            if let first = locationRanges.first {
                if first.lowerBound != text.startIndex {
                    // go back one index from the start of the first match
                    let finalIndex = first.lowerBound == text.endIndex ? first.lowerBound : text.index(before: first.lowerBound)
                    description = String(text[...finalIndex]).trimmingCharacters(in: .whitespaces)
                }
            }
            locations = locationRanges.compactMap { String(text[$0]) }
            if let last = locationRanges.last {
                if last.upperBound != text.endIndex {
                    let finalIndex = last.upperBound
                    let endDescription = String(text[finalIndex...]).trimmingCharacters(in: .whitespaces)
                    if let currentDescription = description {
                        description = "\(currentDescription) \(endDescription)"
                    } else {
                        description = endDescription
                    }
                }
            }
            return (description, locations)
        }
    }
    
    func splitLettersFromHeading(text: String) -> (heading: String?, letters: String?) {
        var heading: String?
        var letters: String?
        
        let regexOptions: NSRegularExpression.Options = [.anchorsMatchLines]
        let regex = try? NSRegularExpression(pattern: "\\bA\\. ", options: regexOptions)
        if let lettersNSRange = regex?.rangeOfFirstMatch(in: text, range: NSRange(location: 0, length: text.utf8.count)), let lettersRange = Range(lettersNSRange) {
            let lowerBound = String.Index(utf16Offset: lettersRange.lowerBound, in: text)
            if lettersNSRange.lowerBound != 0 {
                heading = String(text[...text.index(lowerBound, offsetBy: -1)]).split(separator: "\n").compactMap { $0.trimmingCharacters(in:.whitespacesAndNewlines) }.joined(separator: " ")
            }
            letters = String(text[lowerBound...])
        } else {
            // the entire thing is the heading
            heading = text.split(separator: "\n").compactMap { $0.trimmingCharacters(in:.whitespacesAndNewlines) }.joined(separator: " ")
        }
        return (heading, letters)
    }
    
    func getHeadingAndSections(string: String) -> (heading: String?, sections: String?) {
        var heading: String?
        var sections: String?
                
        let regexOptions: NSRegularExpression.Options = [.anchorsMatchLines]
        let regex = try? NSRegularExpression(pattern: "\\b[1A]\\. ", options: regexOptions)
        if let sectionNSRange = regex?.rangeOfFirstMatch(in: string, range: NSRange(location: 0, length: string.utf8.count)), let sectionRange = Range(sectionNSRange) {
            let lowerBound = String.Index(utf16Offset: sectionRange.lowerBound, in: string)
            if sectionNSRange.lowerBound != 0 {
                heading = String(string[...string.index(lowerBound, offsetBy: -1)]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            sections = String(string[lowerBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // the entire thing is the heading
            heading = string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return (heading, sections)
    }

    func splitSentences(string: String) -> [String] {
        // split on new lines and trim the extra white space
        return string.components(separatedBy: .newlines)
            .compactMap { $0.trimmingCharacters(in: .whitespaces) }
        // join back together
            .joined(separator: " ")
        // split on period space
            .components(separatedBy: ". ")
            .filter { $0 != "" }
            .compactMap {
                ($0.hasSuffix(".") ? $0 : "\($0).").trimmingCharacters(in: .whitespacesAndNewlines)
            }
    }
    
    func splitLetters(string: String) -> [String] {
        var letters: [String] = []
        let ranges = string.ranges(of: "(?<letters>[\\w]+\\. (?<letterContent>[\\W\\w]*?)(?=([\\w]+\\. [\\w])|($)))", options: .regularExpression)
        letters = ranges.map { String(string[$0]).trimmingCharacters(in: .whitespacesAndNewlines) }
        return letters
    }
    
    func splitNumbers(string: String) -> [String] {
        var numbers: [String] = []
        let ranges = string.ranges(of: "(?<numbers>[\\d]+\\. (?<numberContent>[\\W\\w]*?)(?=([\\d]+\\. [\\w])|($)))", options: .regularExpression)
        numbers = ranges.map { String(string[$0]).trimmingCharacters(in: .whitespacesAndNewlines) }
        return numbers
    }
    
    func parseToMappedLocation() -> MappedLocation? {
        // split the text into Heading, and number sections
        let headingAndSections = getHeadingAndSections(string: text)
        // handle header
        if let heading = headingAndSections.heading {
            let sentences = splitSentences(string: heading)
            parseHeading(heading: sentences)
        }
        if let sections = headingAndSections.sections {
            // do we have numbers
            if sections.hasPrefix("1.") {
                for number in splitNumbers(string: sections) {
                    parseNumber(numberSection: number)
                }
            } else
            // or just letters
            if sections.hasPrefix("A.") {
                for letter in splitLetters(string: sections) {
                    parseLetter(letterSection: letter)
                }
            }
        }
        return MappedLocation(locationName: areaName, specificArea: specificArea, subject: subject, cancelTime: nil, location: locations, when: nil, extra: extras.joined(separator: "\n"), dnc:dnc, chart: chart)
    }
    
    func parseToWKT() -> String? {
        var components = text.components(separatedBy: .newlines)
        
        return nil
    }
    
    func parseToGeoJSON() -> [SFGGeoJSONObject] {
        
        return []
    }
}
