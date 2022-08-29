//
//  Asam+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/2/22.
//
//

import Foundation
import CoreData
import OSLog
import MapKit
import SwiftUI

extension Asam: DataSource {
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("ASAM", comment: "ASAM data source display name")
    static var key: String = "asam"
    static var imageName: String? = "asam"
    static var systemImageName: String? = nil
    
    static var color: UIColor = .black
}

class Asam: NSManagedObject, MKAnnotation, AnnotationWithView, EnlargableAnnotation, MapImage {
    var clusteringIdentifierWhenShrunk: String? = "msi"
    
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifier: String? = "msi"
    
    var color: UIColor {
        return Asam.color
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: AsamAnnotationView.ReuseID, for: self)
        self.annotationView = annotationView
        return annotationView
    }
    
    var annotationView: MKAnnotationView?
    
    var dateString: String? {
        if let date = date {
            return AsamProperties.dateFormatter.string(from: date)
        }
        return nil
    }
    
    func mapImage(marker: Bool = false, zoomLevel: Int) -> [UIImage] {
        let scale = marker ? 1 : 2
        var images: [UIImage] = []
        if zoomLevel > 12 {
            if let image = CircleImage(color: Asam.color, radius: 8 * CGFloat(scale), fill: true) {
                images.append(image)
                if let pirateImage = UIImage(named: "asam")?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                    images.append(pirateImage)
                }
            }
        } else if zoomLevel > 5 {
            if let image = CircleImage(color: Asam.color, radius: 4 * CGFloat(scale), fill: true) {
                images.append(image)
                if let pirateImage = UIImage(named: "asam")?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                    images.append(pirateImage)
                }
            }
        } else {
            if let image = CircleImage(color: Asam.color, radius: 1 * CGFloat(scale), fill: true) {
                images.append(image)
            }
        }
        return images
    }
    
    static func newBatchInsertRequest(with propertyList: [AsamProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Asam.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [AsamProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importAsams"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Asam.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            throw MSIError.batchInsertError
        }
    }
    
    override var description: String {
        return "ASAM\n\n" +
        "Reference: \(reference ?? "")\n" +
        "Date: \(dateString ?? "")\n" +
        "Latitude: \(latitude)\n" +
        "Longitude: \(longitude)\n" +
        "Navigate Area: \(navArea ?? "")\n" +
        "Subregion: \(subreg ?? "")\n" +
        "Description: \(asamDescription ?? "")\n" +
        "Hostility: \(hostility ?? "")\n" +
        "Victim: \(victim ?? "")\n"
    }
}

struct AsamPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case asam
    }
    let asam: [AsamProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        asam = try container.decode([Throwable<AsamProperties>].self, forKey: .asam).compactMap { try? $0.result.get() }
    }
}

struct AsamProperties: Decodable {
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case reference
        case position
        case navArea
        case subreg
        case hostility
        case victim
        case latitude
        case longitude
        case asamDescription = "description"
        case date
    }
    
    let reference: String?
    let latitude: Double
    let longitude: Double
    let position: String?
    let navArea: String?
    let subreg: String?
    let hostility: String?
    let victim: String?
    let asamDescription: String?
    let date: Date?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawReference = try? values.decode(String.self, forKey: .reference)
        let rawLatitude = try? values.decode(Double.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Double.self, forKey: .longitude)
        
        guard let reference = rawReference,
              let latitude = rawLatitude,
              let longitude = rawLongitude
        else {
            let values = "reference = \(rawReference?.description ?? "nil"), "
            + "latitude = \(rawLatitude?.description ?? "nil"), "
            + "longitude = \(rawLongitude?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored: \(values)")
            
            throw MSIError.missingData
        }
        
        self.reference = reference
        self.latitude = latitude
        self.longitude = longitude
        self.position = try? values.decode(String.self, forKey: .position)
        self.navArea = try? values.decode(String.self, forKey: .navArea)
        self.subreg = try? values.decode(String.self, forKey: .subreg)
        self.hostility = try? values.decode(String.self, forKey: .hostility)
        self.victim = try? values.decode(String.self, forKey: .victim)
        self.asamDescription = try? values.decode(String.self, forKey: .asamDescription)
        var parsedDate: Date? = nil
        if let dateString = try? values.decode(String.self, forKey: .date) {
            if let date = AsamProperties.dateFormatter.date(from: dateString) {
                parsedDate = date
            }
        }
        self.date = parsedDate
    }
    
    // The keys must have the same name as the attributes of the Asam entity.
    var dictionaryValue: [String: Any?] {
        [
            "reference": reference,
            "latitude": latitude,
            "longitude": longitude,
            "position": position,
            "navArea": navArea,
            "subreg": subreg,
            "hostility": hostility,
            "victim": victim,
            "asamDescription": asamDescription,
            "date": date
        ]
    }
}

