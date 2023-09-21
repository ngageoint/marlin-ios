//
//  PortModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/23.
//

import Foundation
import CoreLocation
import GeoJSON
import UIKit

class PortModel: NSObject, Locatable, Bookmarkable, DataSource {
    var key: String { Self.key }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var canBookmark: Bool = false
    
    var port: Port?
    var portProperties: PortProperties?
    
    var alternateName: String?
    var anchorageDepth: Int64
    var cargoPierDepth: Int64
    var channelDepth: Int64
    var chartNumber: String?
    var chemicalHoldingTank: String?
    var cmAir: String?
    var cmRadio: String?
    var cmRadioTel: String?
    var cmRail: String?
    var cmTelegraph: String?
    var cmTelephone: String?
    var countryCode: String?
    var countryName: String?
    var craneContainer: String?
    var craneFixed: String?
    var craneFloating: String?
    var craneMobile: String?
    var degauss: String?
    var dirtyBallast: String?
    var dnc: String?
    var dodWaterBody: String?
    var drydock: String?
    var entranceWidth: Int64
    var erIce: String?
    var erOther: String?
    var erSwell: String?
    var erTide: String?
    var etaMessage: String?
    var firstPortOfEntry: String?
    var garbageDisposal: String?
    var goodHoldingGround: String?
    var harborSize: String?
    var harborType: String?
    var harborUse: String?
    var latitude: Double
    var latitudeDms: String?
    var lifts0: String?
    var lifts25: String?
    var lifts50: String?
    var lifts100: String?
    var liquifiedNaturalGasTerminalDepth: Int64
    var loAnchor: String?
    var loBeachMoor: String?
    var loBreakBulk: String?
    var loContainer: String?
    var loDangCargo: String?
    var loIceMoor: String?
    var loLiquidBulk: String?
    var loLongTerm: String?
    var loMedMoor: String?
    var longitude: Double
    var longitudeDms: String?
    var loOilTerm: String?
    var loOther: String?
    var loRoro: String?
    var loSolidBulk: String?
    var loWharves: String?
    var maxVesselBeam: Int64
    var maxVesselDraft: Int64
    var maxVesselLength: Int64
    var medFacilities: String?
    var mgrs10km: String?
    var navArea: String?
    var offshoreMaxVesselBeam: Int64
    var offshoreMaxVesselDraft: Int64
    var offshoreMaxVesselLength: Int64
    var oilTerminalDepth: Int64
    var overheadLimits: String?
    var portName: String?
    var portNumber: Int64
    var portSecurity: String?
    var ptAdvisable: String?
    var ptAvailable: String?
    var ptCompulsory: String?
    var ptLocalAssist: String?
    var publicationNumber: String?
    var qtOther: String?
    var qtPratique: String?
    var qtSanitation: String?
    var railway: String?
    var regionName: String?
    var regionNumber: Int64
    var repairCode: String?
    var s57Enc: String?
    var s101Enc: String?
    var searchAndRescue: String?
    var shelter: String?
    var srDiving: String?
    var srElectrical: String?
    var srElectricalRepair: String?
    var srIceBreaking: String?
    var srLongshore: String?
    var srNavigationalEquipment: String?
    var srSteam: String?
    var suAviationFuel: String?
    var suDeck: String?
    var suDiesel: String?
    var suEngine: String?
    var suFuel: String?
    var suProvisions: String?
    var suWater: String?
    var tide: Int64
    var trafficSeparationScheme: String?
    var tugsAssist: String?
    var tugsSalvage: String?
    var turningArea: String?
    var ukcMgmtSystem: String?
    var unloCode: String?
    var usRep: String?
    var vesselTrafficService: String?
    
    func isEqualTo(_ other: PortModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self.port == otherShape.port
    }
    
