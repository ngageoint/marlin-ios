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
import mgrs_ios
import OSLog

struct PortModel: Locatable, Bookmarkable, DataSource, Codable {
    var key: String { Self.key }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    var canBookmark: Bool = false
    
    var port: Port?
    
    var alternateName: String?
    var anchorageDepth: Int?
    var cargoPierDepth: Int?
    var channelDepth: Int?
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
    var entranceWidth: Int?
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
    var liquifiedNaturalGasTerminalDepth: Int?
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
    var maxVesselBeam: Int?
    var maxVesselDraft: Int?
    var maxVesselLength: Int?
    var medFacilities: String?
    var mgrs10km: String?
    var navArea: String?
    var offshoreMaxVesselBeam: Int?
    var offshoreMaxVesselDraft: Int?
    var offshoreMaxVesselLength: Int?
    var oilTerminalDepth: Int?
    var overheadLimits: String?
    var portName: String?
    var portNumber: Int
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
    var regionNumber: Int?
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
    var tide: Int?
    var trafficSeparationScheme: String?
    var tugsAssist: String?
    var tugsSalvage: String?
    var turningArea: String?
    var ukcMgmtSystem: String?
    var unloCode: String?
    var usRep: String?
    var vesselTrafficService: String?
    
    func isEqualTo(_ other: PortModel) -> Bool {
        return self.port == other.port
    }
    
