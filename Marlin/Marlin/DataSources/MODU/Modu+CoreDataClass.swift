//
//  Modu+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import Foundation
import CoreData
import OSLog
import MapKit
import SwiftUI

extension Modu: DataSource {
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("MODU", comment: "MODU data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Mobile Offshore Drilling Units", comment: "MODU data source display name")
    static var key: String = "modu"
    static var imageName: String? = "modu"
    static var systemImageName: String? = nil
    static var seedDataFiles: [String]? = ["modu"]
    static var color: UIColor = UIColor(argbValue: 0xFF0042A4)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 0.75
    
    static func batchImport(value: Decodable?) async throws {
        guard let value = value as? ModuPropertyContainer else {
            return
        }
        let count = value.modu.count
        NSLog("Received \(count) \(Self.key) records.")
        try await Modu.batchImport(from: value.modu, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        let newestModu = try? PersistenceController.shared.container.viewContext.fetchFirst(Modu.self, sortBy: [NSSortDescriptor(keyPath: \Modu.date, ascending: false)])
        return [MSIRouter.readModus(date: newestModu?.dateString)]
    }
    
}

extension Modu: DataSourceViewBuilder {
    var detailView: AnyView {
        AnyView(ModuDetailView(modu: self))
    }
    
    func summaryView(showMoreDetails: Bool = false, showSectionHeader: Bool = false) -> AnyView {
        AnyView(ModuSummaryView(modu: self, showMoreDetails: showMoreDetails))
    }
}

class Modu: NSManagedObject, MKAnnotation, AnnotationWithView, EnlargableAnnotation, MapImage {
    var clusteringIdentifierWhenShrunk: String? = "msi"
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifier: String? = "msi"
    
    var color: UIColor {
        return Modu.color
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857)
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: ModuAnnotationView.ReuseID, for: self)
        self.annotationView = annotationView
        return annotationView
    }
    
    var annotationView: MKAnnotationView?
    
    var dateString: String? {
        if let date = date {
            return ModuProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    static func newBatchInsertRequest(with propertyList: [ModuProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Modu.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [ModuProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importModus"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Modu.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) MODU records")
                    NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceItem(dataSource: Modu.self))
                } else {
                    NSLog("No new MODU records")
                }
                return
            }
            throw MSIError.batchInsertError
        }
    }
    
    override var description: String {
        return "MODU\n\n" +
        "Name: \(name ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Position: \(position ?? "")\n" +
        "Rig Status: \(rigStatus ?? "")\n" +
        "Special Status: \(specialStatus ?? "")\n" +
        "distance: \(distance)\n" +
        "Navigation Area: \(navArea ?? "")\n" +
        "Region: \(region)\n" +
        "Sub Region: \(subregion)\n"
    }
}

struct ModuPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case modu
    }
    let modu: [ModuProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        modu = try container.decode([Throwable<ModuProperties>].self, forKey: .modu).compactMap { try? $0.result.get() }
    }
}

/// A struct encapsulating the properties of a Quake.
struct ModuProperties: Decodable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case subregion
        case region
        case longitude
        case latitude
        case distance
        case specialStatus
        case rigStatus
        case position
        case navArea
        case name
        case date
    }
    
    let subregion: Int?
    let region: Int?
    let longitude: Double
    let latitude: Double
    let distance: Double?
    let specialStatus: String?
    let rigStatus: String?
    let position: String?
    let navArea: String?
    let name: String
    let date: Date?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawName = try? values.decode(String.self, forKey: .name)
        let rawLatitude = try? values.decode(Double.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Double.self, forKey: .longitude)
        
        guard let name = rawName,
              let latitude = rawLatitude,
              let longitude = rawLongitude
        else {
            let values = "name = \(rawName?.description ?? "nil"), "
            + "latitude = \(rawLatitude?.description ?? "nil"), "
            + "longitude = \(rawLongitude?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.subregion = try? values.decode(Int.self, forKey: .subregion)
        self.region = try? values.decode(Int.self, forKey: .region)
        self.distance = try? values.decode(Double.self, forKey: .distance)
        self.specialStatus = try? values.decode(String.self, forKey: .specialStatus)
        self.rigStatus = try? values.decode(String.self, forKey: .rigStatus)
        self.position = try? values.decode(String.self, forKey: .position)
        self.navArea = try? values.decode(String.self, forKey: .navArea)
        
        var parsedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .date) {
            if let date = dateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.date = parsedDate
    }
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // The keys must have the same name as the attributes of the Modu entity.
    var dictionaryValue: [String: Any?] {
        [
            "subregion": subregion,
            "region": region,
            "longitude": longitude,
            "latitude": latitude,
            "distance": distance,
            "specialStatus": specialStatus,
            "rigStatus": rigStatus,
            "position": position,
            "navArea": navArea,
            "name": name,
            "date": date
        ]
    }
}

