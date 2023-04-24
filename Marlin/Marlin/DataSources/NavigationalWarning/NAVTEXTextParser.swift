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

enum MappedLocationGeoJSONProperties {
    case locationName
    case subject
    case cancelTime
}

struct LocationWithType: CustomStringConvertible {
    var location: [String] = []
    var locationType: String?
    var distanceFroMLocation: String?
    
    var description: String {
        return "\(locationType ?? ""): [\(location.joined(separator: "; "))]"
    }
}

struct MappedLocation: CustomStringConvertible {
    var locationName: String?
    var specificArea: String?
    var subject: String?
    var cancelTime: String?
    var location: [LocationWithType] = []
    var when: String?
    var what: String?
    var extra: String?
    var dnc: String?
    var chart: String?
    
    init(seedData: MappedLocation? = nil, locationName: String? = nil, specificArea: String? = nil, subject: String? = nil, cancelTime: String? = nil, location: [LocationWithType]? = nil, when: String? = nil, what: String? = nil, extra: String? = nil, dnc: String? = nil, chart: String? = nil) {
        if let seedData = seedData {
            self.locationName = seedData.locationName
            self.specificArea = seedData.specificArea
            self.subject = seedData.subject
            self.cancelTime = seedData.cancelTime
            self.location = seedData.location
            self.when = seedData.when
            self.what = seedData.what
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
        if let what = what {
            self.what = what
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
        return "Location Name: \(locationName ?? "")\nSpecific Area: \(specificArea ?? "")\nSubject: \(subject ?? "")\nCancelTime: \(cancelTime ?? "")\nLocation: \(location)\nWhat: \(what ?? "")\nWhen: \(when ?? "")\nExtra: \(extra ?? "")\nDNC: \(dnc ?? "")\nChart: \(chart ?? "")\n"
    }
}

extension String {
    var startsWithNumberHeading: Bool {
        return self.range(
            of: "^[0-9]+\\. {1}.*", // 1.
            options: .regularExpression) != nil
    }
    
    var startsWithLetterHeading: Bool {
        return self.range(
            of: "^\\s*[A-Z]+\\.", // 1.
            options: .regularExpression) != nil
    }
    
    var isNumberHeading: Bool {
        return self.range(
            of: "^[0-9]+\\.$", // 1.
            options: .regularExpression) != nil
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
    
    init(text: String) {
        self.text = text
    }
    
    func parseWhat(components: [String]) -> String? {
        var what: [String] = []
        if !components.isEmpty {
            for component in components {
                if !component.isNumberHeading {
                    what.append(component)
                }
            }
        }
        return what.joined(separator: "\n")
    }
    
    func parseSubSection(type: String = "Point", components: [String]) -> LocationWithType? {
        let what = components.joined(separator: " ")
        let locationRanges = what.ranges(of: "[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[NS]{1} {1}[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[EW]", options: .regularExpression)
        var locations = locationRanges.map { String(what[$0]) }
        if locations.isEmpty {
            return nil
        }
        return LocationWithType(location: locations, locationType: type)
    }
    
    func parseSection(components: [String], currentMappedLocation: MappedLocation?, locationType: String?) -> MappedLocation {
//        print("parse section components \(components)")
        let what = parseWhat(components: components)
        var locations: [LocationWithType] = []
        
        var currentLocationStrings: [String] = []
        var currentSubComponent: String?
        
        var subComponents: [String] = []
        var realLocationType: String = locationType ?? "Point"
        for component in components {
            if component.contains(" AREA") {
                realLocationType = "Polygon"
            }

            if component.startsWithLetterHeading && !subComponents.isEmpty {
                // parse the previous ones
                if let location = parseSubSection(type: realLocationType, components: subComponents) {
                    locations.append(location)
                }
                subComponents = [component]
            } else {
                subComponents.append(component)
            }
        }
        
        if !subComponents.isEmpty {
            if let location = parseSubSection(type: realLocationType, components: subComponents) {
                locations.append(location)
            }
        }
        if currentMappedLocation?.subject == nil {
            return MappedLocation(seedData: currentMappedLocation, subject: what, location: locations.isEmpty ? nil : locations)
        } else {
            return MappedLocation(seedData: currentMappedLocation, location: locations.isEmpty ? nil : locations, what: what)
        }
    }
    
    func splitIntoSentences(string: String) -> [String] {
        var toParse = string.replacingOccurrences(of: "\n", with: " ")
        var r = [Range<String.Index>]()
        let t = toParse.linguisticTags(
            in: toParse.startIndex..<toParse.endIndex,
            scheme: NSLinguisticTagScheme.lexicalClass.rawValue,
            tokenRanges: &r)
        var result = [String]()
        let ixs = t.enumerated().filter {
            return $0.1 == "SentenceTerminator"
        }.map {r[$0.0].lowerBound}
        var prev = toParse.startIndex
        for ix in ixs {
            let r = prev...ix
            let subSequence = toParse[r].trimmingCharacters(
                in: NSCharacterSet.whitespaces)
            for component in subSequence.components(separatedBy: ":") {
                result.append(component)
            }
            prev = toParse.index(after: ix)
        }
        return result
    }
    
    func parseHeading(components: [String]) -> (String?, MappedLocation) {
        var areaName: String? = components.first
        var specificArea: String?
        var numberSubject: String?
        var extras: [String] = []
        var chart: String?
        var dnc: String?
        
        if let areaName = areaName {
            if dnc == nil {
                let dncRange = areaName.ranges(of: "(DNC ){1}[0-9]*", options: .regularExpression)
                dnc = dncRange.map { String(areaName[$0]) }.first
            }
            
            if chart == nil {
                let chartRange = areaName.ranges(of: "(CHART ){1}[0-9]*", options: .regularExpression)
                chart = chartRange.map { String(areaName[$0]) }.first
            }
        }
        
        var foundChart: Bool = false
        for toParse in components.dropFirst() {
            var foundChartNow: Bool = false
            if !foundChart && dnc == nil {
                let dncRange = toParse.ranges(of: "(DNC ){1}[0-9]*", options: .regularExpression)
                foundChartNow = !dncRange.isEmpty
                foundChart = !dncRange.isEmpty
                if foundChart {
                    dnc = dncRange.map { String(toParse[$0]) }.first
                    if let dnc = dnc {
                        if toParse.hasSuffix(".") {
                            foundChartNow = dnc.count == toParse.count - 1
                        } else {
                            foundChartNow = dnc.count == toParse.count
                        }
                    }
                }
            }
            
            if !foundChart && chart == nil {
                let chartRange = toParse.ranges(of: "(CHART ){1}[0-9]*", options: .regularExpression)
                foundChartNow = !chartRange.isEmpty
                foundChart = !chartRange.isEmpty
                if foundChart {
                    chart = chartRange.map { String(toParse[$0]) }.first
                    if let chart = chart {
                        if toParse.hasSuffix(".") {
                            foundChartNow = chart.count == toParse.count - 1
                        } else {
                            foundChartNow = chart.count == toParse.count
                        }
                    }
                }
            }
            if !foundChartNow {
                if specificArea == nil && !foundChart {
                    specificArea = toParse
                } else if numberSubject == nil {
                    numberSubject = toParse
                } else {
                    extras.append(toParse)
                }
            }
        }
        var locationType: String = "Point"
        var locations: [String] = []
        for subject in extras {
            let locationRanges = subject.ranges(of: "[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[NS]{1} {1}[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[EW]", options: .regularExpression)
            locations.append(contentsOf: locationRanges.map { String(subject[$0]) })
            if subject.contains(" AREA") {
                locationType = "Polygon"
            }
        }
        if let numberSubject = numberSubject {
            let locationRanges = numberSubject.ranges(of: "[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[NS]{1} {1}[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[EW]", options: .regularExpression)
            locations.append(contentsOf: locationRanges.map { String(numberSubject[$0]) })
            if numberSubject.contains(" AREA") {
                locationType = "Polygon"
            }
        }
        if let specificArea = specificArea {
            let locationRanges = specificArea.ranges(of: "[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[NS]{1} {1}[0-9]{1,3}-{1}[0-9]{2}(-[0-9]{2})?(\\.{1}[0-9]+)?[EW]", options: .regularExpression)
            locations.append(contentsOf: locationRanges.map { String(specificArea[$0]) })
            if specificArea.contains(" AREA") {
                locationType = "Polygon"
            }
        }
        
        return (locations.isEmpty ? nil : locationType, MappedLocation(locationName: areaName, specificArea: specificArea, subject: numberSubject, location: locations.isEmpty ? nil : [LocationWithType(location: locations, locationType: locationType)], extra: extras.joined(separator: ", "), dnc: dnc, chart: chart))
    }
    
    func parseNumbers(heading: MappedLocation?, numbers: [String], locationType: String?) -> [MappedLocation] {
        var locations: [MappedLocation] = []
        var subComponents: [String] = []
        
        for component in numbers {
            var toParse = component

            if toParse.isNumberHeading && !subComponents.isEmpty {
                // parse the previous ones
                locations.append(parseSection(components: subComponents, currentMappedLocation: heading, locationType: locationType))
                subComponents = [toParse]
            } else {
                subComponents.append(toParse)
            }
        }
        locations.append(parseSection(components: subComponents, currentMappedLocation: heading, locationType: locationType))
        return locations
    }
    
    func parseToMappedLocation() -> [MappedLocation] {
        // split the text into Heading, and number sections
        var heading: String?
        var numbers: String?
        
        let regexOptions: NSRegularExpression.Options = [.anchorsMatchLines]
        let regex = try? NSRegularExpression(pattern: "^[0-9]*\\. {1}", options: regexOptions)
        if let numberNSRange = regex?.rangeOfFirstMatch(in: text, range: NSRange(location: 0, length: text.utf8.count)), let numberRange = Range(numberNSRange) {
            let lowerBound = String.Index(utf16Offset: numberRange.lowerBound, in: text)
            if numberNSRange.lowerBound != 0 {
                heading = String(text[...text.index(lowerBound, offsetBy: -1)])
//                print("Heading is \(heading)")
            }
            numbers = String(text[lowerBound...])
//            print("number stuff is \(numbers)")
        } else {
            // the entire thing is the heading
            heading = text
//            print("no range")
        }

        var headingLocation: MappedLocation?
        var locationType: String?

        if let heading = heading {
            let headingSentences = splitIntoSentences(string: heading)
            var parsedHeading = parseHeading(components: headingSentences)
            headingLocation = parsedHeading.1
            locationType = parsedHeading.0
        }
        
        if let numbers = numbers {
            let numberSentences = splitIntoSentences(string: numbers)
            return parseNumbers(heading: headingLocation, numbers: numberSentences, locationType: locationType)
        } else if let headingLocation = headingLocation {
            return [headingLocation]
        } else {
            return []
        }
    }
    
    func parseToWKT() -> String? {
        var components = text.components(separatedBy: .newlines)
        
        return nil
    }
    
    func parseToGeoJSON() -> [SFGGeoJSONObject] {
        
        return []
    }
}
