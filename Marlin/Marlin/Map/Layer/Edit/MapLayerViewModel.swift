//
//  MapLayerViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 3/17/23.
//

import Foundation
import Combine
import Alamofire
import SWXMLHash

enum LayerType: String {
    case xyz = "XYZ"
    case wms = "WMS"
    case tms = "TMS"
    case unknown = "Unknown"
}

enum RefreshRateUnit: Int, Equatable, CaseIterable {
    case none = 0
    case minutes = 1
    case hours = 60
    case days = 1440
    
    var name: String {
        switch(self) {
        case .none:
            return "No Auto Refresh"
        case .minutes:
            return "Minutes"
        case .hours:
            return "Hours"
        case .days:
            return "Days"
        }
    }
}

class MapLayerViewModel: ObservableObject {
    @Published var url: String = "" {
        didSet {
            urlPublisher.send(url)
        }
    }
    @Published var displayName: String = ""
    @Published var name: String = ""
    
    @Published var retrievingWMSCapabilities: Bool = false
    @Published var triedCapabilities: Bool = false
    @Published var triedXYZTile: Bool = false
    @Published var retrievingXYZTile: Bool = false
    @Published var capabilities: WMSCapabilities?
    @Published var layerType: LayerType = .unknown {
        didSet {
            if layerType == .wms {
                if capabilities == nil {
                    retrieveWMSCapabilitiesDocument()
                }
            } else if layerType != .unknown {
                updateTemplate()
            }
        }
    }
    @Published var refreshRate: Int = 0
    @Published var refreshRateUnits: RefreshRateUnit = .none
    @Published var minimumZoom: Int = 0
    @Published var maximumZoom: Int = 25
    
    @Published var username: String?
    @Published var password: String?
    @Published var urlTemplate: String?
    @Published var tabSelection: Int? = 0
    
    var urlOK: Bool {
        url.isValidURL && ((layerType == .wms && capabilities != nil) || (layerType != .unknown))
    }
    
    static let INITIAL_TAB = 0
    static let WMS_TAB = 1
    static let FINAL_CONFIGURATION = 2
    
    var layersOK: Bool {
        if let layers = capabilities?.selectedLayers, !layers.isEmpty {
            return true
        }
        return false
    }
    
    func create() {
        PersistenceController.current.perform {
            let _ = MapLayer.createFrom(viewModel: self, context: PersistenceController.current.viewContext)
            do {
                try PersistenceController.current.viewContext.save()
            } catch {
                print("Error saving layer \(error)")
            }
        }
    }
    
    func updateTemplate() {
        if layerType == .wms {
            guard !url.isEmpty, let layers = capabilities?.selectedLayers, let version = capabilities?.version else {
                urlTemplate = nil
                return
            }
            
            var layerNameArray: [String] = []
            var transparent: Bool = true
            
            for layer in layers {
                if let name = layer.name {
                    layerNameArray.append(name)
                }
                transparent = transparent && layer.transparent
            }
            let layerNames = layerNameArray.joined(separator: ",")
            
            urlTemplate = "\(url)?SERVICE=WMS&VERSION=\(version)&REQUEST=GetMap&FORMAT=\(transparent ? "image%2Fpng" : "image%2Fjpeg")&TRANSPARENT=\(transparent)&LAYERS=\(layerNames)&TILED=true&WIDTH=512&HEIGHT=512&CRS=EPSG%3A3857&STYLES="
        } else if layerType != .unknown {
            guard !url.isEmpty else {
                urlTemplate = nil
                return
            }
            urlTemplate = "\(url)/{z}/{x}/{y}.png"
        }
    }
    
    var cancellable = Set<AnyCancellable>()
    let urlPublisher = PassthroughSubject<String, Never>()
    
    init() {
        urlPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink(receiveValue: { newUrl in
                if !newUrl.isEmpty {
                    self.retrieveWMSCapabilitiesDocument()
                }
            })
            .store(in: &cancellable)
    }
    
