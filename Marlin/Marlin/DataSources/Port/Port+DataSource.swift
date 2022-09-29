//
//  Port+DataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import UIKit
import CoreData

extension Port: DataSource {
    var color: UIColor {
        return Port.color
    }
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Ports", comment: "Port data source display name")
    static var fullDataSourceName: String = NSLocalizedString("World Ports", comment: "Port data source display name")
    static var key: String = "port"
    static var imageName: String? = "port"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFF5856d6)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [NSSortDescriptor] = [NSSortDescriptor(keyPath: \Port.portNumber, ascending: false)]
    
    static var properties: [DataSourceProperty] = [
        // Name and Location
        DataSourceProperty(name: "Latitude", key: "latitude", type: .double),
        DataSourceProperty(name: "Longitude", key: "longitude", type: .double),
        DataSourceProperty(name: "World Port Index Number", key: "portNumber", type: .int),
        DataSourceProperty(name: "Region Name", key: "regionName", type: .string),
        DataSourceProperty(name: "Region Number", key: "regionNumber", type: .int),
        DataSourceProperty(name: "Main Port Name", key: "portName", type: .string),
        DataSourceProperty(name: "Alternate Port Name", key: "alternateName", type: .string),
        DataSourceProperty(name: "UN/LOCODE", key: "unloCode", type: .string),
        DataSourceProperty(name: "Country", key: "countryName", type: .string),
        DataSourceProperty(name: "World Water Body", key: "dodWaterBody", type: .string),
        DataSourceProperty(name: "Sailing Directions or Publication", key: "publicationNumber", type: .string),
        DataSourceProperty(name: "Standard Nautical Chart", key: "chartNumber", type: .string),
        DataSourceProperty(name: "IHO S-57 Electronic Navigational Chart", key: "s57Enc", type: .string),
        DataSourceProperty(name: "IHO S-101 Electronic Navigational Chart", key: "s101Enc", type: .string),
        DataSourceProperty(name: "Digital Nautical Chart", key: "dnc", type: .string),
        
        // Depth
        DataSourceProperty(name: "Tidal Range (m)", key: "tide", type: .int),
        DataSourceProperty(name: "Entrance Width (m)", key: "entranceWidth", type: .int),
        DataSourceProperty(name: "Channel Depth (m)", key: "channelDepth", type: .int),
        DataSourceProperty(name: "Anchorage Depth (m)", key: "anchorageDepth", type: .int),
        DataSourceProperty(name: "Cargo Pier Depth (m)", key: "cargoPierDepth", type: .int),
        DataSourceProperty(name: "Oil Terminal Depth (m)", key: "oilTerminalDepth", type: .int),
        DataSourceProperty(name: "Liquified Natural Gas Terminal Depth (m)", key: "liquifiedNaturalGasTerminalDepth", type: .int),

        // Maximum Vessel Size
        DataSourceProperty(name: "Maximum Vessel Length (m)", key: "maxVesselLength", type: .int),
        DataSourceProperty(name: "Maximum Vessel Beam (m)", key: "maxVesselBeam", type: .int),
        DataSourceProperty(name: "Maximum Vessel Draft (m)", key: "maxVesselDraft", type: .int),
        DataSourceProperty(name: "Offshore Maximum Vessel Length (m)", key: "offshoreMaxVesselLength", type: .int),
        DataSourceProperty(name: "Offshore Maximum Vessel Beam (m)", key: "offshoreMaxVesselBeam", type: .int),
        DataSourceProperty(name: "Offshore Maximum Vessel Draft (m)", key: "offshoreMaxVesselDraft", type: .int),

        
        // Physical Environment
        DataSourceProperty(name: "Harbor Size", key: "harborSize", type: .enumeration, enumerationValues: SizeEnum.keyValueMap),
        DataSourceProperty(name: "Harbor Type", key: "harborType", type: .enumeration, enumerationValues: HarborTypeEnum.keyValueMap),
        DataSourceProperty(name: "Harbor Use", key: "harborUse", type: .enumeration, enumerationValues: HarborUseEnum.keyValueMap),
        DataSourceProperty(name: "Shelter", key: "shelter", type: .enumeration, enumerationValues: ConditionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Tide", key: "erTide", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Heavy Swell", key: "erSwell", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Ice", key: "erIce", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Other", key: "erOther", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Overhead Limits", key: "overheadLimits", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Underkeel Clearance Management System", key: "ukcMgmtSystem", type: .enumeration, enumerationValues: UnderkeelClearanceEnum.keyValueMap),
        DataSourceProperty(name: "Good Holding Ground", key: "goodHoldingGround", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Turning Area", key: "turningArea", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),

        // Approach
        DataSourceProperty(name: "Port Security", key: "portSecurity", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Estimated Time Of Arrival Message", key: "etaMessage", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Quarantine - Pratique", key: "qtPratique", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Quarantine - Sanitation", key: "qtSanitation", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Quarantine - Other", key: "qtOther", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Traffic Separation Scheme", key: "trafficSeparationScheme", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Vessel Traffic Service", key: "vesselTrafficService", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "First Port Of Entry", key: "firstPortOfEntry", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),

        // Pilots Tugs Communications
        DataSourceProperty(name: "Pilotage - Compulsory", key: "ptCompulsory", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Pilotage - Available", key: "ptAvailable", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Pilotage - Local Assistance", key: "ptLocalAssist", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Pilotage - Advisable", key: "ptAdvisable", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Tugs - Salvage", key: "tugsSalvage", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Tugs - Assistance", key: "tugsAssist", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Telephone", key: "cmTelephone", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Telefax", key: "cmTelegraph", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Radio", key: "cmRadio", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Radiotelephone", key: "cmRadioTel", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Airport", key: "cmAir", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Rail", key: "cmRail", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Search and Rescue", key: "searchAndRescue", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "NAVAREA", key: "navArea", type: .string),

        // Facilities
        DataSourceProperty(name: "Facilities - Wharves", key: "loWharves", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Anchorage", key: "loAnchor", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Dangerous Cargo Anchorage", key: "loDangCargo", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Med Mooring", key: "loMedMoor", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Beach Mooring", key: "loBeachMoor", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Ice Mooring", key: "loIceMoor", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - RoRo", key: "loRoro", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Solid Bulk", key: "loSolidBulk", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Liquid Bulk", key: "loLiquidBulk", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Container", key: "loContainer", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Breakbulk", key: "loBreakBulk", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Oil Terminal", key: "loOilTerm", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - LNG Terminal", key: "loLongTerm", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Other", key: "loOther", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Medical Facilities", key: "medFacilities", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Garbage Disposal", key: "garbageDisposal", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Chemical Holding Tank Disposal", key: "chemicalHoldingTank", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Degaussing", key: "degauss", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Dirty Ballast Disposal", key: "dirtyBallast", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),

        // Cranes
        DataSourceProperty(name: "Cranes - Fixed", key: "craneFixed", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Cranes - Mobile", key: "craneMobile", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Cranes - Floating", key: "craneFloating", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Cranes - Container", key: "craneContainer", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 100+ Tons", key: "lifts100", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 50-100 Tons", key: "lifts50", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 25-49 Tons", key: "lifts25", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 0-24 Tons", key: "lifts0", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),

        // Services Supplies
        DataSourceProperty(name: "Services - Longshoremen", key: "srLongshore", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Electricity", key: "srElectrical", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Steam", key: "srSteam", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Navigational Equipment", key: "srNavigationalEquipment", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Electrical Repair", key: "srElectricalRepair", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Ice Breaking", key: "srIceBreaking", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Diving", key: "srDiving", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Provisions", key: "suProvisions", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Potable Water", key: "suWater", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Fuel Oil", key: "suFuel", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Diesel Oil", key: "suDiesel", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Aviation Fuel", key: "suAviationFuel", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Deck", key: "suDeck", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Engine", key: "suEngine", type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Repair Code", key: "repairCode", type: .enumeration, enumerationValues: RepairCodeEnum.keyValueMap),
        DataSourceProperty(name: "Dry Dock", key: "drydock", type: .enumeration, enumerationValues: SizeEnum.keyValueMap),
        DataSourceProperty(name: "Railway", key: "railway", type: .enumeration, enumerationValues: SizeEnum.keyValueMap)
    ]
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
    }
}

