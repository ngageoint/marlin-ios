//
//  DGPSStationListModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/29/24.
//

import Foundation
import CoreLocation

struct DGPSStationListModel: Hashable, Identifiable {
    var id: String {
        "\(featureNumber ?? 0)--\(volumeNumber ?? "")"
    }
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var featureNumber: Int?
    var volumeNumber: String?
    var name: String?
    var geopoliticalHeading: String?
    var sectionHeader: String?
    var stationID: String?
    var remarks: String?
    var latitude: Double
    var longitude: Double

    var canBookmark: Bool = false

    init() {
        self.canBookmark = false
        self.latitude = kCLLocationCoordinate2DInvalid.latitude
        self.longitude = kCLLocationCoordinate2DInvalid.longitude
    }

    init(differentialGPSStation: DifferentialGPSStation) {
        self.canBookmark = true
        self.featureNumber = Int(differentialGPSStation.featureNumber)
        self.volumeNumber = differentialGPSStation.volumeNumber
        self.name = differentialGPSStation.name
        self.geopoliticalHeading = differentialGPSStation.geopoliticalHeading
        self.sectionHeader = differentialGPSStation.sectionHeader
        self.stationID = differentialGPSStation.stationID
        self.remarks = differentialGPSStation.remarks
        self.latitude = differentialGPSStation.latitude
        self.longitude = differentialGPSStation.longitude
    }
}

extension DGPSStationListModel {
    var itemTitle: String {
        return "\(self.name ?? "\(self.featureNumber ?? 0)")"
    }
}

extension DGPSStationListModel: Bookmarkable {
    static var definition: any DataSourceDefinition {
        DataSources.dgps
    }

    var itemKey: String {
        return "\(featureNumber ?? 0)--\(volumeNumber ?? "")"
    }

    var key: String {
        DataSources.dgps.key
    }
}

extension DGPSStationListModel {
    init(dgpsStationModel: DGPSStationModel) {
        self.canBookmark = dgpsStationModel.canBookmark
        self.featureNumber = dgpsStationModel.featureNumber
        self.volumeNumber = dgpsStationModel.volumeNumber
        self.name = dgpsStationModel.name
        self.geopoliticalHeading = dgpsStationModel.geopoliticalHeading
        self.sectionHeader = dgpsStationModel.sectionHeader
        self.stationID = dgpsStationModel.stationID
        self.remarks = dgpsStationModel.remarks
        self.latitude = dgpsStationModel.latitude
        self.longitude = dgpsStationModel.longitude
    }
}