    static func == (lhs: PortModel, rhs: PortModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    func distanceTo(_ location: CLLocation) -> Double {
        location.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try? container.encode(portNumber, forKey: .portNumber)
        try? container.encode(latitude, forKey: .latitude)
        try? container.encode(longitude, forKey: .longitude)
        try? container.encode(alternateName, forKey: .alternateName)
        if let anchorageDepth = anchorageDepth {
            try? container.encode("\(anchorageDepth)", forKey: .anchorageDepth)
        }
        if let cargoPierDepth = cargoPierDepth {
            try? container.encode("\(cargoPierDepth)", forKey: .cargoPierDepth)
        }
        if let channelDepth = channelDepth {
            try? container.encode("\(channelDepth)", forKey: .channelDepth)
        }
        try? container.encode(chartNumber, forKey: .chartNumber)
        try? container.encode(chemicalHoldingTank, forKey: .chemicalHoldingTank)
        try? container.encode(cmAir, forKey: .cmAir)
        try? container.encode(cmRadio, forKey: .cmRadio)
        try? container.encode(cmRadioTel, forKey: .cmRadioTel)
        try? container.encode(cmRail, forKey: .cmRail)
        try? container.encode(cmTelephone, forKey: .cmTelephone)
        try? container.encode(cmTelegraph, forKey: .cmTelegraph)
        try? container.encode(countryCode, forKey: .countryCode)
        try? container.encode(countryName, forKey: .countryName)
        try? container.encode(craneContainer, forKey: .craneContainer)
        try? container.encode(craneFixed, forKey: .craneFixed)
        try? container.encode(craneFloating, forKey: .craneFloating)
        try? container.encode(craneMobile, forKey: .craneMobile)
        try? container.encode(degauss, forKey: .degauss)
        try? container.encode(dirtyBallast, forKey: .dirtyBallast)
        try? container.encode(dnc, forKey: .dnc)
        try? container.encode(dodWaterBody, forKey: .dodWaterBody)
        try? container.encode(drydock, forKey: .drydock)
        try? container.encode(entranceWidth, forKey: .entranceWidth)
        try? container.encode(erIce, forKey: .erIce)
        try? container.encode(erOther, forKey: .erOther)
        try? container.encode(erSwell, forKey: .erSwell)
        try? container.encode(erTide, forKey: .erTide)
        try? container.encode(etaMessage, forKey: .etaMessage)
        try? container.encode(firstPortOfEntry, forKey: .firstPortOfEntry)
        try? container.encode(garbageDisposal, forKey: .garbageDisposal)
        try? container.encode(goodHoldingGround, forKey: .goodHoldingGround)
        try? container.encode(harborSize, forKey: .harborSize)
        try? container.encode(harborType, forKey: .harborType)
        try? container.encode(harborUse, forKey: .harborUse)
        try? container.encode(latitudeDms, forKey: .latitudeDms)
        try? container.encode(lifts0, forKey: .lifts0)
        try? container.encode(lifts25, forKey: .lifts25)
        try? container.encode(lifts50, forKey: .lifts50)
        try? container.encode(lifts100, forKey: .lifts100)
        try? container.encode(liquifiedNaturalGasTerminalDepth, forKey: .liquifiedNaturalGasTerminalDepth)
        try? container.encode(loAnchor, forKey: .loAnchor)
        try? container.encode(loBeachMoor, forKey: .loBeachMoor)
        try? container.encode(loBreakBulk, forKey: .loBreakBulk)
        try? container.encode(loContainer, forKey: .loContainer)
        try? container.encode(loDangCargo, forKey: .loDangCargo)
        try? container.encode(loIceMoor, forKey: .loIceMoor)
        try? container.encode(loLiquidBulk, forKey: .loLiquidBulk)
        try? container.encode(loLongTerm, forKey: .loLongTerm)
        try? container.encode(loMedMoor, forKey: .loMedMoor)
        try? container.encode(longitudeDms, forKey: .longitudeDms)
        try? container.encode(loOilTerm, forKey: .loOilTerm)
        try? container.encode(loOther, forKey: .loOther)
        try? container.encode(loRoro, forKey: .loRoro)
        try? container.encode(loSolidBulk, forKey: .loSolidBulk)
        try? container.encode(loWharves, forKey: .loWharves)
        if let maxVesselBeam = maxVesselBeam {
            try? container.encode("\(maxVesselBeam)", forKey: .maxVesselBeam)
        }
        if let maxVesselDraft = maxVesselDraft {
            try? container.encode("\(maxVesselDraft)", forKey: .maxVesselDraft)
        }
        if let maxVesselLength = maxVesselLength {
            try? container.encode("\(maxVesselLength)", forKey: .maxVesselLength)
        }
        try? container.encode(medFacilities, forKey: .medFacilities)
        try? container.encode(navArea, forKey: .navArea)
        try? container.encode(offshoreMaxVesselBeam, forKey: .offshoreMaxVesselBeam)
        try? container.encode(offshoreMaxVesselDraft, forKey: .offshoreMaxVesselDraft)
        try? container.encode(offshoreMaxVesselLength, forKey: .offshoreMaxVesselLength)
        if let oilTerminalDepth = oilTerminalDepth {
            try? container.encode("\(oilTerminalDepth)", forKey: .oilTerminalDepth)
        }
        try? container.encode(overheadLimits, forKey: .overheadLimits)
        try? container.encode(portName, forKey: .portName)
        try? container.encode(portSecurity, forKey: .portSecurity)
        try? container.encode(ptAdvisable, forKey: .ptAdvisable)
        try? container.encode(ptAvailable, forKey: .ptAvailable)
        try? container.encode(ptCompulsory, forKey: .ptCompulsory)
        try? container.encode(ptLocalAssist, forKey: .ptLocalAssist)
        try? container.encode(publicationNumber, forKey: .publicationNumber)
        try? container.encode(qtOther, forKey: .qtOther)
        try? container.encode(qtPratique, forKey: .qtPratique)
        try? container.encode(qtSanitation, forKey: .qtSanitation)
        try? container.encode(railway, forKey: .railway)
        try? container.encode(regionName, forKey: .regionName)
        try? container.encode(repairCode, forKey: .repairCode)
        try? container.encode(s57Enc, forKey: .s57Enc)
        try? container.encode(s101Enc, forKey: .s101Enc)
        try? container.encode(searchAndRescue, forKey: .searchAndRescue)
        try? container.encode(shelter, forKey: .shelter)
        try? container.encode(srDiving, forKey: .srDiving)
        try? container.encode(srElectricalRepair, forKey: .srElectricalRepair)
        try? container.encode(srElectrical, forKey: .srElectrical)
        try? container.encode(srIceBreaking, forKey: .srIceBreaking)
        try? container.encode(srLongshore, forKey: .srLongshore)
        try? container.encode(srNavigationalEquipment, forKey: .srNavigationalEquipment)
        try? container.encode(srSteam, forKey: .srSteam)
        try? container.encode(suAviationFuel, forKey: .suAviationFuel)
        try? container.encode(suDeck, forKey: .suDeck)
        try? container.encode(suDiesel, forKey: .suDiesel)
        try? container.encode(suEngine, forKey: .suEngine)
        try? container.encode(suFuel, forKey: .suFuel)
        try? container.encode(suProvisions, forKey: .suProvisions)
        try? container.encode(suWater, forKey: .suWater)
        try? container.encode(tide, forKey: .tide)
        try? container.encode(trafficSeparationScheme, forKey: .trafficSeparationScheme)
        try? container.encode(tugsAssist, forKey: .tugsAssist)
        try? container.encode(tugsSalvage, forKey: .tugsSalvage)
        try? container.encode(turningArea, forKey: .turningArea)
        try? container.encode(ukcMgmtSystem, forKey: .ukcMgmtSystem)
        try? container.encode(unloCode, forKey: .unloCode)
        try? container.encode(usRep, forKey: .usRep)
        try? container.encode(vesselTrafficService, forKey: .vesselTrafficService)
    }
    
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
        self.goodHoldingGround = try? values.decode(String.self, forKey: .goodHoldingGround)
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
        
        let mgrsPosition = MGRS.from(longitude, latitude)
        self.mgrs10km = mgrsPosition.coordinate(.TEN_KILOMETER)
    }
    
