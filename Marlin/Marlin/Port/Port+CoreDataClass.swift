//
//  Port+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 8/16/22.
//

import Foundation
import MapKit
import CoreData
import OSLog

extension Port: DataSource {
    var color: UIColor {
        return Port.color
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Ports", comment: "Port data source display name")
    static var key: String = "port"
    static var imageName: String? = "port"
    static var systemImageName: String? = nil
    
    static var color: UIColor = UIColor(argbValue: 0xFF5856d6)
}

enum SizeEnum: String, CaseIterable, CustomStringConvertible {
    case V
    case S
    case M
    case L
    case unknown
    
    static func fromValue(_ value: String?) -> SizeEnum {
        guard let value = value else {
            return .unknown
        }
        return SizeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .V:
            return "Very Small"
        case .S:
            return "Small"
        case .M:
            return "Medium"
        case .L:
            return "Large"
        case .unknown:
            return ""
        }
    }
}

enum DecisionEnum: String, CaseIterable, CustomStringConvertible {
    case Y
    case N
    case U
    case UNK
    case unknown
    
    static func fromValue(_ value: String?) -> DecisionEnum {
        guard let value = value else {
            return .unknown
        }
        return DecisionEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .Y:
            return "Yes"
        case .N:
            return "No"
        default:
            return "Unknown"
        }
    }
}

enum RepairCodeEnum: String, CaseIterable, CustomStringConvertible {
    case A
    case B
    case C
    case D
    case N
    case unknown
    
    static func fromValue(_ value: String?) -> RepairCodeEnum {
        guard let value = value else {
            return .unknown
        }
        return RepairCodeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .A:
            return "Major"
        case .B:
            return "Moderate"
        case .C:
            return "Limited"
        case .D:
            return "Emergency Only"
        case .N:
            return "None"
        default:
            return "Unknown"
        }
    }
}

enum HarborTypeEnum: String, CaseIterable, CustomStringConvertible {
    case CB
    case CN
    case CT
    case LC
    case OR
    case RB
    case RN
    case RT
    case TH
    case unknown
    
    static func fromValue(_ value: String?) -> HarborTypeEnum {
        guard let value = value else {
            return .unknown
        }
        return HarborTypeEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .CB:
            return "Coastal Breakwater"
        case .CN:
            return "Coastal Natural"
        case .CT:
            return "Coastal Tide Gate"
        case .LC:
            return "Lake or Canal"
        case .OR:
            return "Open Roadstead"
        case .RB:
            return "River Basin"
        case .RN:
            return "River Natural"
        case .RT:
            return "River Tide Gate"
        case .TH:
            return "Typhoon Harbor"
        default:
            return "Unknown"
        }
    }
}

enum HarborUseEnum: String, CaseIterable, CustomStringConvertible {
    case FISH
    case MIL
    case CARGO
    case FERRY
    case UNK
    case unknown
    
    static func fromValue(_ value: String?) -> HarborUseEnum {
        guard let value = value else {
            return .unknown
        }
        return HarborUseEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .FISH:
            return "Fishing"
        case .MIL:
            return "Military"
        case .CARGO:
            return "Cargo"
        case .FERRY:
            return "Ferry"
        case .UNK:
            return "Unknown"
        default:
            return "Unknown"
        }
    }
}

enum UnderkeelClearanceEnum: String, CaseIterable, CustomStringConvertible {
    case S
    case D
    case N
    case U
    case unknown
    
    static func fromValue(_ value: String?) -> UnderkeelClearanceEnum {
        guard let value = value else {
            return .unknown
        }
        return UnderkeelClearanceEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .S:
            return "Static"
        case .D:
            return "Dynamic"
        case .N:
            return "None"
        case .U:
            return "Unknown"
        default:
            return "Unknown"
        }
    }
}

enum ConditionEnum: String, CaseIterable, CustomStringConvertible {
    case E
    case G
    case F
    case P
    case N
    case unknown
    
    static func fromValue(_ value: String?) -> ConditionEnum {
        guard let value = value else {
            return .unknown
        }
        return ConditionEnum(rawValue: value) ?? .unknown
    }
    
    var description: String {
        switch self {
        case .E:
            return "Excellent"
        case .G:
            return "Good"
        case .F:
            return "Fair"
        case .P:
            return "Poor"
        case .N:
            return "None"
        default:
            return ""
        }
    }
}

extension Int64 {
    var zeroIsEmptyString: String {
        if self == 0 {
            return ""
        }
        return "\(self)"
    }
}

class Port: NSManagedObject, MKAnnotation, AnnotationWithView {
    var annotationView: MKAnnotationView?
        
    var enlarged: Bool = false
    
    var shouldEnlarge: Bool = false
    
