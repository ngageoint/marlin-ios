//
//  Modu+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import Foundation
import CoreData
import OSLog

public class Modu: NSManagedObject {
    
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
    
    static func batchImport(from propertiesList: [ModuProperties], taskContext: NSManagedObjectContext, viewContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importModus"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Modu.newBatchInsertRequest(with: propertiesList)
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

struct ModuPropertyContainer: Decodable {
    let modu: [ModuProperties]
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
    let longitude: Decimal
    let latitude: Decimal
    let distance: Decimal?
    let specialStatus: String?
    let rigStatus: String?
    let position: String?
    let navArea: String?
    let name: String
    let date: Date?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawName = try? values.decode(String.self, forKey: .name)
        let rawLatitude = try? values.decode(Decimal.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Decimal.self, forKey: .longitude)
        
        // Ignore earthquakes with missing data.
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
        self.distance = try? values.decode(Decimal.self, forKey: .distance)
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