    func retrieveXYZTile() {
        guard let url = URL(string: "\(url)/0/0/0.png") else {
            print("invalid url")
            return
        }
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        MSI.shared.capabilitiesSession.request(url, method: .get)
            .onURLRequestCreation(perform: { request in
                self.retrievingXYZTile = true
                self.triedXYZTile = false
            })
            .validate()
            .publishData()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { response in
                self.triedXYZTile = true
                self.retrievingXYZTile = false
                if let error = response.error {
                    print("Error retrieving capabilities \(error)")
                    return
                }
                if let _ = try? response.result.get() {
                    if self.layerType != .tms && self.layerType != .xyz {
                        self.layerType = .xyz
                    }
                }
            })
            .store(in: &cancellable)
    }
    
    func retrieveWMSCapabilitiesDocument() {
        do {
            guard let url = URL(string: url) else {
                print("invalid url")
                return
            }
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let parameters: Parameters = [
                "SERVICE":"WMS",
                "REQUEST": "GetCapabilities"
            ]
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
            MSI.shared.capabilitiesSession.request(url, method: .get, parameters: parameters)
                .onURLRequestCreation(perform: { request in
                    self.retrievingWMSCapabilities = true
                    self.triedCapabilities = false
                })
                .validate()
                .publishString()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { response in
                    self.triedCapabilities = true
                    self.retrievingWMSCapabilities = false
                    if let error = response.error {
                        print("Error retrieving capabilities \(error)")
                        self.retrieveXYZTile()
                        return
                    }
                    if let string = try? response.result.get() {
                        self.capabilities = self.parseDocument(string: string)
                        if self.capabilities != nil {
                            self.layerType = .wms
                        } else {
                            self.retrieveXYZTile()
                        }
                    } else {
                        self.retrieveXYZTile()
                    }
                })
                .store(in: &cancellable)
        } catch {
            print("Error making request \(error)")
        }
    }
    
    func parseDocument(string: String) -> WMSCapabilities? {
        let xml = XMLHash.config { config in
            config.caseInsensitive = true
        }.parse(string)
        do {
            let capabilities: WMSCapabilities? = try xml["WMS_Capabilities"].value()
            return capabilities
        } catch {
            print("Error parsing capabilities \(error)")
        }
        return nil
    }
}

struct GetMap: XMLObjectDeserialization {
    let formats: [String]
    
    static func deserialize(_ element: XMLIndexer) throws -> GetMap {
        return try GetMap(formats: element["Format"].value())
    }
}

struct WMSCapabilities: XMLObjectDeserialization {
    let title: String?
    let abstract: String?
    let version: String?
    let contactPerson: String?
    let contactOrganization: String?
    let contactTelephone: String?
    let contactEmail: String?
    let layers: [Layer]?
    let getMap: GetMap?
    
    var webMercatorLayers: [Layer] {
        return layers?.reduce([], { partialResult, layer in
            if let layer = layer.webMercatorLayers() {
                return partialResult + [layer]
            }
            return partialResult
        }) ?? []
    }
    
    var selectedLayers: [Layer] {
        var selected: [Layer] = []
        if let layers = layers {
            for layer in layers {
                selected += layer.selectedLayers
            }
        }
        return selected
    }
    
    var totalLayers: Int {
        return layers?.reduce(0, { partialResult, layer in
            return (layer.name != nil ? partialResult + 1 : partialResult) + layer.layerCount
        }) ?? 0
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> WMSCapabilities {
        return try WMSCapabilities(
            title: node["Service"]["Title"].value(),
            abstract: node["Service"]["Abstract"].value(),
            version: node.value(ofAttribute: "version"),
            contactPerson: node["Service"]["ContactInformation"]["ContactPersonPrimary"]["ContactPerson"].value(),
            contactOrganization: node["Service"]["ContactInformation"]["ContactPersonPrimary"]["ContactOrganization"].value(),
            contactTelephone: node["Service"]["ContactInformation"]["ContactVoiceTelephone"].value(),
            contactEmail: node["Service"]["ContactInformation"]["ContactElectronicMailAddress"].value(),
            layers: node["Capability"]["Layer"].value(),
            getMap: node["Capability"]["Request"]["GetMap"].value()
        )
    }
}

final class Layer: XMLObjectDeserialization, Identifiable, ObservableObject {
    var id: String { name ?? "" }
    