    var shouldShrink: Bool = false
    var clusteringIdentifier: String? = nil
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func distanceTo(_ location: CLLocation) -> Double {
        location.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    var nameAndLocationKeyValues: [KeyValue] {
        return [
            KeyValue(key: "World Port Index Number", value: "\(portNumber)"),
            KeyValue(key: "Region Name", value: "\(regionName ?? "") - \(regionNumber)"),
            KeyValue(key: "Main Port Name", value: portName),
            KeyValue(key: "Alternate Port Name", value: alternateName),
            KeyValue(key: "UN/LOCODE", value: unloCode),
            KeyValue(key: "Country", value: countryName),
            KeyValue(key: "World Water Body", value: dodWaterBody),
            KeyValue(key: "Sailing Directions or Publication", value: publicationNumber),
            KeyValue(key: "Standard Nautical Chart", value: chartNumber),
            KeyValue(key: "IHO S-57 Electronic Navigational Chart", value: s57Enc),
            KeyValue(key: "IHO S-101 Electronic Navigational Chart", value: s101Enc),
            KeyValue(key: "Digital Nautical Chart", value: dnc)
        ]
    }
    
    var depthKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Tidal Range (m)", value: "\(tide.zeroIsEmptyString)"),
            KeyValue(key: "Entrance Width (m)", value: "\(entranceWidth.zeroIsEmptyString)"),
            KeyValue(key: "Channel Depth (m)", value: "\(channelDepth.zeroIsEmptyString)"),
            KeyValue(key: "Anchorage Depth (m)", value: "\(anchorageDepth.zeroIsEmptyString)"),
            KeyValue(key: "Cargo Pier Depth (m)", value: "\(cargoPierDepth.zeroIsEmptyString)"),
            KeyValue(key: "Oil Terminal Depth (m)", value: "\(oilTerminalDepth.zeroIsEmptyString)"),
            KeyValue(key: "Liquified Natural Gas Terminal Depth (m)", value: "\(liquifiedNaturalGasTerminalDepth.zeroIsEmptyString)")
            ]
    }
    
    var maximumVesselSizeKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Maximum Vessel Length (m)", value: "\(maxVesselLength.zeroIsEmptyString)"),
            KeyValue(key: "Maximum Vessel Beam (m)", value: "\(maxVesselBeam.zeroIsEmptyString)"),
            KeyValue(key: "Maximum Vessel Draft (m)", value: "\(maxVesselDraft.zeroIsEmptyString)"),
            KeyValue(key: "Offshore Maximum Vessel Length (m)", value: "\(offshoreMaxVesselLength.zeroIsEmptyString)"),
            KeyValue(key: "Offshore Maximum Vessel Beam (m)", value: "\(offshoreMaxVesselBeam.zeroIsEmptyString)"),
            KeyValue(key: "Offshore Maximum Vessel Draft (m)", value: "\(offshoreMaxVesselDraft.zeroIsEmptyString)")
            ]
    }
    
    var physicalEnvironmentKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Harbor Size", value: "\(SizeEnum.fromValue(harborSize))"),
            KeyValue(key: "Harbor Type", value: "\(HarborTypeEnum.fromValue(harborType))"),
            KeyValue(key: "Harbor Use", value: "\(HarborUseEnum.fromValue(harborUse))"),
            KeyValue(key: "Shelter", value: "\(ConditionEnum.fromValue(shelter))"),
            KeyValue(key: "Entrance Restriction - Tide", value: "\(DecisionEnum.fromValue(erTide))"),
            KeyValue(key: "Entrance Restriction - Heavy Swell", value: "\(DecisionEnum.fromValue(erSwell))"),
            KeyValue(key: "Entrance Restriction - Ice", value: "\(DecisionEnum.fromValue(erIce))"),
            KeyValue(key: "Entrance Restriction - Other", value: "\(DecisionEnum.fromValue(erOther))"),
            KeyValue(key: "Overhead Limits", value: "\(DecisionEnum.fromValue(overheadLimits))"),
            KeyValue(key: "Underkeel Clearance Management System", value: "\(UnderkeelClearanceEnum.fromValue(ukcMgmtSystem))"),
            KeyValue(key: "Good Holding Ground", value: "\(DecisionEnum.fromValue(goodHoldingGround))"),
            KeyValue(key: "Turning Area", value: "\(DecisionEnum.fromValue(turningArea))")
        ]
    }
    
    var approachKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Port Security", value: "\(DecisionEnum.fromValue(portSecurity))"),
            KeyValue(key: "Estimated Time Of Arrival Message", value: "\(DecisionEnum.fromValue(etaMessage))"),
            KeyValue(key: "Quarantine - Pratique", value: "\(DecisionEnum.fromValue(qtPratique))"),
            KeyValue(key: "Quarantine - Sanitation", value: "\(DecisionEnum.fromValue(qtSanitation))"),
            KeyValue(key: "Quarantine - Other", value: "\(DecisionEnum.fromValue(qtOther))"),
            KeyValue(key: "Traffic Separation Scheme", value: "\(DecisionEnum.fromValue(trafficSeparationScheme))"),
            KeyValue(key: "Vessel Traffic Service", value: "\(DecisionEnum.fromValue(vesselTrafficService))"),
            KeyValue(key: "First Port Of Entry", value: "\(DecisionEnum.fromValue(firstPortOfEntry))"),
        ]
    }
    
    var pilotsTugsCommunicationsKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Pilotage - Compulsory", value: "\(DecisionEnum.fromValue(ptCompulsory))"),
            KeyValue(key: "Pilotage - Available", value: "\(DecisionEnum.fromValue(ptAvailable))"),
            KeyValue(key: "Pilotage - Local Assistance", value: "\(DecisionEnum.fromValue(ptLocalAssist))"),
            KeyValue(key: "Pilotage - Advisable", value: "\(DecisionEnum.fromValue(ptAdvisable))"),
            KeyValue(key: "Tugs - Salvage", value: "\(DecisionEnum.fromValue(tugsSalvage))"),
            KeyValue(key: "Tugs - Assistance", value: "\(DecisionEnum.fromValue(tugsAssist))"),
            KeyValue(key: "Communications - Telephone", value: "\(DecisionEnum.fromValue(cmTelephone))"),
            KeyValue(key: "Communications - Telefax", value: "\(DecisionEnum.fromValue(cmTelegraph))"),
            KeyValue(key: "Communications - Radio", value: "\(DecisionEnum.fromValue(cmRadio))"),
            KeyValue(key: "Communications - Radiotelephone", value: "\(DecisionEnum.fromValue(cmRadioTel))"),
            KeyValue(key: "Communications - Airport", value: "\(DecisionEnum.fromValue(cmAir))"),
            KeyValue(key: "Communications - Rail", value: "\(DecisionEnum.fromValue(cmRail))"),
            KeyValue(key: "Search and Rescue", value: "\(DecisionEnum.fromValue(searchAndRescue))"),
            KeyValue(key: "NAVAREA", value: navArea),
        ]
    }
    
    var facilitiesKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Facilities - Wharves", value: "\(DecisionEnum.fromValue(loWharves))"),
            KeyValue(key: "Facilities - Anchorage", value: "\(DecisionEnum.fromValue(loAnchor))"),
            KeyValue(key: "Facilities - Dangerous Cargo Anchorage", value: "\(DecisionEnum.fromValue(loDangCargo))"),
            KeyValue(key: "Facilities - Med Mooring", value: "\(DecisionEnum.fromValue(loMedMoor))"),
            KeyValue(key: "Facilities - Beach Mooring", value: "\(DecisionEnum.fromValue(loBeachMoor))"),
            KeyValue(key: "Facilities - Ice Mooring", value: "\(DecisionEnum.fromValue(loIceMoor))"),
            KeyValue(key: "Facilities - RoRo", value: "\(DecisionEnum.fromValue(loRoro))"),
            KeyValue(key: "Facilities - Solid Bulk", value: "\(DecisionEnum.fromValue(loSolidBulk))"),
            KeyValue(key: "Facilities - Liquid Bulk", value: "\(DecisionEnum.fromValue(loLiquidBulk))"),
            KeyValue(key: "Facilities - Container", value: "\(DecisionEnum.fromValue(loContainer))"),
            KeyValue(key: "Facilities - Breakbulk", value: "\(DecisionEnum.fromValue(loBreakBulk))"),
            KeyValue(key: "Facilities - Oil Terminal", value: "\(DecisionEnum.fromValue(loOilTerm))"),
            KeyValue(key: "Facilities - LNG Terminal", value: "\(DecisionEnum.fromValue(loLongTerm))"),
            KeyValue(key: "Facilities - Other", value: "\(DecisionEnum.fromValue(loOther))"),
            KeyValue(key: "Medical Facilities", value: "\(DecisionEnum.fromValue(medFacilities))"),
            KeyValue(key: "Garbage Disposal", value: "\(DecisionEnum.fromValue(garbageDisposal))"),
            KeyValue(key: "Chemical Holding Tank Disposal", value: "\(DecisionEnum.fromValue(chemicalHoldingTank))"),
            KeyValue(key: "Degaussing", value: "\(DecisionEnum.fromValue(degauss))"),
            KeyValue(key: "Dirty Ballast Disposal", value: "\(DecisionEnum.fromValue(dirtyBallast))"),
        ]
    }
    
    var cranesKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Cranes - Fixed", value: "\(DecisionEnum.fromValue(craneFixed))"),
            KeyValue(key: "Cranes - Mobile", value: "\(DecisionEnum.fromValue(craneMobile))"),
            KeyValue(key: "Cranes - Floating", value: "\(DecisionEnum.fromValue(craneFloating))"),
            KeyValue(key: "Cranes - Container", value: "\(DecisionEnum.fromValue(craneContainer))"),
            KeyValue(key: "Lifts - 100+ Tons", value: "\(DecisionEnum.fromValue(lifts100))"),
            KeyValue(key: "Lifts - 50-100 Tons", value: "\(DecisionEnum.fromValue(lifts50))"),
            KeyValue(key: "Lifts - 25-49 Tons", value: "\(DecisionEnum.fromValue(lifts25))"),
            KeyValue(key: "Lifts - 0-24 Tons", value: "\(DecisionEnum.fromValue(lifts0))"),
        ]
    }
    
    var servicesSuppliesKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Services - Longshoremen", value: "\(DecisionEnum.fromValue(srLongshore))"),
            KeyValue(key: "Services - Electricity", value: "\(DecisionEnum.fromValue(srElectrical))"),
            KeyValue(key: "Services - Steam", value: "\(DecisionEnum.fromValue(srSteam))"),
            KeyValue(key: "Services - Navigational Equipment", value: "\(DecisionEnum.fromValue(srNavigationalEquipment))"),
            KeyValue(key: "Services - Electrical Repair", value: "\(DecisionEnum.fromValue(srElectricalRepair))"),
            KeyValue(key: "Services - Ice Breaking", value: "\(DecisionEnum.fromValue(srIceBreaking))"),
            KeyValue(key: "Services - Diving", value: "\(DecisionEnum.fromValue(srDiving))"),
            KeyValue(key: "Supplies - Provisions", value: "\(DecisionEnum.fromValue(suProvisions))"),
            KeyValue(key: "Supplies - Potable Water", value: "\(DecisionEnum.fromValue(suWater))"),
            KeyValue(key: "Supplies - Fuel Oil", value: "\(DecisionEnum.fromValue(suFuel))"),
            KeyValue(key: "Supplies - Diesel Oil", value: "\(DecisionEnum.fromValue(suDiesel))"),
            KeyValue(key: "Supplies - Aviation Fuel", value: "\(DecisionEnum.fromValue(suAviationFuel))"),
            KeyValue(key: "Supplies - Deck", value: "\(DecisionEnum.fromValue(suDeck))"),
            KeyValue(key: "Supplies - Engine", value: "\(DecisionEnum.fromValue(suEngine))"),
            KeyValue(key: "Repair Code", value: "\(RepairCodeEnum.fromValue(repairCode))"),
            KeyValue(key: "Dry Dock", value: "\(SizeEnum.fromValue(drydock))"),
            KeyValue(key: "Railway", value: "\(SizeEnum.fromValue(railway))"),
        ]
    }

    static func newBatchInsertRequest(with propertyList: [PortProperties]) -> NSBatchInsertRequest {
        var index = 0
        let total = propertyList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Port.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: propertyList[index].dictionaryValue.filter({
                return $0.value != nil
            }) as [AnyHashable : Any])
            index += 1
            return false
        })
        return batchInsertRequest
    }
    
    static func batchImport(from propertiesList: [PortProperties], taskContext: NSManagedObjectContext) async throws {
        guard !propertiesList.isEmpty else { return }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importPorts"
        
        try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Port.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            do {
                let fetchResult = try taskContext.execute(batchInsertRequest)
                if let batchInsertResult = fetchResult as? NSBatchInsertResult,
                   let success = batchInsertResult.result as? Int {
                    print("Inserted \(success) ports")
                    return
                }
            } catch {
                print("error was \(error)")
            }
            throw MSIError.batchInsertError
        }
    }
    
    func mapImage(marker: Bool = false, small: Bool = false) -> [UIImage] {
        let scale = marker ? 1 : 2
        
        var images: [UIImage] = []
        
        if let portImage = portImage(scale: scale, small: small) {
    
            images.append(portImage)
        }
        
        return images
    }
    
    func portImage(scale: Int, small: Bool = false) -> UIImage? {
//        if small {
        return LightColorImage(frame: CGRect(x: 0, y: 0, width: 5 * scale, height: 5 * scale), colors: [Port.color], outerStroke: false)
//        } else {
//            return RaconImage(frame: CGRect(x: 0, y: 0, width: 100 * scale, height: 20 * scale), arcWidth: Double(2 * scale), arcRadius: Double(8 * scale), text: "Racon (\(morseLetter))\n\(remarks?.replacingOccurrences(of: "\n", with: "") ?? "")", darkMode: false)
//        }
    }
    
    func view(on: MKMapView) -> MKAnnotationView {
        let annotationView = on.dequeueReusableAnnotationView(withIdentifier: LightAnnotationView.ReuseID, for: self)
        let images = self.mapImage(marker: true)
        
        let largestSize = images.reduce(CGSize(width: 0, height: 0)) { partialResult, image in
            return CGSize(width: max(partialResult.width, image.size.width), height: max(partialResult.height, image.size.height))
        }
        
        UIGraphicsBeginImageContext(largestSize)
        for image in images {
            image.draw(at: CGPoint(x: (largestSize.width / 2.0) - (image.size.width / 2.0), y: (largestSize.height / 2.0) - (image.size.height / 2.0)))
        }
        
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        guard let cgImage = newImage.cgImage else {
            return annotationView
        }
        let image = UIImage(cgImage: cgImage)
        
        if let lav = annotationView as? LightAnnotationView {
            lav.combinedImage = image
        } else {
            annotationView.image = image
        }
        self.annotationView = annotationView
        return annotationView
    }
}

