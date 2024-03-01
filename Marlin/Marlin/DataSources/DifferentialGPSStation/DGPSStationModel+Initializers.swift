//
//  DGPSStationModel+Initializers.swift
//  Marlin
//
//  Created by Daniel Barela on 2/29/24.
//

import Foundation
import mgrs_ios
import GeoJSON
import OSLog
import CoreLocation

extension DGPSStationModel {
    init(differentialGPSStation: DifferentialGPSStation) {
        self.canBookmark = true
        self.differentialGPSStation = differentialGPSStation
        self.aidType = differentialGPSStation.aidType
        self.deleteFlag = differentialGPSStation.deleteFlag
        self.featureNumber = Int(differentialGPSStation.featureNumber)
        self.frequency = Int(differentialGPSStation.frequency)
        self.geopoliticalHeading = differentialGPSStation.geopoliticalHeading
        self.latitude = differentialGPSStation.latitude
        self.longitude = differentialGPSStation.longitude
        self.name = differentialGPSStation.name
        self.noticeNumber = Int(differentialGPSStation.noticeNumber)
        self.noticeWeek = differentialGPSStation.noticeWeek
        self.noticeYear = differentialGPSStation.noticeYear
        self.position = differentialGPSStation.position
        self.postNote = differentialGPSStation.postNote
        self.precedingNote = differentialGPSStation.precedingNote
        self.range = Int(differentialGPSStation.range)
        self.regionHeading = differentialGPSStation.regionHeading
        self.remarks = differentialGPSStation.remarks
        self.removeFromList = differentialGPSStation.removeFromList
        self.sectionHeader = differentialGPSStation.sectionHeader
        self.stationID = differentialGPSStation.stationID
        self.transferRate = Int(differentialGPSStation.transferRate)
        self.volumeNumber = differentialGPSStation.volumeNumber
        self.mgrs10km = differentialGPSStation.mgrs10km
    }

    // This model has a lot of properties...
    // swiftlint:disable function_body_length
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        // this potentially is US and international feature number combined with a new line
        let rawFeatureNumber = try? values.decode(Int.self, forKey: .featureNumber)
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
        self.deleteFlag = try? values.decode(String.self, forKey: .deleteFlag)
        self.featureNumber = featureNumber
        self.frequency = try? values.decode(Int.self, forKey: .frequency)
        self.geopoliticalHeading = try? values.decode(String.self, forKey: .geopoliticalHeading)
        self.name = try? values.decode(String.self, forKey: .name)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.noticeWeek = try? values.decode(String.self, forKey: .noticeWeek)
        self.noticeYear = try? values.decode(String.self, forKey: .noticeYear)
        self.postNote = try? values.decode(String.self, forKey: .postNote)
        self.precedingNote = try? values.decode(String.self, forKey: .precedingNote)
        self.range = try? values.decode(Int.self, forKey: .range)
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
        let rawStationID = try? values.decode(String.self, forKey: .stationID)
        if let rawStationID = rawStationID {
            if rawStationID.hasSuffix("\n") {
                self.stationID = "\(rawStationID.dropLast(2))"
            } else {
                self.stationID = rawStationID
            }
        } else {
            self.stationID = nil
        }
        self.sectionHeader = try? values.decode(String.self, forKey: .sectionHeader)
        self.transferRate = try? values.decode(Int.self, forKey: .transferRate)

        if let position = self.position,
            let coordinate = CLLocationCoordinate2D(coordinateString: position) {
            self.longitude = coordinate.longitude
            self.latitude = coordinate.latitude
        } else {
            self.longitude = 0.0
            self.latitude = 0.0
        }

        if CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(
            latitude: latitude, longitude: longitude
        )) {
            let mgrsPosition = MGRS.from(longitude, latitude)
            self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
        }
    }
    // swiftlint:enable function_body_length

    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {

            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)

            if let model = try? decoder.decode(DGPSStationModel.self, from: jsonData) {
                self = model
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
