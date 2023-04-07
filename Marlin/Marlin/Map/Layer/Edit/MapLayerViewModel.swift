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
import geopackage_ios
import proj_ios

enum LayerType: String {
    case xyz = "XYZ"
    case wms = "WMS"
    case tms = "TMS"
    case geopackage = "GeoPackage"
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

protocol LayerInfo: Identifiable, Hashable {
    var name: String { get }
    var minLatitude: Double { get }
    var maxLatitude: Double { get }
    var minLongitude: Double { get }
    var maxLongitude: Double { get }
    var selected: Bool { get set }
}

extension LayerInfo {
    var id: String { name }
    
    var boundingBoxDisplay: String {
        return "(\(minLatitude.latitudeDisplay), \(minLongitude.longitudeDisplay)) - (\(maxLatitude.latitudeDisplay), \(maxLongitude.longitudeDisplay))"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    

}

class TileLayerInfo: LayerInfo, ObservableObject {
    var name: String
    var minZoom: Int
    var maxZoom: Int
    var minLatitude: Double = -90.0
    var maxLatitude: Double = 90.0
    var minLongitude: Double = -180.0
    var maxLongitude: Double = 180.0
    
    @Published var selected: Bool = false
    
    init(name: String, minZoom: Int, maxZoom: Int, minLatitude: Double = -90.0, maxLatitude: Double = 90.0, minLongitude: Double = -180.0, maxLongitude: Double = 180.0) {
        self.name = name
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    static func == (lhs: TileLayerInfo, rhs: TileLayerInfo) -> Bool {
        return lhs.id == rhs.id
    }

}

extension TileLayerInfo {
    convenience init(name: String, minZoom: Int, maxZoom: Int, boundingBox: GPKGBoundingBox) {
        self.init(name: name, minZoom: minZoom, maxZoom: maxZoom, minLatitude: boundingBox.minLatitude.doubleValue, maxLatitude: boundingBox.maxLatitude.doubleValue, minLongitude: boundingBox.minLongitude.doubleValue, maxLongitude: boundingBox.maxLongitude.doubleValue)
    }
}

class FeatureLayerInfo: LayerInfo, ObservableObject {
    var name: String
    var count: Int
    var minLatitude: Double = -90.0
    var maxLatitude: Double = 90.0
    var minLongitude: Double = -180.0
    var maxLongitude: Double = 180.0
    @Published var selected: Bool = false
    
    init(name: String, count: Int, minLatitude: Double = -90.0, maxLatitude: Double = 90.0, minLongitude: Double = -180.0, maxLongitude: Double = 180.0) {
        self.name = name
        self.count = count
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
    }
    
    static func == (lhs: FeatureLayerInfo, rhs: FeatureLayerInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

extension FeatureLayerInfo {
    convenience init(name: String, count: Int, boundingBox: GPKGBoundingBox) {
        self.init(name: name, count: count, minLatitude: boundingBox.minLatitude.doubleValue, maxLatitude: boundingBox.maxLatitude.doubleValue, minLongitude: boundingBox.minLongitude.doubleValue, maxLongitude: boundingBox.maxLongitude.doubleValue)
    }
}

class MapLayerViewModel: ObservableObject {
    @Published var url: String = "" {
        didSet {
            if url != oldValue {
                capabilities = nil
                urlPublisher.send(url)
            }
        }
    }
    @Published var displayName: String = ""
    
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
            } else if layerType == .xyz || layerType == .tms {
                updateTemplate()
            }
        }
    }
    @Published var refreshRate: Int = 0
    @Published var refreshRateUnits: RefreshRateUnit = .none
    @Published var minimumZoom: Int = 0
    @Published var maximumZoom: Int = 25
    @Published var minLatitude: Double = -90.0
    @Published var maxLatitude: Double = 90.0
    @Published var minLongitude: Double = -180.0
    @Published var maxLongitude: Double = 180.0
    
    @Published var username: String?
    @Published var password: String?
    @Published var urlTemplate: String?
    @Published var tabSelection: Int? = 0
    
    @Published var importingFile: Bool = false
    @Published var fileImported: Bool = false
    @Published var confirmFileOverwrite: Bool = false
    @Published var fileUrl: URL?
    @Published var fileLayers: [String] = []
    @Published var fileName: String?
    @Published var selectedFileLayers: [any LayerInfo] = []
    
    var geoPackage: GPKGGeoPackage?  {
        didSet {
            populateFileLayers()
        }
    }
    
    @Published var selectedGeoPackageTables: [String]?
    var documentPickerViewModel: DocumentPickerViewModel = DocumentPickerViewModel()
    
    var urlOK: Bool {
        url.isValidURL && ((layerType == .wms && capabilities != nil) || (layerType != .unknown))
    }
    