    init(port: Port) {
        self.port = port
        self.canBookmark = true
        self.alternateName = port.alternateName
        self.anchorageDepth = Int(port.anchorageDepth)
        self.cargoPierDepth = Int(port.cargoPierDepth)
        self.channelDepth = Int(port.channelDepth)
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
        self.entranceWidth = Int(port.entranceWidth)
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
        self.liquifiedNaturalGasTerminalDepth = Int(port.liquifiedNaturalGasTerminalDepth)
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
        self.maxVesselBeam = Int(port.maxVesselBeam)
        self.maxVesselDraft = Int(port.maxVesselDraft)
        self.maxVesselLength = Int(port.maxVesselLength)
        self.medFacilities = port.medFacilities
        self.mgrs10km = port.mgrs10km
        self.navArea = port.navArea
        self.offshoreMaxVesselBeam = Int(port.offshoreMaxVesselBeam)
        self.offshoreMaxVesselDraft = Int(port.offshoreMaxVesselDraft)
        self.offshoreMaxVesselLength = Int(port.offshoreMaxVesselLength)
        self.oilTerminalDepth = Int(port.oilTerminalDepth)
        self.overheadLimits = port.overheadLimits
        self.portName = port.portName
        self.portNumber = Int(port.portNumber)
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
        self.regionNumber = Int(port.regionNumber)
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
        self.tide = Int(port.tide)
        self.trafficSeparationScheme = port.trafficSeparationScheme
        self.tugsAssist = port.tugsAssist
        self.tugsSalvage = port.tugsSalvage
        self.turningArea = port.turningArea
        self.ukcMgmtSystem = port.ukcMgmtSystem
        self.unloCode = port.unloCode
        self.usRep = port.usRep
        self.vesselTrafficService = port.vesselTrafficService
    }
    
    init?(feature: Feature) {
        if let json = try? JSONEncoder().encode(feature.properties), let string = String(data: json, encoding: .utf8) {
            
            let decoder = JSONDecoder()
            let jsonData = Data(string.utf8)
            if let ds = try? decoder.decode(PortModel.self, from: jsonData) {
                self = ds
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
            KeyValue(key: "Region Name", value: "\(regionName ?? "") - \(regionNumber ?? 0)"),
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
            KeyValue(key: "Tidal Range (m)", value: tide?.zeroIsEmptyString),
            KeyValue(key: "Entrance Width (m)", value: entranceWidth?.zeroIsEmptyString),
            KeyValue(key: "Channel Depth (m)", value: channelDepth?.zeroIsEmptyString),
            KeyValue(key: "Anchorage Depth (m)", value: anchorageDepth?.zeroIsEmptyString),
            KeyValue(key: "Cargo Pier Depth (m)", value: cargoPierDepth?.zeroIsEmptyString),
            KeyValue(key: "Oil Terminal Depth (m)", value: oilTerminalDepth?.zeroIsEmptyString),
            KeyValue(key: "Liquified Natural Gas Terminal Depth (m)", value: liquifiedNaturalGasTerminalDepth?.zeroIsEmptyString)
        ]
    }
    
    var maximumVesselSizeKeyValues: [KeyValue] {
        return [
            KeyValue(key: "Maximum Vessel Length (m)", value: maxVesselLength?.zeroIsEmptyString),
            KeyValue(key: "Maximum Vessel Beam (m)", value: maxVesselBeam?.zeroIsEmptyString),
            KeyValue(key: "Maximum Vessel Draft (m)", value: maxVesselDraft?.zeroIsEmptyString),
            KeyValue(key: "Offshore Maximum Vessel Length (m)", value: offshoreMaxVesselLength?.zeroIsEmptyString),
            KeyValue(key: "Offshore Maximum Vessel Beam (m)", value: offshoreMaxVesselBeam?.zeroIsEmptyString),
            KeyValue(key: "Offshore Maximum Vessel Draft (m)", value: offshoreMaxVesselDraft?.zeroIsEmptyString)
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
            "goodHoldingGround": goodHoldingGround,
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
        case goodHoldingGround
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
}

extension PortModel: MapImage {
    static var cacheTiles: Bool = true
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: MapBoundingBox?, context: CGContext? = nil) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
}
