//
//  UserPlaceModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/26/24.
//

import Foundation
import CoreLocation

struct UserPlaceModel: Locatable, Bookmarkable, Codable, GeoJSONExportable, Hashable, Identifiable {
    var coordinate: CLLocationCoordinate2D {
        if let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return kCLLocationCoordinate2DInvalid
    }
    static var definition: any DataSourceDefinition = DataSources.userPlace

    var canBookmark: Bool = false

    var itemKey: String {
        return uri?.absoluteString ?? ""
    }

    var itemTitle: String {
        name ?? "User Defined Place"
    }

    var sfGeometry: SFGeometry?

    private enum CodingKeys: String, CodingKey {
        case date
        case json
        case latitude
        case longitude
        case maxLatitude
        case maxLongitude
        case minLatitude
        case minLongitude
        case name
        case uri
    }

    var date: Date?
    var json: String?
    var latitude: Double?
    var longitude: Double?
    var maxLatitude: Double?
    var maxLongitude: Double?
    var minLatitude: Double?
    var minLongitude: Double?
    var name: String?
    var uri: URL?

    init() {
        canBookmark = false
    }

    init(userPlace: UserPlace) {
        self.date = userPlace.date
        self.json = userPlace.json
        self.latitude = userPlace.latitude
        self.longitude = userPlace.longitude
        self.maxLatitude = userPlace.maxLatitude
        self.maxLongitude = userPlace.maxLongitude
        self.minLatitude = userPlace.minLatitude
        self.minLongitude = userPlace.minLongitude
        self.name = userPlace.name
        self.uri = userPlace.objectID.uriRepresentation()
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.date = try? values.decode(Date.self, forKey: .date)
        self.json = try? values.decode(String.self, forKey: .json)
        self.latitude = try? values.decode(Double.self, forKey: .latitude)
        self.longitude = try? values.decode(Double.self, forKey: .longitude)
        self.maxLatitude = try? values.decode(Double.self, forKey: .maxLatitude)
        self.maxLongitude = try? values.decode(Double.self, forKey: .maxLongitude)
        self.minLatitude = try? values.decode(Double.self, forKey: .minLatitude)
        self.minLongitude = try? values.decode(Double.self, forKey: .minLongitude)
        self.name = try? values.decode(String.self, forKey: .name)
        self.uri = try? values.decode(URL.self, forKey: .uri)
        self.canBookmark = false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(date, forKey: .date)
        try? container.encode(json, forKey: .json)
        try? container.encode(latitude, forKey: .latitude)
        try? container.encode(longitude, forKey: .longitude)
        try? container.encode(maxLatitude, forKey: .maxLatitude)
        try? container.encode(maxLongitude, forKey: .maxLongitude)
        try? container.encode(minLatitude, forKey: .minLatitude)
        try? container.encode(minLongitude, forKey: .minLongitude)
        try? container.encode(name, forKey: .name)
        try? container.encode(uri, forKey: .uri)
    }
}
