//
//  DFRS+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import Foundation
import MapKit
import CoreData
import OSLog

extension DFRS: DataSource {
    var color: UIColor {
        return DFRS.color
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("DFRS", comment: "Radio Direction Finders and Radar station data source display name")
    static var fullDataSourceName: String = NSLocalizedString("Radio Direction Finders & Radar Stations", comment: "Radio Direction Finders and Radar station data source display name")
    static var key: String = "dfrs"
    static var imageName: String? = nil
    static var systemImageName: String? = "antenna.radiowaves.left.and.right.circle"
    
    static var color: UIColor = UIColor(argbValue: 0xFF00E676)
}

class DFRS: NSManagedObject, MKAnnotation, AnnotationWithView, MapImage {
    
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    
    var clusteringIdentifier: String? = nil
    
    var additionalKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Number", value: stationNumber),
            KeyValue(key: "Name", value: stationName),
            KeyValue(key: "Area Name", value: areaName),
            KeyValue(key: "Type", value: stationType),
            KeyValue(key: "Rx Position", value: rxPosition),
            KeyValue(key: "Tx Position", value: txPosition),
            KeyValue(key: "Frequency (kHz)", value: frequency),
            KeyValue(key: "Range (nmi)", value: "\(range)"),
            KeyValue(key: "Procedure", value: procedureText),
            KeyValue(key: "Remarks", value: remarks),
            KeyValue(key: "Notes", value: notes)
        ]
    }
    
    var txCoordinate: CLLocationCoordinate2D {
        if txPosition == nil {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: txLatitude, longitude: txLongitude)
    }
    
    var rxCoordinate: CLLocationCoordinate2D {
        if rxPosition == nil {
            return kCLLocationCoordinate2DInvalid
        }
        return CLLocationCoordinate2D(latitude: rxLatitude, longitude: rxLongitude)
    }
    
    var coordinate: CLLocationCoordinate2D {
        if CLLocationCoordinate2DIsValid(txCoordinate) {
            return txCoordinate
        } else if CLLocationCoordinate2DIsValid(rxCoordinate) {
            return rxCoordinate
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: AsamAnnotationView.ReuseID, for: self)
        self.annotationView = annotationView
        return annotationView
    }
    
    var annotationView: MKAnnotationView?
    
    func mapImage(marker: Bool = false, zoomLevel: Int) -> [UIImage] {
        let scale = marker ? 1 : 2
        var images: [UIImage] = []
        if zoomLevel > 12 {
            if let image = CircleImage(color: DFRS.color, radius: 4 * CGFloat(scale), fill: true) {
                images.append(image)
                if let dfrsImage = UIImage(systemName: "antenna.radiowaves.left.and.right.circle")?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                    images.append(dfrsImage)
                }
            }
        } else if zoomLevel > 5 {
            if let image = CircleImage(color: DFRS.color, radius: 4 * CGFloat(scale), fill: true) {
                images.append(image)
                if let dfrsImage = UIImage(systemName: "antenna.radiowaves.left.and.right.circle")?.aspectResize(to: CGSize(width: image.size.width / 1.5, height: image.size.height / 1.5)).withRenderingMode(.alwaysTemplate).maskWithColor(color: UIColor.white){
                    images.append(dfrsImage)
                }
            }
        } else {
            if let image = CircleImage(color: DFRS.color, radius: 1 * CGFloat(scale), fill: true) {
                images.append(image)
            }
        }
        return images
    }
    
    static func newBatchInsertRequest(with propertyList: [DFRSProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: DFRS.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [DFRSProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDFRS"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DFRS.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            throw MSIError.batchInsertError
        }
    }
    
    override var description: String {
        return "DFRS\n\n" +
        "Area Name: \(areaName ?? "")\n" +
        "frequency: \(frequency ?? "")\n" +
        "notes: \(notes ?? "")\n" +
        "procedure text: \(procedureText ?? "")\n" +
        "range: \(range)\n" +
        "remarks: \(remarks ?? "")\n" +
        "rx position: \(rxPosition ?? "")\n" +
        "station name: \(stationName ?? "")\n" +
        "station number: \(stationNumber ?? "")\n" +
        "station type: \(stationType ?? "")\n" +
        "tx position: \(txPosition ?? "")\n"
    }
}

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
                self.procedureText = "\(rawProcedureText.dropLast(2))"
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
                self.remarks = "\(rawRemarks.dropLast(2))"
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
            self.rxLongitude = 0.0
            self.rxLatitude = 0.0
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
            self.txLongitude = 0.0
            self.txLatitude = 0.0
            self.txPosition = nil
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
        
        let pattern = #"(?<latdeg>[0-9]*)°(?<latminutes>[0-9]*)'(?<latseconds>[0-9]*\.?[0-9]*)\"(?<latdirection>[NS]) \n(?<londeg>[0-9]*)°(?<lonminutes>[0-9]*)'(?<lonseconds>[0-9]*\.?[0-9]*)\"(?<londirection>[EW])"#
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsrange = NSRange(position.startIndex..<position.endIndex,
                              in: position)
        if let match = regex?.firstMatch(in: position,
                                         options: [],
                                         range: nsrange)
        {
            for component in ["latdeg", "latminutes", "latseconds", "latdirection"] {
                let nsrange = match.range(withName: component)
                if nsrange.location != NSNotFound,
                   let range = Range(nsrange, in: position)
                {
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
                   let range = Range(nsrange, in: position)
                {
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

class DFRSArea: NSManagedObject {
    static func newBatchInsertRequest(with propertyList: [DFRSAreaProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: DFRSArea.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [DFRSAreaProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importDFRSArea"
        
        /// - Tag: performAndWait
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = DFRSArea.newBatchInsertRequest(with: propertiesList)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            throw MSIError.batchInsertError
        }
    }
}

struct DFRSAreaPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case areas
    }
    let areas: [DFRSAreaProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        areas = try container.decode([Throwable<DFRSAreaProperties>].self, forKey: .areas).compactMap { try? $0.result.get()}
    }
}

struct DFRSAreaProperties: Decodable {
    
    // MARK: Codable
    
    private enum CodingKeys: String, CodingKey {
        case areaName
        case areaIndex
        case areaNote
        case noteIndex
        case indexNote
    }
    
    let areaName: String?
    let areaIndex: Int?
    let areaNote: String?
    let noteIndex: Int?
    let indexNote: String?
    
    init(from decoder: Decoder) throws {
        var values = try decoder.unkeyedContainer()
        /**
         [
         "CANADA",
         30,
         "The VHF direction finding stations of Canada are for emergency use only. All stations are remotely controlled by a Marine Communications and Traffic Services Center (MCTS). The following details of operation are common to all of these stations:",
         1,
         "A. Ch.16."
         ]
         */
        
        areaName = try? values.decode(String.self)
        areaIndex = try? values.decode(Int.self)
        areaNote = try? values.decodeIfPresent(String.self)
        noteIndex = try? values.decodeIfPresent(Int.self)
        indexNote = try? values.decodeIfPresent(String.self)
    }
    
    // The keys must have the same name as the attributes of the Asam entity.
    var dictionaryValue: [String: Any?] {
        [
            "areaName": areaName,
            "areaNote": areaNote,
            "areaIndex": areaIndex,
            "index": noteIndex,
            "indexNote": indexNote
        ]
    }
}