    static let INITIAL_TAB = 0
    static let WMS_TAB = 1
    static let FINAL_CONFIGURATION = 2
    
    var layersOK: Bool {
        if !layers.isEmpty {
            return true
        }
        return false
    }
    
    var layers: [String] {
        if layerType == .wms {
            guard let layers = capabilities?.selectedLayers else {
                return []
            }
            
            var layerNameArray: [String] = []
            for layer in layers {
                if let name = layer.name {
                    layerNameArray.append(name)
                }
            }
            return layerNameArray
        } else if layerType == .geopackage {
            return selectedFileLayers.map { $0.name }
        }
        return []
    }
    
    var tileLayers: [TileLayerInfo] {
        var tileLayers: [TileLayerInfo] = []
        if let geoPackage = geoPackage {
            for tileTable in geoPackage.tileTables() {
                if let tileDao = geoPackage.tileDao(withTableName: tileTable) {
                    let bb: GPKGBoundingBox = tileDao.contents().boundingBox().transform(SFPGeometryTransform(from: tileDao.projection, andToEpsg: 4326)) ?? GPKGBoundingBox.worldWGS84()
                    tileLayers.append(TileLayerInfo(name: tileDao.tableName, minZoom: Int(tileDao.mapMinZoom()), maxZoom: Int(tileDao.mapMaxZoom()), boundingBox: bb))
                }
            }
        }
        return tileLayers
    }
    
    var featureLayers: [FeatureLayerInfo] {
        var featureLayers: [FeatureLayerInfo] = []
        if let geoPackage = geoPackage {
            for featureTable in geoPackage.featureTables() {
                if let featureDao = geoPackage.featureDao(withTableName: featureTable) {
                    let bb: GPKGBoundingBox = featureDao.contents().boundingBox().transform(SFPGeometryTransform(from: featureDao.projection, andToEpsg: 4326)) ?? GPKGBoundingBox.worldWGS84()
                    featureLayers.append(FeatureLayerInfo(name: featureDao.tableName, count: Int(featureDao.count()), boundingBox: bb))
                }
            }
        }
        return featureLayers
    }
    
    func updateBounds() {
        if layerType == .geopackage {
            if selectedFileLayers.isEmpty {
                minLatitude = -90.0
                maxLatitude = 90.0
                minLongitude = -180.0
                maxLongitude = 180.0
            } else {
                minLatitude = selectedFileLayers[0].minLatitude
                maxLatitude = selectedFileLayers[0].maxLatitude
                minLongitude = selectedFileLayers[0].minLongitude
                maxLongitude = selectedFileLayers[0].maxLongitude
                for selectedFileLayer in selectedFileLayers.dropFirst() {
                    minLatitude = min(minLatitude, selectedFileLayer.minLatitude)
                    maxLatitude = max(maxLatitude, selectedFileLayer.maxLatitude)
                    minLongitude = min(minLongitude, selectedFileLayer.minLongitude)
                    maxLongitude = max(maxLongitude, selectedFileLayer.maxLongitude)
                }
            }
        } else if layerType == .wms {
            guard !url.isEmpty, let layers = capabilities?.selectedLayers, !layers.isEmpty else {
                minLatitude = -90.0
                maxLatitude = 90.0
                minLongitude = -180.0
                maxLongitude = 180.0
                return
            }
            
            if let boundingBox = layers[0].boundingBox, let minLatitude = boundingBox.minLatitude, let maxLatitude = boundingBox.maxLatitude, let minLongitude = boundingBox.minLongitude, let maxLongitude = boundingBox.maxLongitude {
                self.minLatitude = minLatitude
                self.maxLatitude = maxLatitude
                self.minLongitude = minLongitude
                self.maxLongitude = maxLongitude
                
            }
            for layer in layers.dropFirst() {
                if let boundingBox = layer.boundingBox, let minLatitude = boundingBox.minLatitude, let maxLatitude = boundingBox.maxLatitude, let minLongitude = boundingBox.minLongitude, let maxLongitude = boundingBox.maxLongitude {
                    self.minLatitude = min(self.minLatitude, minLatitude)
                    self.maxLatitude = max(self.maxLatitude, maxLatitude)
                    self.minLongitude = min(self.minLongitude, minLongitude)
                    self.maxLongitude = max(self.maxLongitude, maxLongitude)
                }
            }
        }
    }
    
    func updateSelectedFileLayers(layer: any LayerInfo) {
        if layer.selected {
            selectedFileLayers.append(layer)
        } else if let index = selectedFileLayers.firstIndex(where: { layerInfo in
            layerInfo.name == layer.name
        }) {
            selectedFileLayers.remove(at: index)
        }
        updateBounds()
    }

