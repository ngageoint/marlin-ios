//
//  ElectronicPublication+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import Foundation
import CoreData

enum PublicationTypeEnum: Int, CaseIterable, CustomStringConvertible {
    case listOfLights = 9
    case atlasOfPilotCharts = 30
    case chartNo1 = 3
    case americanPracticalNavigator = 2
    case radioNavigationAids = 11
    case radarNavigationAndManeuveringBoardManual = 10
    case sightReductionTablesForAirNavigation = 13
    case worldPortIndex = 17
    case sightReductionTablesForMarineNavigation = 14
    case sailingDirectionsEnroute = 22
    case uscgLightList = 16
    case sailingDirectionsPlanningGuides = 21
    case internationalCodeOfSignals = 7
    case noticeToMarinersAndCorrections = 15
    case distanceBetweenPorts = 5
    case fleetGuides = 6
    case noaaTidalCurrentTables = 27
    case random = 40
    case tideTables = 26
    case unknown = -1
    
    static func fromValue(_ value: Int?) -> PublicationTypeEnum {
        guard let value = value else {
            return .unknown
        }
        return PublicationTypeEnum(rawValue: value) ?? .unknown
    }
    
    static func fromValue(_ value: String?) -> PublicationTypeEnum {
        guard let value = value else {
            return .unknown
        }
        guard let value = Int(value) else {
            return .unknown
        }
        return PublicationTypeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .listOfLights:
            return "List of Lights"
        case .atlasOfPilotCharts:
            return "Atlas of Pilot Charts"
        case .chartNo1:
            return "Chart No. 1"
        case .americanPracticalNavigator:
            return "American Practical Navigator"
        case .radioNavigationAids:
            return "Radio Navigation Aids"
        case .radarNavigationAndManeuveringBoardManual:
            return "Radar Navigation and Maneuvering Board Manual"
        case .sightReductionTablesForAirNavigation:
            return "Sight Reduction Tables for Air Navigation"
        case .sailingDirectionsEnroute:
            return "Sailing Directions Enroute"
        case .uscgLightList:
            return "USCG Light List"
        case .sailingDirectionsPlanningGuides:
            return "Sailing Directions Planning Guides"
        case .internationalCodeOfSignals:
            return "International Code of Signals"
        case .noticeToMarinersAndCorrections:
            return "Notice To Mariners and Corrections"
        case .distanceBetweenPorts:
            return "Distances Between Ports"
        case .fleetGuides:
            return "Fleet Guides"
        case .noaaTidalCurrentTables:
            return "NOAA Tidal Current Tables"
        case .random:
            return "Random"
        case .tideTables:
            return "Tide Tables"
        case .worldPortIndex:
            return "World Port Index"
        case .sightReductionTablesForMarineNavigation:
            return "Sight Reduction Tables for Marine Navigation"
        default:
            return "Electronic Publications"
        }
    }
    
    static var keyValueMap: [String: [String]] {
        PublicationTypeEnum.allCases.reduce(into: [String: [String]]()) {
            var array: [String] = $0[$1.description] ?? []
            array.append("\($1.rawValue)")
            return $0[$1.description] = array
        }
    }
}

protocol Downloadable: NSManagedObject {
    var isDownloaded: Bool { get set }
    var isDownloading: Bool { get set }
    var downloadProgress: Float { get set }
    var remoteLocation: URL? { get }
    var savePath: String { get }
    var title: String { get }
    func checkFileExists() -> Bool
    func deleteFile()
}

class ElectronicPublication: NSManagedObject, Downloadable {
        
    var title: String {
        return sectionDisplayName ?? "Electronic Publication"
    }
    var remoteLocation: URL? {
        guard let s3Key else {
            return nil
        }
        return URL(string: "https://msi.nga.mil/api/publications/download?key=\(s3Key)&type=download")
    }
    var savePath: String {
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return "\(docsUrl?.absoluteString ?? "")\(s3Key ?? "")"
    }
    override var description: String {
        return "Electronic Publication\n\n" +
        "Name: \(pubDownloadDisplayName ?? "")\n"
    }
    
    func deleteFile() {
        guard let s3Key else {
            return
        }
        let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileUrl = "\(docsUrl?.absoluteString ?? "")\(s3Key)"
        let destinationUrl = URL(string: fileUrl)
        
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
                PersistenceController.current.perform {
                    self.objectWillChange.send()
                    self.isDownloaded = false
                    DispatchQueue.main.async {
                        try? PersistenceController.current.save()
                    }
                }
            } catch let error {
                print("Error while deleting file: ", error)
            }
        }
    }
    
    func checkFileExists() -> Bool {
        var downloaded = false
        if let destinationUrl = URL(string: self.savePath) {
            downloaded = FileManager().fileExists(atPath: destinationUrl.path)
        }
        if downloaded != self.isDownloaded {
            PersistenceController.current.perform {
                self.objectWillChange.send()
                self.isDownloaded = downloaded
                DispatchQueue.main.async {
                    try? PersistenceController.current.save()
                }
            }
        }
        return downloaded
    }
    
    func downloadFile() {
        if isDownloaded && checkFileExists() {
            return
        }
        DownloadManager.shared.download(downloadable: self)
    }
}