    let title: String?
    let abstract: String?
    let name: String?
    let crs: [String]?
    let layers: [Layer]?
    let transparent: Bool
    
    @Published var selected: Bool = false
    
    var isWebMercator: Bool {
        if let crs = crs, crs.contains(where: { code in
            code == "EPSG:3857" || code == "EPSG:900913"
        }) {
            return true
        }
        return false
    }
    
    func webMercatorLayers(parentIsWebMercator: Bool = false) -> Layer? {
        var sublayers: [Layer] = []
        if parentIsWebMercator {
            sublayers = layers?.reduce([], { partialResult, layer in
                if let layer = layer.webMercatorLayers(parentIsWebMercator: true) {
                    return partialResult + [layer]
                }
                return partialResult
            }) ?? []
        }
        
        if let crs = crs, crs.contains(where: { code in
            code == "EPSG:3857" || code == "EPSG:900913"
        }) {
            sublayers = layers?.reduce([], { partialResult, layer in
                if let layer = layer.webMercatorLayers(parentIsWebMercator: true) {
                    return partialResult + [layer]
                }
                return partialResult
            }) ?? []
        } else if name == nil {
            sublayers = layers?.reduce([], { partialResult, layer in
                if let layer = layer.webMercatorLayers(parentIsWebMercator: parentIsWebMercator) {
                    return partialResult + [layer]
                }
                return partialResult
            }) ?? []
        } else {
            sublayers = layers?.reduce([], { partialResult, layer in
                if let layer = layer.webMercatorLayers(parentIsWebMercator: parentIsWebMercator) {
                    return partialResult + [layer]
                }
                return partialResult
            }) ?? []
        }
        return Layer(title: title, abstract: abstract, name: name, crs: crs, layers: sublayers, transparent: transparent)
    }
    
    var selectedLayers: [Layer] {
        
        let selectedLayers: [Layer] = layers?.filter({ layer in
            layer.selected && layer.name != nil
        }).map({ layer in
            layer
        }) ?? []
        
        let selectedSubLayers: [Layer] = layers?.filter({ layer in
            if let layers = layer.layers, !layers.isEmpty {
                return true
            }
            return false
        }).reduce(selectedLayers, { partialResult, layer in
            return layer.selectedLayers + partialResult
        }) ?? []
        
        return selectedSubLayers
    }
    
    var layerCount: Int {
        return layers?.reduce(0, { partialResult, layer in
            return layer.name != nil ? partialResult + layer.layerCount + 1 : partialResult + layer.layerCount
        }) ?? 0
    }
    
    init(title: String?, abstract: String?, name: String?, crs: [String]?, layers: [Layer]?, transparent: Bool) {
        self.title = title
        self.abstract = abstract
        self.name = name
        self.crs = crs
        self.layers = layers
        self.transparent = transparent
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> Layer {
        var transparent = true
        let opaque: Int? = node.value(ofAttribute: "opaque")
        if let opaque = opaque {
            transparent = opaque == 1 ? false : true
        } else {
            transparent = false
        }
        
        return try Layer(
            title: node["Title"].value(),
            abstract: node["Abstract"].value(),
            name: node["Name"].value(),
            crs: node["CRS"].all.map { elem in
                let crs: String? = try? elem.value()
                return crs ?? ""
            },
            layers: node["Layer"].value(),
            transparent: transparent
        )
    }
}