    func populateFileLayers() {
        let tileTables = geoPackage?.tileTables() ?? []
        let featureTables = geoPackage?.featureTables() ?? []
        fileLayers = tileTables + featureTables
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
            updateBounds()
        } else if layerType == .xyz || layerType == .tms {
            guard !url.isEmpty else {
                urlTemplate = nil
                return
            }
            urlTemplate = "\(url)/{z}/{x}/{y}.png"
        }
    }
    
    var cancellable = Set<AnyCancellable>()
    let urlPublisher = PassthroughSubject<String, Never>()
    let importer = GeoPackageImporter()
    
    init() {
        urlPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink(receiveValue: { newUrl in
                if !newUrl.isEmpty {
                    self.retrieveWMSCapabilitiesDocument()
                }
            })
            .store(in: &cancellable)
        
        documentPickerViewModel.$url.receive(on: DispatchQueue.main).sink { url in
            if let url = url {
                self.fileChosen(url: url)
            }
        }
        .store(in: &cancellable)
        
        importer.progress.$complete.receive(on: DispatchQueue.main).sink { complete in
            self.geoPackageImported()
        }
        .store(in: &cancellable)
    }
    
    func fileChosen(url: URL, forceImport: Bool = false) {
        layerType = .unknown
        importingFile = true
        fileUrl = url
        let securityScoped = url.startAccessingSecurityScopedResource()
        
        if importer.alreadyImported(url: url) && !forceImport {
            confirmFileOverwrite = true
            importingFile = false
        } else if forceImport {
            confirmFileOverwrite = false
            fileName = importer.uniqueName(url: url)
            importer.importGeoPackage(url: url, nameOverride: fileName, overwrite: true)
        } else {
            confirmFileOverwrite = false
            fileName = importer.fileName(url: url)
            importer.importGeoPackage(url: url, overwrite: false)
        }
        
        if securityScoped {
            url.stopAccessingSecurityScopedResource()
        }
    }
    
    func useExistingFile(url: URL) {
        importingFile = false
        fileName = importer.fileName(url: url)
        if let name = fileName, importer.alreadyImported(url: url) {
            geoPackage = GeoPackage.shared.getGeoPackage(name: name)
            layerType = .geopackage
        } else {
            // unsuccessful import
        }
    }
    
    func geoPackageImported() {
        importingFile = false
        
        if let name = fileName, importer.alreadyImported(name: name) {
            geoPackage = GeoPackage.shared.getGeoPackage(name: name)
            layerType = .geopackage
        } else {
            // unsuccessful import
        }
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
            capabilities?.correctBounds()
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
    
    func correctBounds() {
        if let layers = layers {
            for layer in layers {
                layer.correctBounds(parentBounds: nil)
            }
        }
    }
}

final class BoundingBox: XMLObjectDeserialization {
    let minLongitude: Double?
    let maxLongitude: Double?
    let minLatitude: Double?
    let maxLatitude: Double?
    
    init(minLongitude: Double?, maxLongitude: Double?, minLatitude: Double?, maxLatitude: Double?) {
        self.minLongitude = minLongitude
        self.maxLongitude = maxLongitude
        self.minLatitude = minLatitude
        self.maxLatitude = maxLatitude
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> BoundingBox {
        return try BoundingBox(
            minLongitude: node["westBoundLongitude"].value(),
            maxLongitude: node["eastBoundLongitude"].value(),
            minLatitude: node["southBoundLatitude"].value(),
            maxLatitude: node["northBoundLatitude"].value()
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
    var boundingBox: BoundingBox?
    let transparent: Bool
    
    @Published var selected: Bool = false
    
    var boundingBoxDisplay: String {
        if let boundingBox = boundingBox, let minLatitude = boundingBox.minLatitude, let maxLatitude = boundingBox.maxLatitude, let minLongitude = boundingBox.minLongitude, let maxLongitude = boundingBox.maxLongitude {
            return "(\(minLatitude.latitudeDisplay), \(minLongitude.longitudeDisplay)) - (\(maxLatitude.latitudeDisplay), \(maxLongitude.longitudeDisplay))"
        }
        return ""
    }
    
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
        return Layer(title: title, abstract: abstract, name: name, crs: crs, layers: sublayers, boundingBox: boundingBox, transparent: transparent)
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
    
    init(title: String?, abstract: String?, name: String?, crs: [String]?, layers: [Layer]?, boundingBox: BoundingBox?, transparent: Bool) {
        self.title = title
        self.abstract = abstract
        self.name = name
        self.crs = crs
        self.layers = layers
        self.boundingBox = boundingBox
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
            boundingBox: node["EX_GeographicBoundingBox"].value(),
            transparent: transparent
        )
    }
    
    func correctBounds(parentBounds: BoundingBox?) {
        boundingBox = boundingBox ?? parentBounds
        if let layers = layers {
            for layer in layers {
                layer.correctBounds(parentBounds: boundingBox)
            }
        }
    }
}