struct PortPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ports
    }
    let ports: [PortProperties]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ports = try container.decode([Throwable<PortProperties>].self, forKey: .ports).compactMap { try? $0.result.get() }
    }
}

struct PortProperties: Decodable {
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case alternateName
        case anchorageDepth = "anDepth"
        case cargoPierDepth = "cpDepth"
        case channelDepth = "chDepth"
        case chartNumber
        case chemicalHoldingTank = "cht"
        case cmAir
        case cmRadio
        case cmRadioTel
        case cmRail
        case cmTelephone
        case cmTelegraph
        case countryCode
        case countryName
        case craneContainer = "cranesContainer"
        case craneFixed = "crFixed"
        case craneFloating = "crFloating"
        case craneMobile = "crMobile"
        case degauss
        case dirtyBallast
        case dnc
        case dodWaterBody
        case drydock
        case entranceWidth
        case erIce
        case erOther
        case erSwell
        case erTide
        case etaMessage
        case firstPortOfEntry
        case garbageDisposal
        case harborSize
        case harborType
        case harborUse
        case latitude = "ycoord"
        case latitudeDms = "latitude"
        case lifts0
        case lifts25
        case lifts50
        case lifts100
        case liquifiedNaturalGasTerminalDepth = "lngTerminalDepth"
        case loAnchor
        case loBeachMoor
        case loBreakBulk
        case loContainer
        case loDangCargo
        case loIceMoor
        case loLiquidBulk
        case loLongTerm
        case loMedMoor
        case longitude = "xcoord"
        case longitudeDms = "longitude"
        case loOilTerm
        case loOther
        case loRoro
        case loSolidBulk
        case loWharves
        case maxVesselBeam
        case maxVesselDraft
        case maxVesselLength
        case medFacilities
        case navArea
        case offshoreMaxVesselBeam = "offMaxVesselBeam"
        case offshoreMaxVesselDraft = "offMaxVesselDraft"
        case offshoreMaxVesselLength = "offMaxVesselLength"
        case oilTerminalDepth = "otDepth"
        case overheadLimits = "overheadLimits"
        case portName
        case portNumber
        case portSecurity
        case ptAdvisable
        case ptAvailable
        case ptCompulsory
        case ptLocalAssist
        case publicationNumber
        case qtOther
        case qtPratique
        case qtSanitation
        case railway
        case regionName
        case regionNumber
        case repairCode
        case s57Enc
        case s101Enc
        case searchAndRescue
        case shelter
        case srDiving
        case srElectricalRepair = "srElectRepair"
        case srElectrical
        case srIceBreaking
        case srLongshore
        case srNavigationalEquipment = "srNavigEquip"
        case srSteam
        case suAviationFuel
        case suDeck
        case suDiesel
        case suEngine
        case suFuel
        case suProvisions
        case suWater
        case tide
        case trafficSeparationScheme = "tss"
        case tugsAssist
        case tugsSalvage
        case turningArea
        case ukcMgmtSystem
        case unloCode
        case usRep
        case vesselTrafficService = "vts"
    }
    
    let alternateName: String?
    let anchorageDepth: Int?
    let cargoPierDepth: Int?
    let channelDepth: Int?
    let chartNumber: String?
    let chemicalHoldingTank: String?
    let cmAir: String?
    let cmRadio: String?
    let cmRadioTel: String?
    let cmRail: String?
    let cmTelephone: String?
    let cmTelegraph: String?
    let countryCode: String?
    let countryName: String?
    let craneContainer: String?
    let craneFixed: String?
    let craneFloating: String?
    let craneMobile: String?
    let degauss: String?
    let dirtyBallast: String?
    let dnc: String?
    let dodWaterBody: String?
    let drydock: String?
    let entranceWidth: Int?
    let erIce: String?
    let erOther: String?
    let erSwell: String?
    let erTide: String?
    let etaMessage: String?
    let firstPortOfEntry: String?
    let garbageDisposal: String?
    let harborSize: String?
    let harborType: String?
    let harborUse: String?
    let latitude: Double
    let latitudeDms: String?
    let lifts0: String?
    let lifts25: String?
    let lifts50: String?
    let lifts100: String?
    let liquifiedNaturalGasTerminalDepth: Int?
    let loAnchor: String?
    let loBeachMoor: String?
    let loBreakBulk: String?
    let loContainer: String?
    let loDangCargo: String?
    let loIceMoor: String?
    let loLiquidBulk: String?
    let loLongTerm: String?
    let loMedMoor: String?
    let longitude: Double
    let longitudeDms: String?
    let loOilTerm: String?
    let loOther: String?
    let loRoro: String?
    let loSolidBulk: String?
    let loWharves: String?
    let maxVesselBeam: Int?
    let maxVesselDraft: Int?
    let maxVesselLength: Int?
    let medFacilities: String?
    let navArea: String?
    let offshoreMaxVesselBeam: Int?
    let offshoreMaxVesselDraft: Int?
    let offshoreMaxVesselLength: Int?
    let oilTerminalDepth: Int?
    let overheadLimits: String?
    let portName: String?
    let portNumber: Int
    let portSecurity: String?
    let ptAdvisable: String?
    let ptAvailable: String?
    let ptCompulsory: String?
    let ptLocalAssist: String?
    let publicationNumber: String?
    let qtOther: String?
    let qtPratique: String?
    let qtSanitation: String?
    let railway: String?
    let regionName: String?
    let regionNumber: Int?
    let repairCode: String?
    let s57Enc: String?
    let s101Enc: String?
    let searchAndRescue: String?
    let shelter: String?
    let srDiving: String?
    let srElectricalRepair: String?
    let srElectrical: String?
    let srIceBreaking: String?
    let srLongshore: String?
    let srNavigationalEquipment: String?
    let srSteam: String?
    let suAviationFuel: String?
    let suDeck: String?
    let suDiesel: String?
    let suEngine: String?
    let suFuel: String?
    let suProvisions: String?
    let suWater: String?
    let tide: Int?
    let trafficSeparationScheme: String?
    let tugsAssist: String?
    let tugsSalvage: String?
    let turningArea: String?
    let ukcMgmtSystem: String?
    let unloCode: String?
    let usRep: String?
    let vesselTrafficService: String?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawPortNumber = try? values.decode(Int.self, forKey: .portNumber)
        let rawLatitude = try? values.decode(Double.self, forKey: .latitude)
        let rawLongitude = try? values.decode(Double.self, forKey: .longitude)

        guard let portNumber = rawPortNumber,
              let latitude = rawLatitude,
              let longitude = rawLongitude
        else {
            let values = "reference = \(rawPortNumber?.description ?? "nil"), "
            + "latitude = \(rawLatitude?.description ?? "nil"), "
            + "longitude = \(rawLongitude?.description ?? "nil")"
            
            let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "parsing")
            logger.debug("Ignored Port... \(values)")
            
            throw MSIError.missingData
        }
        
        self.portNumber = portNumber
        self.latitude = latitude
        self.longitude = longitude
        self.alternateName = try? values.decode(String.self, forKey: .alternateName)
        if let anchorageDepthString = try? values.decode(String.self, forKey: .anchorageDepth) {
            self.anchorageDepth = Int(anchorageDepthString)
        } else {
            self.anchorageDepth = nil
        }
        if let cargoPierDepthString = try? values.decode(String.self, forKey: .cargoPierDepth) {
            self.cargoPierDepth = Int(cargoPierDepthString)
            if self.cargoPierDepth == nil {
                print("xxxx depth is nil  \(cargoPierDepthString)")
            }
        } else {
            self.cargoPierDepth = nil
        }
        if let channelDepthString = try? values.decode(String.self, forKey: .channelDepth) {
            self.channelDepth = Int(channelDepthString)
        } else {
            self.channelDepth = nil
        }
        self.chartNumber = try? values.decode(String.self, forKey: .chartNumber)
        self.chemicalHoldingTank = try? values.decode(String.self, forKey: .chemicalHoldingTank)
        self.cmAir = try? values.decode(String.self, forKey: .cmAir)
        self.cmRadio = try? values.decode(String.self, forKey: .cmRadio)
        self.cmRadioTel = try? values.decode(String.self, forKey: .cmRadioTel)
        self.cmRail = try? values.decode(String.self, forKey: .cmRail)
        self.cmTelephone = try? values.decode(String.self, forKey: .cmTelephone)
        self.cmTelegraph = try? values.decode(String.self, forKey: .cmTelegraph)
        self.countryCode = try? values.decode(String.self, forKey: .countryCode)
        self.countryName = try? values.decode(String.self, forKey: .countryName)
        self.craneContainer = try? values.decode(String.self, forKey: .craneContainer)
        self.craneFixed = try? values.decode(String.self, forKey: .craneFixed)
        self.craneFloating = try? values.decode(String.self, forKey: .craneFloating)
        self.craneMobile = try? values.decode(String.self, forKey: .craneMobile)
        self.degauss = try? values.decode(String.self, forKey: .degauss)
        self.dirtyBallast = try? values.decode(String.self, forKey: .dirtyBallast)
        self.dnc = try? values.decode(String.self, forKey: .dnc)
        self.dodWaterBody = try? values.decode(String.self, forKey: .dodWaterBody)
        self.drydock = try? values.decode(String.self, forKey: .drydock)
        self.entranceWidth = try? values.decode(Int.self, forKey: .entranceWidth)
        self.erIce = try? values.decode(String.self, forKey: .erIce)
        self.erOther = try? values.decode(String.self, forKey: .erOther)
        self.erSwell = try? values.decode(String.self, forKey: .erSwell)
        self.erTide = try? values.decode(String.self, forKey: .erTide)
        self.etaMessage = try? values.decode(String.self, forKey: .etaMessage)
        self.firstPortOfEntry = try? values.decode(String.self, forKey: .firstPortOfEntry)
        self.garbageDisposal = try? values.decode(String.self, forKey: .garbageDisposal)
        self.harborSize = try? values.decode(String.self, forKey: .harborSize)
        self.harborType = try? values.decode(String.self, forKey: .harborType)
        self.harborUse = try? values.decode(String.self, forKey: .harborUse)
        self.latitudeDms = try? values.decode(String.self, forKey: .latitudeDms)
        self.lifts0 = try? values.decode(String.self, forKey: .lifts0)
        self.lifts25 = try? values.decode(String.self, forKey: .lifts25)
        self.lifts50 = try? values.decode(String.self, forKey: .lifts50)
        self.lifts100 = try? values.decode(String.self, forKey: .lifts100)
        self.liquifiedNaturalGasTerminalDepth  = try? values.decode(Int.self, forKey: .liquifiedNaturalGasTerminalDepth)
        self.loAnchor = try? values.decode(String.self, forKey: .loAnchor)
        self.loBeachMoor = try? values.decode(String.self, forKey: .loBeachMoor)
        self.loBreakBulk = try? values.decode(String.self, forKey: .loBreakBulk)
        self.loContainer = try? values.decode(String.self, forKey: .loContainer)
        self.loDangCargo = try? values.decode(String.self, forKey: .loDangCargo)
        self.loIceMoor = try? values.decode(String.self, forKey: .loIceMoor)
        self.loLiquidBulk = try? values.decode(String.self, forKey: .loLiquidBulk)
        self.loLongTerm = try? values.decode(String.self, forKey: .loLongTerm)
        self.loMedMoor = try? values.decode(String.self, forKey: .loMedMoor)
        self.longitudeDms = try? values.decode(String.self, forKey: .longitudeDms)
        self.loOilTerm = try? values.decode(String.self, forKey: .loOilTerm)
        self.loOther = try? values.decode(String.self, forKey: .loOther)
        self.loRoro = try? values.decode(String.self, forKey: .loRoro)
        self.loSolidBulk = try? values.decode(String.self, forKey: .loSolidBulk)
        self.loWharves = try? values.decode(String.self, forKey: .loWharves)
        if let maxVesselBeamString = try? values.decode(String.self, forKey: .maxVesselBeam) {
            self.maxVesselBeam = Int(maxVesselBeamString)
        } else {
            self.maxVesselBeam = nil
        }
        if let maxVesselDraftString = try? values.decode(String.self, forKey: .maxVesselDraft) {
            self.maxVesselDraft = Int(maxVesselDraftString)
        } else {
            self.maxVesselDraft = nil
        }
        if let maxVesselLengthString = try? values.decode(String.self, forKey: .maxVesselLength) {
            self.maxVesselLength = Int(maxVesselLengthString)
        } else {
            self.maxVesselLength = nil
        }
        self.medFacilities = try? values.decode(String.self, forKey: .medFacilities)
        self.navArea = try? values.decode(String.self, forKey: .navArea)
        self.offshoreMaxVesselBeam = try? values.decode(Int.self, forKey: .offshoreMaxVesselBeam)
        self.offshoreMaxVesselDraft = try? values.decode(Int.self, forKey: .offshoreMaxVesselDraft)
        self.offshoreMaxVesselLength = try? values.decode(Int.self, forKey: .offshoreMaxVesselLength)

        if let oilTerminalDepthString = try? values.decode(String.self, forKey: .oilTerminalDepth) {
            self.oilTerminalDepth = Int(oilTerminalDepthString)
        } else {
            self.oilTerminalDepth = nil
        }
        self.overheadLimits = try? values.decode(String.self, forKey: .overheadLimits)
        self.portName = try? values.decode(String.self, forKey: .portName)
        self.portSecurity = try? values.decode(String.self, forKey: .portSecurity)
        self.ptAdvisable = try? values.decode(String.self, forKey: .ptAdvisable)
        self.ptAvailable = try? values.decode(String.self, forKey: .ptAvailable)
        self.ptCompulsory = try? values.decode(String.self, forKey: .ptCompulsory)
        self.ptLocalAssist = try? values.decode(String.self, forKey: .ptLocalAssist)
        self.publicationNumber = try? values.decode(String.self, forKey: .publicationNumber)
        self.qtOther = try? values.decode(String.self, forKey: .qtOther)
        self.qtPratique = try? values.decode(String.self, forKey: .qtPratique)
        self.qtSanitation = try? values.decode(String.self, forKey: .qtSanitation)
        self.railway = try? values.decode(String.self, forKey: .railway)
        self.regionName = try? values.decode(String.self, forKey: .regionName)
        self.regionNumber  = try? values.decode(Int.self, forKey: .regionNumber)
        self.repairCode = try? values.decode(String.self, forKey: .repairCode)
        self.s57Enc = try? values.decode(String.self, forKey: .s57Enc)
        self.s101Enc = try? values.decode(String.self, forKey: .s101Enc)
        self.searchAndRescue = try? values.decode(String.self, forKey: .searchAndRescue)
        self.shelter = try? values.decode(String.self, forKey: .shelter)
        self.srDiving = try? values.decode(String.self, forKey: .srDiving)
        self.srElectricalRepair = try? values.decode(String.self, forKey: .srElectricalRepair)
        self.srElectrical = try? values.decode(String.self, forKey: .srElectrical)
        self.srIceBreaking = try? values.decode(String.self, forKey: .srIceBreaking)
        self.srLongshore = try? values.decode(String.self, forKey: .srLongshore)
        self.srNavigationalEquipment = try? values.decode(String.self, forKey: .srNavigationalEquipment)
        self.srSteam = try? values.decode(String.self, forKey: .srSteam)
        self.suAviationFuel = try? values.decode(String.self, forKey: .suAviationFuel)
        self.suDeck = try? values.decode(String.self, forKey: .suDeck)
        self.suDiesel = try? values.decode(String.self, forKey: .suDiesel)
        self.suEngine = try? values.decode(String.self, forKey: .suEngine)
        self.suFuel = try? values.decode(String.self, forKey: .suFuel)
        self.suProvisions = try? values.decode(String.self, forKey: .suProvisions)
        self.suWater = try? values.decode(String.self, forKey: .suWater)
        self.tide  = try? values.decode(Int.self, forKey: .tide)
        self.trafficSeparationScheme = try? values.decode(String.self, forKey: .trafficSeparationScheme)
        self.tugsAssist = try? values.decode(String.self, forKey: .tugsAssist)
        self.tugsSalvage = try? values.decode(String.self, forKey: .tugsSalvage)
        self.turningArea = try? values.decode(String.self, forKey: .turningArea)
        self.ukcMgmtSystem = try? values.decode(String.self, forKey: .ukcMgmtSystem)
        self.unloCode = try? values.decode(String.self, forKey: .unloCode)
        self.usRep = try? values.decode(String.self, forKey: .usRep)
        self.vesselTrafficService = try? values.decode(String.self, forKey: .vesselTrafficService)
    }
    
    // The keys must have the same name as the attributes of the Port entity.
    var dictionaryValue: [String: Any?] {
        [
            "alternateName": alternateName,
            "anchorageDepth": anchorageDepth,
            "cargoPierDepth": cargoPierDepth,
            "channelDepth": channelDepth,
            "chartNumber": chartNumber,
            "chemicalHoldingTank": chemicalHoldingTank,
            "cmAir": cmAir,
            "cmRadio": cmRadio,
            "cmRadioTel": cmRadioTel,
            "cmRail": cmRail,
            "cmTelephone": cmTelephone,
            "cmTelegraph": cmTelegraph,
            "countryCode": countryCode,
            "countryName": countryName,
            "craneContainer": craneContainer,
            "craneFixed": craneFixed,
            "craneFloating": craneFloating,
            "craneMobile": craneMobile,
            "degauss": degauss,
            "dirtyBallast": dirtyBallast,
            "dnc": dnc,
            "dodWaterBody": dodWaterBody,
            "drydock": drydock,
            "entranceWidth": entranceWidth,
            "erIce": erIce,
            "erOther": erOther,
            "erSwell": erSwell,
            "erTide": erTide,
            "etaMessage": etaMessage,
            "firstPortOfEntry": firstPortOfEntry,
            "garbageDisposal": garbageDisposal,
            "harborSize": harborSize,
            "harborType": harborType,
            "harborUse": harborUse,
            "latitude": latitude,
            "latitudeDms": latitudeDms,
            "lifts0": lifts0,
            "lifts25": lifts25,
            "lifts50": lifts50,
            "lifts100": lifts100,
            "liquifiedNaturalGasTerminalDepth": liquifiedNaturalGasTerminalDepth,
            "loAnchor": loAnchor,
            "loBeachMoor": loBeachMoor,
            "loBreakBulk": loBreakBulk,
            "loContainer": loContainer,
            "loDangCargo": loDangCargo,
            "loIceMoor": loIceMoor,
            "loLiquidBulk": loLiquidBulk,
            "loLongTerm": loLongTerm,
            "loMedMoor": loMedMoor,
            "longitude": longitude,
            "longitudeDms": longitudeDms,
            "loOilTerm": loOilTerm,
            "loOther": loOther,
            "loRoro": loRoro,
            "loSolidBulk": loSolidBulk,
            "loWharves": loWharves,
            "maxVesselBeam": maxVesselBeam,
            "maxVesselDraft": maxVesselDraft,
            "maxVesselLength": maxVesselLength,
            "medFacilities": medFacilities,
            "navArea": navArea,
            "offshoreMaxVesselBeam": offshoreMaxVesselBeam,
            "offshoreMaxVesselDraft": offshoreMaxVesselDraft,
            "offshoreMaxVesselLength": offshoreMaxVesselLength,
            "oilTerminalDepth": oilTerminalDepth,
            "overheadLimits": overheadLimits,
            "portName": portName,
            "portNumber": portNumber,
            "portSecurity": portSecurity,
            "ptAdvisable": ptAdvisable,
            "ptAvailable": ptAvailable,
            "ptCompulsory": ptCompulsory,
            "ptLocalAssist": ptLocalAssist,
            "publicationNumber": publicationNumber,
            "qtOther": qtOther,
            "qtPratique": qtPratique,
            "qtSanitation": qtSanitation,
            "railway": railway,
            "regionName": regionName,
            "regionNumber":regionNumber,
            "repairCode": repairCode,
            "s57Enc": s57Enc,
            "s101Enc": s101Enc,
            "searchAndRescue": searchAndRescue,
            "shelter": shelter,
            "srDiving": srDiving,
            "srElectricalRepair": srElectricalRepair,
            "srElectrical": srElectrical,
            "srIceBreaking": srIceBreaking,
            "srLongshore": srLongshore,
            "srNavigationalEquipment": srNavigationalEquipment,
            "srSteam": srSteam,
            "suAviationFuel": suAviationFuel,
            "suDeck": suDeck,
            "suDiesel": suDiesel,
            "suEngine": suEngine,
            "suFuel": suFuel,
            "suProvisions": suProvisions,
            "suWater": suWater,
            "tide": tide,
            "trafficSeparationScheme": trafficSeparationScheme,
            "tugsAssist": tugsAssist,
            "tugsSalvage": tugsSalvage,
            "turningArea": turningArea,
            "ukcMgmtSystem": ukcMgmtSystem,
            "unloCode": unloCode,
            "usRep": usRep,
            "vesselTrafficService": vesselTrafficService
        ]
    }
}
