//
//  DFRS+Decodable.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import CoreLocation
import OSLog
import mgrs_ios

struct DFRSPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case dfrs = "radio-navaids"
    }
    let dfrs: [DFRSProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        dfrs = try container.decode([Throwable<DFRSProperties>].self, forKey: .dfrs).compactMap { try? $0.result.get() }
    }
}

struct DFRSProperties: Decodable {
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case areaName
        case frequency
        case notes
        case procedureText
        case range
        case remarks
        case rxPosition
        case stationName
        case stationNumber = "stationNo"
        case stationType
        case txPosition
    }
    
    let areaName: String?
    let frequency: String?
    let notes: String?
    let procedureText: String?
    let range: Double
    let remarks: String?
    let rxPosition: String?
    let rxLatitude: Double
    let rxLongitude: Double
    let stationName: String?
    let stationNumber: String?
    let stationType: String?
    let txPosition: String?
    let txLatitude: Double
    let txLongitude: Double
    var latitude: Double { txPosition != nil ? txLatitude : rxLatitude }
    var longitude: Double { txPosition != nil ? txLongitude : rxLongitude}
    var mgrs10km: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawStationNumber = try? values.decode(String.self, forKey: .stationNumber)
        let rawAreaName = try? values.decode(String.self, forKey: .areaName)
        
        guard let stationNumber = rawStationNumber,
              let areaName = rawAreaName
        else {
            let values = "station number = \(rawStationNumber?.description ?? "nil"), "
            + "area name = \(rawAreaName?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.stationNumber = stationNumber
        self.areaName = areaName
        self.frequency = try? values.decode(String.self, forKey: .frequency)
        self.notes = try? values.decode(String.self, forKey: .notes)
        let rawProcedureText = try? values.decode(String.self, forKey: .procedureText)
        if let rawProcedureText = rawProcedureText {
            if rawProcedureText.hasSuffix("\n") {
                self.procedureText = "\(rawProcedureText.dropLast(1))"
            } else {
                self.procedureText = rawProcedureText
            }
        } else {
            self.procedureText = nil
        }
        let rawRange = try? values.decode(String.self, forKey: .range)
        if let rawRange = rawRange {
            self.range = Double(rawRange) ?? 0.0
        } else {
            self.range = 0.0
        }
        let rawRemarks = try? values.decode(String.self, forKey: .remarks)
        if let rawRemarks = rawRemarks {
            if rawRemarks.hasSuffix("\n") {
                self.remarks = "\(rawRemarks.dropLast(1))"
            } else {
                self.remarks = rawRemarks
            }
        } else {
            self.remarks = nil
        }
        
        let rawRxPosition = try? values.decode(String.self, forKey: .rxPosition)
        if let position = rawRxPosition, rawRxPosition != " \n" {
            let coordinate = DFRSProperties.parsePosition(position: position)
            self.rxLongitude = coordinate.longitude
            self.rxLatitude = coordinate.latitude
            self.rxPosition = rawRxPosition
        } else {
            self.rxPosition = nil
            self.rxLongitude = -190.0
            self.rxLatitude = -190.0
        }
        
        self.stationName = try? values.decode(String.self, forKey: .stationName)
        self.stationType = try? values.decode(String.self, forKey: .stationType)
        
        let rawTxPosition = try? values.decode(String.self, forKey: .txPosition)
        if let position = rawTxPosition, rawTxPosition != " \n" {
            let coordinate = DFRSProperties.parsePosition(position: position)
            self.txLongitude = coordinate.longitude
            self.txLatitude = coordinate.latitude
            self.txPosition = rawTxPosition
        } else {
            self.txLongitude = -190.0
            self.txLatitude = -190.0
            self.txPosition = nil
        }
        if txPosition != nil || rxPosition != nil {
            let mgrsPosition = MGRS.from(longitude, latitude)
            self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
        }
    }
    
    // The keys must have the same name as the attributes of the Asam entity.
    var dictionaryValue: [String: Any?] {
        [
            "areaName": areaName,
            "frequency": frequency,
            "notes": notes,
            "procedureText": procedureText,
            "range": range,
            "remarks": remarks,
            "rxLatitude": rxLatitude,
            "rxLongitude": rxLongitude,
            "rxPosition": rxPosition,
            "stationName": stationName,
            "stationNumber": stationNumber,
            "stationType": stationType,
            "txLatitude": txLatitude,
            "txLongitude": txLongitude,
            "txPosition": txPosition,
            "latitude": latitude,
            "longitude": longitude
        ]
    }
    
    static func parsePosition(position: String) -> CLLocationCoordinate2D {
        var latitude = 0.0
        var longitude = 0.0
        // swiftlint:disable line_length
        let pattern = #"(?<latdeg>[0-9]*)°(?<latminutes>[0-9]*)'(?<latseconds>[0-9]*\.?[0-9]*)\"(?<latdirection>[NS]) \n(?<londeg>[0-9]*)°(?<lonminutes>[0-9]*)'(?<lonseconds>[0-9]*\.?[0-9]*)\"(?<londirection>[EW])"#
        // swiftlint:enable line_length

        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(position.startIndex..<position.endIndex,
                              in: position)
        if let match = regex?.firstMatch(in: position,
                                         options: [],
                                         range: nsrange) {
            for component in ["latdeg", "latminutes", "latseconds", "latdirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position) {
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
                   let range = Range(nsrange, in: position) {
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
}
