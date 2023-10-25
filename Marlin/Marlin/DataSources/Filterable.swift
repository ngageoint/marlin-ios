//
//  Filterable.swift
//  Marlin
//
//  Created by Daniel Barela on 10/12/23.
//

import Foundation
import CoreData

protocol Filterable {
    var id: String { get }
    var definition: any DataSourceDefinition { get }
    var properties: [DataSourceProperty] { get }
    var defaultFilter: [DataSourceFilterParameter] { get }
    var locatableClass: Locatable.Type? { get }
    func fetchRequest(filters: [DataSourceFilterParameter]?, commonFilters: [DataSourceFilterParameter]?) -> NSFetchRequest<NSFetchRequestResult>?
}

extension Filterable {
    var id: String {
        definition.key
    }
    var locatableClass: Locatable.Type? {
        nil
    }
    
    func fetchRequest(filters: [DataSourceFilterParameter]?, commonFilters: [DataSourceFilterParameter]?) -> NSFetchRequest<NSFetchRequestResult>? {
        // TODO: this should take a repostory
        var dataSourceNSManaged: NSManagedObject.Type? = self as? NSManagedObject.Type ?? DataSourceType.fromKey(definition.key)?.toDataSource() as? NSManagedObject.Type
        
        guard let dataSourceNSManaged = dataSourceNSManaged else {
            return nil
        }
        let fetchRequest = dataSourceNSManaged.fetchRequest()
        var predicates: [NSPredicate] = []
        
        if let commonFilters = commonFilters {
            for filter in commonFilters {
                if let predicate = filter.toPredicate(dataSource: self) {
                    predicates.append(predicate)
                }
            }
        }
        
        if let filters = filters {
            for filter in filters {
                if let predicate = filter.toPredicate(dataSource: self) {
                    predicates.append(predicate)
                }
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        fetchRequest.predicate = predicate
        return fetchRequest
    }
}

struct ChartCorrectionFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.chartCorrection.definition
    }
    
    var properties: [DataSourceProperty] {
        [
            DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int, requiredInFilter: false),
            DataSourceProperty(name: "Location", key: "location", type: .location, requiredInFilter: true)
        ]
    }
    
    var defaultFilter: [DataSourceFilterParameter] {
        if LocationManager.shared().lastLocation != nil {
            return [
                DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .nearMe, valueInt: 2500)
            ]
        } else {
            return [
                DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .closeTo, valueInt: 2500, valueLatitude: 0.0, valueLongitude: 0.0)
            ]
        }
    }
}

