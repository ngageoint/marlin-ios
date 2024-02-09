//
//  PortFilterable.swift
//  Marlin
//
//  Created by Daniel Barela on 12/18/23.
//

import Foundation

// disable these checks, this data type has a lot of properties
// swiftlint:disable type_body_length file_length
struct PortFilterable: Filterable {
    var definition: any DataSourceDefinition {
        DataSourceDefinitions.port.definition
    }

    var defaultSort: [DataSourceSortParameter] = [
        DataSourceSortParameter(
            property: DataSourceProperty(
                name: "World Port Index Number",
                key: #keyPath(Port.portNumber),
                type: .int),
            ascending: false)
    ]

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
        DataSourceProperty(
            name: "Sailing Directions or Publication",
            key: #keyPath(Port.publicationNumber),
            type: .string),
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
        DataSourceProperty(
            name: "Oil Terminal Depth (m)",
            key: #keyPath(Port.oilTerminalDepth),
            type: .int),
        DataSourceProperty(
            name: "Liquified Natural Gas Terminal Depth (m)",
            key: #keyPath(Port.liquifiedNaturalGasTerminalDepth),
            type: .int),

        // Maximum Vessel Size
        DataSourceProperty(name: "Maximum Vessel Length (m)", key: #keyPath(Port.maxVesselLength), type: .int),
        DataSourceProperty(name: "Maximum Vessel Beam (m)", key: #keyPath(Port.maxVesselBeam), type: .int),
        DataSourceProperty(
            name: "Maximum Vessel Draft (m)",
            key: #keyPath(Port.maxVesselDraft),
            type: .int),
        DataSourceProperty(
            name: "Offshore Maximum Vessel Length (m)",
            key: #keyPath(Port.offshoreMaxVesselLength),
            type: .int),
        DataSourceProperty(
            name: "Offshore Maximum Vessel Beam (m)",
            key: #keyPath(Port.offshoreMaxVesselBeam),
            type: .int),
        DataSourceProperty(
            name: "Offshore Maximum Vessel Draft (m)",
            key: #keyPath(Port.offshoreMaxVesselDraft),
            type: .int),

        // Physical Environment
        DataSourceProperty(
            name: "Harbor Size",
            key: #keyPath(Port.harborSize),
            type: .enumeration,
            enumerationValues: SizeEnum.keyValueMap),
        DataSourceProperty(
            name: "Harbor Type",
            key: #keyPath(Port.harborType),
            type: .enumeration,
            enumerationValues: HarborTypeEnum.keyValueMap),
        DataSourceProperty(
            name: "Harbor Use",
            key: #keyPath(Port.harborUse),
            type: .enumeration,
            enumerationValues: HarborUseEnum.keyValueMap),
        DataSourceProperty(
            name: "Shelter",
            key: #keyPath(Port.shelter),
            type: .enumeration,
            enumerationValues: ConditionEnum.keyValueMap),
        DataSourceProperty(
            name: "Entrance Restriction - Tide",
            key: #keyPath(Port.erTide),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Entrance Restriction - Heavy Swell",
            key: #keyPath(Port.erSwell),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Entrance Restriction - Ice",
            key: #keyPath(Port.erIce),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Entrance Restriction - Other",
            key: #keyPath(Port.erOther),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Overhead Limits",
            key: #keyPath(Port.overheadLimits),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Underkeel Clearance Management System",
            key: #keyPath(Port.ukcMgmtSystem),
            type: .enumeration,
            enumerationValues: UnderkeelClearanceEnum.keyValueMap),
        DataSourceProperty(
            name: "Good Holding Ground",
            key: #keyPath(Port.goodHoldingGround),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Turning Area",
            key: #keyPath(Port.turningArea),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),

        // Approach
        DataSourceProperty(
            name: "Port Security",
            key: #keyPath(Port.portSecurity),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Estimated Time Of Arrival Message",
            key: #keyPath(Port.etaMessage),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Quarantine - Pratique",
            key: #keyPath(Port.qtPratique),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Quarantine - Sanitation",
            key: #keyPath(Port.qtSanitation),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Quarantine - Other",
            key: #keyPath(Port.qtOther),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Traffic Separation Scheme",
            key: #keyPath(Port.trafficSeparationScheme),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Vessel Traffic Service",
            key: #keyPath(Port.vesselTrafficService),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "First Port Of Entry",
            key: #keyPath(Port.firstPortOfEntry),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),

        // Pilots Tugs Communications
        DataSourceProperty(
            name: "Pilotage - Compulsory",
            key: #keyPath(Port.ptCompulsory),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Pilotage - Available",
            key: #keyPath(Port.ptAvailable),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Pilotage - Local Assistance",
            key: #keyPath(Port.ptLocalAssist),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Pilotage - Advisable",
            key: #keyPath(Port.ptAdvisable),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Tugs - Salvage",
            key: #keyPath(Port.tugsSalvage),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Tugs - Assistance",
            key: #keyPath(Port.tugsAssist),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Communications - Telephone",
            key: #keyPath(Port.cmTelephone),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Communications - Telefax",
            key: #keyPath(Port.cmTelegraph),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Communications - Radio",
            key: #keyPath(Port.cmRadio),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Communications - Radiotelephone",
            key: #keyPath(Port.cmRadioTel),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Communications - Airport",
            key: #keyPath(Port.cmAir),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Communications - Rail",
            key: #keyPath(Port.cmRail),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Search and Rescue",
            key: #keyPath(Port.searchAndRescue),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "NAVAREA",
            key: #keyPath(Port.navArea),
            type: .string),

        // Facilities
        DataSourceProperty(
            name: "Facilities - Wharves",
            key: #keyPath(Port.loWharves),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Anchorage",
            key: #keyPath(Port.loAnchor),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Dangerous Cargo Anchorage",
            key: #keyPath(Port.loDangCargo),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Med Mooring",
            key: #keyPath(Port.loMedMoor),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Beach Mooring",
            key: #keyPath(Port.loBeachMoor),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Ice Mooring",
            key: #keyPath(Port.loIceMoor),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - RoRo",
            key: #keyPath(Port.loRoro),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Solid Bulk",
            key: #keyPath(Port.loSolidBulk),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Liquid Bulk",
            key: #keyPath(Port.loLiquidBulk),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Container",
            key: #keyPath(Port.loContainer),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Breakbulk",
            key: #keyPath(Port.loBreakBulk),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Oil Terminal",
            key: #keyPath(Port.loOilTerm),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - LNG Terminal",
            key: #keyPath(Port.loLongTerm),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Facilities - Other",
            key: #keyPath(Port.loOther),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Medical Facilities",
            key: #keyPath(Port.medFacilities),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Garbage Disposal",
            key: #keyPath(Port.garbageDisposal),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Chemical Holding Tank Disposal",
            key: #keyPath(Port.chemicalHoldingTank),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Degaussing",
            key: #keyPath(Port.degauss),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Dirty Ballast Disposal",
            key: #keyPath(Port.dirtyBallast),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),

        // Cranes
        DataSourceProperty(
            name: "Cranes - Fixed",
            key: #keyPath(Port.craneFixed),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Cranes - Mobile",
            key: #keyPath(Port.craneMobile),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Cranes - Floating",
            key: #keyPath(Port.craneFloating),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Cranes - Container",
            key: #keyPath(Port.craneContainer),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Lifts - 100+ Tons",
            key: #keyPath(Port.lifts100),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Lifts - 50-100 Tons",
            key: #keyPath(Port.lifts50),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Lifts - 25-49 Tons",
            key: #keyPath(Port.lifts25),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Lifts - 0-24 Tons",
            key: #keyPath(Port.lifts0),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),

        // Services Supplies
        DataSourceProperty(
            name: "Services - Longshoremen",
            key: #keyPath(Port.srLongshore),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Services - Electricity",
            key: #keyPath(Port.srElectrical),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Services - Steam",
            key: #keyPath(Port.srSteam),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Services - Navigational Equipment",
            key: #keyPath(Port.srNavigationalEquipment),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Services - Electrical Repair",
            key: #keyPath(Port.srElectricalRepair),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Services - Ice Breaking",
            key: #keyPath(Port.srIceBreaking),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Services - Diving",
            key: #keyPath(Port.srDiving),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Provisions",
            key: #keyPath(Port.suProvisions),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Potable Water",
            key: #keyPath(Port.suWater),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Fuel Oil",
            key: #keyPath(Port.suFuel),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Diesel Oil",
            key: #keyPath(Port.suDiesel),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Aviation Fuel",
            key: #keyPath(Port.suAviationFuel),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Deck",
            key: #keyPath(Port.suDeck),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Supplies - Engine",
            key: #keyPath(Port.suEngine),
            type: .enumeration,
            enumerationValues: DecisionEnum.keyValueMap),
        DataSourceProperty(
            name: "Repair Code",
            key: #keyPath(Port.repairCode),
            type: .enumeration,
            enumerationValues: RepairCodeEnum.keyValueMap),
        DataSourceProperty(
            name: "Dry Dock",
            key: #keyPath(Port.drydock),
            type: .enumeration,
            enumerationValues: SizeEnum.keyValueMap),
        DataSourceProperty(
            name: "Railway",
            key: #keyPath(Port.railway),
            type: .enumeration,
            enumerationValues: SizeEnum.keyValueMap)
    ]

    var defaultFilter: [DataSourceFilterParameter] = []

//    var locatableClass: Locatable.Type? = Port.self
}
// swiftlint:enable type_body_length file_length