    static func == (lhs: PortModel, rhs: PortModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    func distanceTo(_ location: CLLocation) -> Double {
        location.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    init(port: Port) {
        self.port = port
        self.canBookmark = true
        self.alternateName = port.alternateName
        self.anchorageDepth = port.anchorageDepth
        self.cargoPierDepth = port.cargoPierDepth
        self.channelDepth = port.channelDepth
        self.chartNumber = port.chartNumber
        self.chemicalHoldingTank = port.chemicalHoldingTank
        self.cmAir = port.cmAir
        self.cmRadio = port.cmRadio
        self.cmRadioTel = port.cmRadioTel
        self.cmRail = port.cmRail
        self.cmTelegraph = port.cmTelegraph
        self.cmTelephone = port.cmTelephone
        self.countryCode = port.countryCode
        self.countryName = port.countryName
        self.craneContainer = port.craneContainer
        self.craneFixed = port.craneFixed
        self.craneFloating = port.craneFloating
        self.craneMobile = port.craneMobile
        self.degauss = port.degauss
        self.dirtyBallast = port.dirtyBallast
        self.dnc = port.dnc
        self.dodWaterBody = port.dodWaterBody
        self.drydock = port.drydock
        self.entranceWidth = port.entranceWidth
        self.erIce = port.erIce
        self.erOther = port.erOther
        self.erSwell = port.erSwell
        self.erTide = port.erTide
        self.etaMessage = port.etaMessage
        self.firstPortOfEntry = port.firstPortOfEntry
        self.garbageDisposal = port.garbageDisposal
        self.goodHoldingGround = port.goodHoldingGround
        self.harborSize = port.harborSize
        self.harborType = port.harborType
        self.harborUse = port.harborUse
        self.latitude = port.latitude
        self.latitudeDms = port.latitudeDms
        self.lifts0 = port.lifts0
        self.lifts25 = port.lifts25
        self.lifts50 = port.lifts50
        self.lifts100 = port.lifts100
        self.liquifiedNaturalGasTerminalDepth = port.liquifiedNaturalGasTerminalDepth
        self.loAnchor = port.loAnchor
        self.loBeachMoor = port.loBeachMoor
        self.loBreakBulk = port.loBreakBulk
        self.loContainer = port.loContainer
        self.loDangCargo = port.loDangCargo
        self.loIceMoor = port.loIceMoor
        self.loLiquidBulk = port.loLiquidBulk
        self.loLongTerm = port.loLongTerm
        self.loMedMoor = port.loMedMoor
        self.longitude = port.longitude
        self.longitudeDms = port.longitudeDms
        self.loOilTerm = port.loOilTerm
        self.loOther = port.loOther
        self.loRoro = port.loRoro
        self.loSolidBulk = port.loSolidBulk
        self.loWharves = port.loWharves
        self.maxVesselBeam = port.maxVesselBeam
        self.maxVesselDraft = port.maxVesselDraft
        self.maxVesselLength = port.maxVesselLength
        self.medFacilities = port.medFacilities
        self.mgrs10km = port.mgrs10km
        self.navArea = port.navArea
        self.offshoreMaxVesselBeam = port.offshoreMaxVesselBeam
        self.offshoreMaxVesselDraft = port.offshoreMaxVesselDraft
        self.offshoreMaxVesselLength = port.offshoreMaxVesselLength
        self.oilTerminalDepth = port.oilTerminalDepth
        self.overheadLimits = port.overheadLimits
        self.portName = port.portName
        self.portNumber = port.portNumber
        self.portSecurity = port.portSecurity
        self.ptAdvisable = port.ptAdvisable
        self.ptAvailable = port.ptAvailable
        self.ptCompulsory = port.ptCompulsory
        self.ptLocalAssist = port.ptLocalAssist
        self.publicationNumber = port.publicationNumber
        self.qtOther = port.qtOther
        self.qtPratique = port.qtPratique
        self.qtSanitation = port.qtSanitation
        self.railway = port.railway
        self.regionName = port.regionName
        self.regionNumber = port.regionNumber
        self.repairCode = port.repairCode
        self.s57Enc = port.s57Enc
        self.s101Enc = port.s101Enc
        self.searchAndRescue = port.searchAndRescue
        self.shelter = port.shelter
        self.srDiving = port.srDiving
        self.srElectrical = port.srElectrical
        self.srElectricalRepair = port.srElectricalRepair
        self.srIceBreaking = port.srIceBreaking
        self.srLongshore = port.srLongshore
        self.srNavigationalEquipment = port.srNavigationalEquipment
        self.srSteam = port.srSteam
        self.suAviationFuel = port.suAviationFuel
        self.suDeck = port.suDeck
        self.suDiesel = port.suDiesel
        self.suEngine = port.suEngine
        self.suFuel = port.suFuel
        self.suProvisions = port.suProvisions
        self.suWater = port.suWater
        self.tide = port.tide
        self.trafficSeparationScheme = port.trafficSeparationScheme
        self.tugsAssist = port.tugsAssist
        self.tugsSalvage = port.tugsSalvage
        self.turningArea = port.turningArea
        self.ukcMgmtSystem = port.ukcMgmtSystem
        self.unloCode = port.unloCode
        self.usRep = port.usRep
        self.vesselTrafficService = port.vesselTrafficService
    }
    
    init(port: PortProperties) {
        self.portProperties = port
        self.canBookmark = true
        self.alternateName = port.alternateName
        self.anchorageDepth = Int64(port.anchorageDepth ?? 0)
        self.cargoPierDepth = Int64(port.cargoPierDepth ?? 0)
        self.chartNumber = port.chartNumber
        self.channelDepth = Int64(port.channelDepth ?? 0)
        self.chemicalHoldingTank = port.chemicalHoldingTank
        self.cmAir = port.cmAir
        self.cmRadio = port.cmRadio
        self.cmRadioTel = port.cmRadioTel
        self.cmRail = port.cmRail
        self.cmTelegraph = port.cmTelegraph
        self.cmTelephone = port.cmTelephone
        self.countryCode = port.countryCode
        self.countryName = port.countryName
        self.craneContainer = port.craneContainer
        self.craneFixed = port.craneFixed
        self.craneFloating = port.craneFloating
        self.craneMobile = port.craneMobile
        self.degauss = port.degauss
        self.dirtyBallast = port.dirtyBallast
        self.dnc = port.dnc
        self.dodWaterBody = port.dodWaterBody
        self.drydock = port.drydock
        self.entranceWidth = Int64(port.entranceWidth ?? 0)
        self.erIce = port.erIce
        self.erOther = port.erOther
        self.erSwell = port.erSwell
        self.erTide = port.erTide
        self.etaMessage = port.etaMessage
        self.firstPortOfEntry = port.firstPortOfEntry
        self.garbageDisposal = port.garbageDisposal
        self.goodHoldingGround = port.goodHoldingGround
        self.harborSize = port.harborSize
        self.harborType = port.harborType
        self.harborUse = port.harborUse
        self.latitude = port.latitude
        self.latitudeDms = port.latitudeDms
        self.lifts0 = port.lifts0
        self.lifts25 = port.lifts25
        self.lifts50 = port.lifts50
        self.lifts100 = port.lifts100
        self.liquifiedNaturalGasTerminalDepth = Int64(port.liquifiedNaturalGasTerminalDepth ?? 0)
        self.loAnchor = port.loAnchor
        self.loBeachMoor = port.loBeachMoor
        self.loBreakBulk = port.loBreakBulk
        self.loContainer = port.loContainer
        self.loDangCargo = port.loDangCargo
        self.loIceMoor = port.loIceMoor
        self.loLiquidBulk = port.loLiquidBulk
        self.loLongTerm = port.loLongTerm
        self.loMedMoor = port.loMedMoor
        self.longitude = port.longitude
        self.longitudeDms = port.longitudeDms
        self.loOilTerm = port.loOilTerm
        self.loOther = port.loOther
        self.loRoro = port.loRoro
        self.loSolidBulk = port.loSolidBulk
        self.loWharves = port.loWharves
        self.maxVesselBeam = Int64(port.maxVesselBeam ?? 0)
        self.maxVesselDraft = Int64(port.maxVesselDraft ?? 0)
        self.maxVesselLength = Int64(port.maxVesselLength ?? 0)
        self.medFacilities = port.medFacilities
        self.mgrs10km = port.mgrs10km
        self.navArea = port.navArea
        self.offshoreMaxVesselBeam = Int64(port.offshoreMaxVesselBeam ?? 0)
        self.offshoreMaxVesselDraft = Int64(port.offshoreMaxVesselDraft ?? 0)
        self.offshoreMaxVesselLength = Int64(port.offshoreMaxVesselLength ?? 0)
        self.oilTerminalDepth = Int64(port.oilTerminalDepth ?? 0)
        self.overheadLimits = port.overheadLimits
        self.portName = port.portName
        self.portNumber = Int64(port.portNumber)
        self.portSecurity = port.portSecurity
        self.ptAdvisable = port.ptAdvisable
        self.ptAvailable = port.ptAvailable
        self.ptCompulsory = port.ptCompulsory
        self.ptLocalAssist = port.ptLocalAssist
        self.publicationNumber = port.publicationNumber
        self.qtOther = port.qtOther
        self.qtPratique = port.qtPratique
        self.qtSanitation = port.qtSanitation
        self.railway = port.railway
        self.regionName = port.regionName
        self.regionNumber = Int64(port.regionNumber ?? 0)
        self.repairCode = port.repairCode
        self.s57Enc = port.s57Enc
        self.s101Enc = port.s101Enc
        self.searchAndRescue = port.searchAndRescue
        self.shelter = port.shelter
        self.srDiving = port.srDiving
        self.srElectrical = port.srElectrical
        self.srElectricalRepair = port.srElectricalRepair
        self.srIceBreaking = port.srIceBreaking
        self.srLongshore = port.srLongshore
        self.srNavigationalEquipment = port.srNavigationalEquipment
        self.srSteam = port.srSteam
        self.suAviationFuel = port.suAviationFuel
        self.suDeck = port.suDeck
        self.suDiesel = port.suDiesel
        self.suEngine = port.suEngine
        self.suFuel = port.suFuel
        self.suProvisions = port.suProvisions
        self.suWater = port.suWater
        self.tide = Int64(port.tide ?? 0)
        self.trafficSeparationScheme = port.trafficSeparationScheme
        self.tugsAssist = port.tugsAssist
        self.tugsSalvage = port.tugsSalvage
        self.turningArea = port.turningArea
        self.ukcMgmtSystem = port.ukcMgmtSystem
        self.unloCode = port.unloCode
        self.usRep = port.usRep
        self.vesselTrafficService = port.vesselTrafficService
    }
    
    convenience init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(PortProperties.self, from: jsonData) {
                self.init(port: ds)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    var itemTitle: String {
        return "\(self.portName ?? "")"
    }
    
    var itemKey: String {
        return "\(portNumber)"
    }
    
    var color: UIColor {
        return Port.color
    }
    
    static func postProcess() {}
    
    static var isMappable: Bool = true
    static var dataSourceName: String = NSLocalizedString("Ports", comment: "Port data source display name")
    static var fullDataSourceName: String = NSLocalizedString("World Ports", comment: "Port data source display name")
    static var key: String = "port"
    static var metricsKey: String = "ports"
    static var imageName: String? = "port"
    static var systemImageName: String? = nil
    static var color: UIColor = UIColor(argbValue: 0xFF5856d6)
    static var imageScale = UserDefaults.standard.imageScale(key) ?? 1.0
    
    static var defaultSort: [DataSourceSortParameter] = [DataSourceSortParameter(property:DataSourceProperty(name: "World Port Index Number", key: #keyPath(Port.portNumber), type: .int), ascending: false)]
    static var defaultFilter: [DataSourceFilterParameter] = []
    
    static var properties: [DataSourceProperty] = [
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
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter
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
            KeyValue(key: "Dry Dock", value: "\(DecisionEnum.fromValue(drydock))"),
            KeyValue(key: "Railway", value: "\(SizeEnum.fromValue(railway))"),
        ]
    }
}

extension PortModel: MapImage {
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
}