extension Port: BatchImportable {
    static var seedDataFiles: [String]? = ["port"]
    static var decodableRoot: Decodable.Type = PortPropertyContainer.self
    
    static func batchImport(value: Decodable?) async throws -> Int {
        guard let value = value as? PortPropertyContainer else {
            return 0
        }
        let count = value.ports.count
        NSLog("Received \(count) \(Self.key) records.")
        return try await Port.importRecords(from: value.ports, taskContext: PersistenceController.shared.newTaskContext())
    }
    
    static func dataRequest() -> [MSIRouter] {
        return [MSIRouter.readPorts]
    }
    
    static func shouldSync() -> Bool {
        // sync once every week
        return UserDefaults.standard.dataSourceEnabled(Port.self) && (Date().timeIntervalSince1970 - (60 * 60 * 24 * 7)) > UserDefaults.standard.lastSyncTimeSeconds(Port.self)
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
    
    static func importRecords(from propertiesList: [PortProperties], taskContext: NSManagedObjectContext) async throws -> Int {
        guard !propertiesList.isEmpty else { return 0 }
        
        // Add name and author to identify source of persistent history changes.
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importPorts"
        
        return try await taskContext.perform {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = Port.newBatchInsertRequest(with: propertiesList)
            batchInsertRequest.resultType = .count
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult {
                if let count = batchInsertResult.result as? Int, count > 0 {
                    NSLog("Inserted \(count) Port records")
                    return count
                } else {
                    NSLog("No new Port records")
                }
                return 0
            }
            throw MSIError.batchInsertError
        }
    }
}
