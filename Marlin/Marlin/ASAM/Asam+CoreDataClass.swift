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

class Asam: NSManagedObject, MKAnnotation, AnnotationWithView {
    var coordinate: CLLocationCoordinate2D {
        if let latitude = latitude, let longitude = longitude {
            return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
        } else {
            return kCLLocationCoordinate2DInvalid
        }
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: AsamAnnotationView.ReuseID, for: self)
        let image = UIImage(named: "asam_marker")
        annotationView.image = image
        annotationView.centerOffset = CGPoint(x: 0, y: -(image!.size.height/2.0))
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
//            self.logger.debug("Failed to execute batch insert request.")
            throw MSIError.batchInsertError
        }
        
//        logger.debug("Successfully inserted data.")
    }
    
}

struct AsamPropertyContainer: Decodable {
    let asam: [AsamProperties]
}

/// A struct encapsulating the properties of a Quake.
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
    let latitude: Decimal
    let longitude: Decimal
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
        let rawLatitude = try? values.decode(Decimal.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Decimal.self, forKey: .longitude)
        
        // Ignore earthquakes with missing data.
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