struct AsamFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.asam.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date),
        DataSourceProperty(name: "Location", key: #keyPath(Asam.mgrs10km), type: .location),
        DataSourceProperty(name: "Reference", key: #keyPath(Asam.reference), type: .string),
        DataSourceProperty(name: "Latitude", key: #keyPath(Asam.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Asam.longitude), type: .longitude),
        DataSourceProperty(name: "Navigation Area", key: #keyPath(Asam.navArea), type: .string),
        DataSourceProperty(name: "Subregion", key: #keyPath(Asam.subreg), type: .string),
        DataSourceProperty(name: "Description", key: #keyPath(Asam.asamDescription), type: .string),
        DataSourceProperty(name: "Hostility", key: #keyPath(Asam.hostility), type: .string),
        DataSourceProperty(name: "Victim", key: #keyPath(Asam.victim), type: .string)
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = [DataSourceFilterParameter(property: DataSourceProperty(name: "Date", key: #keyPath(Asam.date), type: .date), comparison: .window, windowUnits: DataSourceWindowUnits.last365Days)]
    
    var locatableClass: Locatable.Type? = Asam.self
}

struct ModuFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.modu.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Modu.mgrs10km), type: .location),
        DataSourceProperty(name: "Subregion", key: #keyPath(Modu.subregion), type: .int),
        DataSourceProperty(name: "Region", key: #keyPath(Modu.region), type: .int),
        DataSourceProperty(name: "Longitude", key: #keyPath(Modu.longitude), type: .longitude),
        DataSourceProperty(name: "Latitude", key: #keyPath(Modu.latitude), type: .latitude),
        DataSourceProperty(name: "Distance", key: #keyPath(Modu.distance), type: .double),
        DataSourceProperty(name: "Special Status", key: #keyPath(Modu.specialStatus), type: .string),
        DataSourceProperty(name: "Rig Status", key: #keyPath(Modu.rigStatus), type: .string),
        DataSourceProperty(name: "Nav Area", key: #keyPath(Modu.navArea), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Modu.name), type: .string),
        DataSourceProperty(name: "Date", key: #keyPath(Modu.date), type: .date),
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var locatableClass: Locatable.Type? = Modu.self
}

struct DifferentialGPSStationFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.dgps.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(DifferentialGPSStation.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(DifferentialGPSStation.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(DifferentialGPSStation.longitude), type: .longitude),
        DataSourceProperty(name: "Number", key: #keyPath(DifferentialGPSStation.featureNumber), type: .int),
        DataSourceProperty(name: "Name", key: #keyPath(DifferentialGPSStation.name), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(DifferentialGPSStation.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Station ID", key: #keyPath(DifferentialGPSStation.stationID), type: .int),
        DataSourceProperty(name: "Range (nmi)", key: #keyPath(DifferentialGPSStation.range), type: .int),
        DataSourceProperty(name: "Frequency (kHz)", key: #keyPath(DifferentialGPSStation.frequency), type: .int),
        DataSourceProperty(name: "Transfer Rate", key: #keyPath(DifferentialGPSStation.transferRate), type: .int),
        DataSourceProperty(name: "Remarks", key: #keyPath(DifferentialGPSStation.remarks), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(DifferentialGPSStation.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(DifferentialGPSStation.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(DifferentialGPSStation.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(DifferentialGPSStation.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(DifferentialGPSStation.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(DifferentialGPSStation.postNote), type: .string),
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var locatableClass: Locatable.Type? = DifferentialGPSStation.self
}

struct PortFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.port.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Port.mgrs10km), type: .location),
        // Name and Location
        DataSourceProperty(name: "Latitude", key: #keyPath(Port.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Port.longitude), type: .longitude),
        DataSourceProperty(name: "World Port Index Number", key: #keyPath(Port.portNumber), type: .int),
        DataSourceProperty(name: "Region Name", key: #keyPath(Port.regionName), type: .string),
        DataSourceProperty(name: "Region Number", key: #keyPath(Port.regionNumber), type: .int),
        DataSourceProperty(name: "Main Port Name", key: #keyPath(Port.portName), type: .string),
        DataSourceProperty(name: "Alternate Port Name", key: #keyPath(Port.alternateName), type: .string),
        DataSourceProperty(name: "UN/LOCODE", key: #keyPath(Port.unloCode), type: .string),
        DataSourceProperty(name: "Country", key: #keyPath(Port.countryName), type: .string),
        DataSourceProperty(name: "World Water Body", key: #keyPath(Port.dodWaterBody), type: .string),
        DataSourceProperty(name: "Sailing Directions or Publication", key: #keyPath(Port.publicationNumber), type: .string),
        DataSourceProperty(name: "Standard Nautical Chart", key: #keyPath(Port.chartNumber), type: .string),
        DataSourceProperty(name: "IHO S-57 Electronic Navigational Chart", key: #keyPath(Port.s57Enc), type: .string),
        DataSourceProperty(name: "IHO S-101 Electronic Navigational Chart", key: #keyPath(Port.s101Enc), type: .string),
        DataSourceProperty(name: "Digital Nautical Chart", key: #keyPath(Port.dnc), type: .string),
        
        // Depth
        DataSourceProperty(name: "Tidal Range (m)", key: #keyPath(Port.tide), type: .int),
        DataSourceProperty(name: "Entrance Width (m)", key: #keyPath(Port.entranceWidth), type: .int),
        DataSourceProperty(name: "Channel Depth (m)", key: #keyPath(Port.channelDepth), type: .int),
        DataSourceProperty(name: "Anchorage Depth (m)", key: #keyPath(Port.anchorageDepth), type: .int),
        DataSourceProperty(name: "Cargo Pier Depth (m)", key: #keyPath(Port.cargoPierDepth), type: .int),
        DataSourceProperty(name: "Oil Terminal Depth (m)", key: #keyPath(Port.oilTerminalDepth), type: .int),
        DataSourceProperty(name: "Liquified Natural Gas Terminal Depth (m)", key: #keyPath(Port.liquifiedNaturalGasTerminalDepth), type: .int),
        
        // Maximum Vessel Size
        DataSourceProperty(name: "Maximum Vessel Length (m)", key: #keyPath(Port.maxVesselLength), type: .int),
        DataSourceProperty(name: "Maximum Vessel Beam (m)", key: #keyPath(Port.maxVesselBeam), type: .int),
        DataSourceProperty(name: "Maximum Vessel Draft (m)", key: #keyPath(Port.maxVesselDraft), type: .int),
        DataSourceProperty(name: "Offshore Maximum Vessel Length (m)", key: #keyPath(Port.offshoreMaxVesselLength), type: .int),
        DataSourceProperty(name: "Offshore Maximum Vessel Beam (m)", key: #keyPath(Port.offshoreMaxVesselBeam), type: .int),
        DataSourceProperty(name: "Offshore Maximum Vessel Draft (m)", key: #keyPath(Port.offshoreMaxVesselDraft), type: .int),
        
        
        // Physical Environment
        DataSourceProperty(name: "Harbor Size", key: #keyPath(Port.harborSize), type: .enumeration, enumerationValues: SizeEnum.keyValueMap),
        DataSourceProperty(name: "Harbor Type", key: #keyPath(Port.harborType), type: .enumeration, enumerationValues: HarborTypeEnum.keyValueMap),
        DataSourceProperty(name: "Harbor Use", key: #keyPath(Port.harborUse), type: .enumeration, enumerationValues: HarborUseEnum.keyValueMap),
        DataSourceProperty(name: "Shelter", key: #keyPath(Port.shelter), type: .enumeration, enumerationValues: ConditionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Tide", key: #keyPath(Port.erTide), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Heavy Swell", key: #keyPath(Port.erSwell), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Ice", key: #keyPath(Port.erIce), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Entrance Restriction - Other", key: #keyPath(Port.erOther), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Overhead Limits", key: #keyPath(Port.overheadLimits), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Underkeel Clearance Management System", key: #keyPath(Port.ukcMgmtSystem), type: .enumeration, enumerationValues: UnderkeelClearanceEnum.keyValueMap),
        DataSourceProperty(name: "Good Holding Ground", key: #keyPath(Port.goodHoldingGround), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Turning Area", key: #keyPath(Port.turningArea), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        
        // Approach
        DataSourceProperty(name: "Port Security", key: #keyPath(Port.portSecurity), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Estimated Time Of Arrival Message", key: #keyPath(Port.etaMessage), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Quarantine - Pratique", key: #keyPath(Port.qtPratique), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Quarantine - Sanitation", key: #keyPath(Port.qtSanitation), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Quarantine - Other", key: #keyPath(Port.qtOther), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Traffic Separation Scheme", key: #keyPath(Port.trafficSeparationScheme), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Vessel Traffic Service", key: #keyPath(Port.vesselTrafficService), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "First Port Of Entry", key: #keyPath(Port.firstPortOfEntry), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        
        // Pilots Tugs Communications
        DataSourceProperty(name: "Pilotage - Compulsory", key: #keyPath(Port.ptCompulsory), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Pilotage - Available", key: #keyPath(Port.ptAvailable), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Pilotage - Local Assistance", key: #keyPath(Port.ptLocalAssist), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Pilotage - Advisable", key: #keyPath(Port.ptAdvisable), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Tugs - Salvage", key: #keyPath(Port.tugsSalvage), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Tugs - Assistance", key: #keyPath(Port.tugsAssist), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Telephone", key: #keyPath(Port.cmTelephone), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Telefax", key: #keyPath(Port.cmTelegraph), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Radio", key: #keyPath(Port.cmRadio), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Radiotelephone", key: #keyPath(Port.cmRadioTel), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Airport", key: #keyPath(Port.cmAir), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Communications - Rail", key: #keyPath(Port.cmRail), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Search and Rescue", key: #keyPath(Port.searchAndRescue), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "NAVAREA", key: #keyPath(Port.navArea), type: .string),
        
        // Facilities
        DataSourceProperty(name: "Facilities - Wharves", key: #keyPath(Port.loWharves), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Anchorage", key: #keyPath(Port.loAnchor), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Dangerous Cargo Anchorage", key: #keyPath(Port.loDangCargo), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Med Mooring", key: #keyPath(Port.loMedMoor), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Beach Mooring", key: #keyPath(Port.loBeachMoor), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Ice Mooring", key: #keyPath(Port.loIceMoor), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - RoRo", key: #keyPath(Port.loRoro), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Solid Bulk", key: #keyPath(Port.loSolidBulk), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Liquid Bulk", key: #keyPath(Port.loLiquidBulk), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Container", key: #keyPath(Port.loContainer), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Breakbulk", key: #keyPath(Port.loBreakBulk), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Oil Terminal", key: #keyPath(Port.loOilTerm), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - LNG Terminal", key: #keyPath(Port.loLongTerm), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Facilities - Other", key: #keyPath(Port.loOther), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Medical Facilities", key: #keyPath(Port.medFacilities), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Garbage Disposal", key: #keyPath(Port.garbageDisposal), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Chemical Holding Tank Disposal", key: #keyPath(Port.chemicalHoldingTank), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Degaussing", key: #keyPath(Port.degauss), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Dirty Ballast Disposal", key: #keyPath(Port.dirtyBallast), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        
        // Cranes
        DataSourceProperty(name: "Cranes - Fixed", key: #keyPath(Port.craneFixed), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Cranes - Mobile", key: #keyPath(Port.craneMobile), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Cranes - Floating", key: #keyPath(Port.craneFloating), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Cranes - Container", key: #keyPath(Port.craneContainer), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 100+ Tons", key: #keyPath(Port.lifts100), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 50-100 Tons", key: #keyPath(Port.lifts50), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 25-49 Tons", key: #keyPath(Port.lifts25), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Lifts - 0-24 Tons", key: #keyPath(Port.lifts0), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        
        // Services Supplies
        DataSourceProperty(name: "Services - Longshoremen", key: #keyPath(Port.srLongshore), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Electricity", key: #keyPath(Port.srElectrical), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Steam", key: #keyPath(Port.srSteam), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Navigational Equipment", key: #keyPath(Port.srNavigationalEquipment), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Electrical Repair", key: #keyPath(Port.srElectricalRepair), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Ice Breaking", key: #keyPath(Port.srIceBreaking), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Services - Diving", key: #keyPath(Port.srDiving), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Provisions", key: #keyPath(Port.suProvisions), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Potable Water", key: #keyPath(Port.suWater), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Fuel Oil", key: #keyPath(Port.suFuel), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Diesel Oil", key: #keyPath(Port.suDiesel), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Aviation Fuel", key: #keyPath(Port.suAviationFuel), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Deck", key: #keyPath(Port.suDeck), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Supplies - Engine", key: #keyPath(Port.suEngine), type: .enumeration, enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(name: "Repair Code", key: #keyPath(Port.repairCode), type: .enumeration, enumerationValues: RepairCodeEnum.keyValueMap),
        DataSourceProperty(name: "Dry Dock", key: #keyPath(Port.drydock), type: .enumeration, enumerationValues: SizeEnum.keyValueMap),
        DataSourceProperty(name: "Railway", key: #keyPath(Port.railway), type: .enumeration, enumerationValues: SizeEnum.keyValueMap)
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var locatableClass: Locatable.Type? = Port.self
}

struct LightFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.light.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(Light.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(Light.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(Light.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(Light.featureNumber), type: .string),
        DataSourceProperty(name: "International Feature Number", key: #keyPath(Light.internationalFeature), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(Light.name), type: .string),
        DataSourceProperty(name: "Structure", key: #keyPath(Light.structure), type: .string),
        DataSourceProperty(name: "Focal Plane Elevation (ft)", key: #keyPath(Light.heightFeet), type: .double),
        DataSourceProperty(name: "Focal Plane Elevation (m)", key: #keyPath(Light.heightMeters), type: .double),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(Light.lightRange), type: .double, subEntityKey: #keyPath(LightRange.range)),
        DataSourceProperty(name: "Remarks", key: #keyPath(Light.remarks), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Signal", key: #keyPath(Light.characteristic), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(Light.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(Light.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(Light.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(Light.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(Light.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(Light.postNote), type: .string),
        DataSourceProperty(name: "Region", key: #keyPath(Light.sectionHeader), type: .string),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(Light.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(Light.regionHeading), type: .string),
        DataSourceProperty(name: "Subregion Heading", key: #keyPath(Light.subregionHeading), type: .string),
        DataSourceProperty(name: "Local Heading", key: #keyPath(Light.localHeading), type: .string)
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var locatableClass: Locatable.Type? = Light.self
    
}

struct RadioBeaconFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.radioBeacon.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(RadioBeacon.mgrs10km), type: .location),
        DataSourceProperty(name: "Latitude", key: #keyPath(RadioBeacon.latitude), type: .latitude),
        DataSourceProperty(name: "Longitude", key: #keyPath(RadioBeacon.longitude), type: .longitude),
        DataSourceProperty(name: "Feature Number", key: #keyPath(RadioBeacon.featureNumber), type: .int),
        DataSourceProperty(name: "Geopolitical Heading", key: #keyPath(RadioBeacon.geopoliticalHeading), type: .string),
        DataSourceProperty(name: "Name", key: #keyPath(RadioBeacon.name), type: .string),
        DataSourceProperty(name: "Range (nm)", key: #keyPath(RadioBeacon.range), type: .int),
        DataSourceProperty(name: "Frequency (kHz)", key: #keyPath(RadioBeacon.frequency), type: .string),
        DataSourceProperty(name: "Station Remark", key: #keyPath(RadioBeacon.stationRemark), type: .string),
        DataSourceProperty(name: "Characteristic", key: #keyPath(RadioBeacon.characteristic), type: .string),
        DataSourceProperty(name: "Sequence Text", key: #keyPath(RadioBeacon.sequenceText), type: .string),
        DataSourceProperty(name: "Notice Number", key: #keyPath(RadioBeacon.noticeNumber), type: .int),
        DataSourceProperty(name: "Notice Week", key: #keyPath(RadioBeacon.noticeWeek), type: .string),
        DataSourceProperty(name: "Notice Year", key: #keyPath(RadioBeacon.noticeYear), type: .string),
        DataSourceProperty(name: "Volume Number", key: #keyPath(RadioBeacon.volumeNumber), type: .string),
        DataSourceProperty(name: "Preceding Note", key: #keyPath(RadioBeacon.precedingNote), type: .string),
        DataSourceProperty(name: "Post Note", key: #keyPath(RadioBeacon.postNote), type: .string),
        DataSourceProperty(name: "Aid Type", key: #keyPath(RadioBeacon.aidType), type: .string),
        DataSourceProperty(name: "Region Heading", key: #keyPath(RadioBeacon.regionHeading), type: .string),
        DataSourceProperty(name: "Remove From List", key: #keyPath(RadioBeacon.removeFromList), type: .string),
        DataSourceProperty(name: "Delete Flag", key: #keyPath(RadioBeacon.deleteFlag), type: .string)
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var locatableClass: Locatable.Type? = RadioBeacon.self
}

struct CommonFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.common.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Location", key: #keyPath(CommonDataSource.coordinate), type: .location)
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
}

struct NoticeToMarinersFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.noticeToMariners.definition
    }
    
    var properties: [DataSourceProperty] {
        return []
    }
    
    var defaultFilter: [DataSourceFilterParameter] = []
    }

struct ElectronicPublicationFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.epub.definition
    }
    
    var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Type", key: #keyPath(ElectronicPublication.pubTypeId), type: .enumeration, enumerationValues: PublicationTypeEnum.keyValueMap),
        DataSourceProperty(name: "Display Name", key: #keyPath(ElectronicPublication.pubDownloadDisplayName), type: .string)
    ]
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
}

struct NavigationalWarningFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.navWarning.definition
    }
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var properties: [DataSourceProperty] = []
    
    var locatableClass: Locatable.Type? = NavigationalWarning.self
}

struct RouteFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.route.definition
    }
    
    var defaultFilter: [DataSourceFilterParameter] = []
    
    var properties: [DataSourceProperty] = []
    
}
