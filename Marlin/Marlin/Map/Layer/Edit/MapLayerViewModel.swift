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
    var name: String? { get }
    var boundingBox: BoundingBox? { get }
    var selected: Bool { get set }
}

extension LayerInfo {
    var id: String { name ?? "" }
    
    var boundingBoxDisplay: String {
        return "(\((boundingBox?.minLatitude ?? 0).latitudeDisplay), \((boundingBox?.minLongitude ?? 0).longitudeDisplay)) - (\((boundingBox?.maxLatitude ?? 0).latitudeDisplay), \((boundingBox?.maxLongitude ?? 0).longitudeDisplay))"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    

}

class TileLayerInfo: LayerInfo, ObservableObject {
    var name: String?
    var minZoom: Int
    var maxZoom: Int
    var boundingBox: BoundingBox?
    
    @Published var selected: Bool = false
    
    init(name: String, minZoom: Int, maxZoom: Int, boundingBox: BoundingBox) {
        self.name = name
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.boundingBox = boundingBox
    }
    
    static func == (lhs: TileLayerInfo, rhs: TileLayerInfo) -> Bool {
        return lhs.id == rhs.id
    }

}

extension TileLayerInfo {
    convenience init(name: String, minZoom: Int, maxZoom: Int, boundingBox: GPKGBoundingBox) {
        self.init(name: name, minZoom: minZoom, maxZoom: maxZoom, boundingBox: BoundingBox(minLongitude: boundingBox.minLongitude.doubleValue, maxLongitude: boundingBox.maxLongitude.doubleValue, minLatitude: boundingBox.minLatitude.doubleValue, maxLatitude: boundingBox.maxLatitude.doubleValue))
    }
}

class FeatureLayerInfo: LayerInfo, ObservableObject {
    var name: String?
    var count: Int
    var boundingBox: BoundingBox?
    @Published var selected: Bool = false
    
    init(name: String, count: Int, boundingBox: BoundingBox) {
        self.name = name
        self.count = count
        self.boundingBox = boundingBox
    }
    
    static func == (lhs: FeatureLayerInfo, rhs: FeatureLayerInfo) -> Bool {
        return lhs.id == rhs.id
    }
}

extension FeatureLayerInfo {
    convenience init(name: String, count: Int, boundingBox: GPKGBoundingBox) {
        self.init(name: name, count: count, boundingBox: BoundingBox(minLongitude: boundingBox.minLongitude.doubleValue, maxLongitude: boundingBox.maxLongitude.doubleValue, minLatitude: boundingBox.minLatitude.doubleValue, maxLatitude: boundingBox.maxLatitude.doubleValue))
    }
}

private extension URL {
    var removingQueries: URL {
        if var components = URLComponents(string: absoluteString) {
            components.query = nil
            return components.url ?? self
        } else {
            return self
        }
    }
    
    var queryParameters: [String : String] {
        var queryParameters: [String : String] = [:]
        if let components = URLComponents(string: absoluteString) {
            if let queries = components.query?.components(separatedBy: "&") {
                for query in queries {
                    let parameter = query.components(separatedBy: "=")
                    if parameter.count > 0 {
                        queryParameters[parameter[0]] = parameter.count > 1 ? parameter[1] : ""
                    }
                }
            }
        }
        
        return queryParameters
    }
}

class MapLayerViewModel: ObservableObject, Identifiable {
    var id: String {
        displayName
    }
    @Published var url: String = "" {
        didSet {
            if url != oldValue {
                url = url.trimmingCharacters(in: .whitespacesAndNewlines)
                capabilities = nil
                urlPublisher.send(url)
            }
        }
    }
    var plainUrl: String {
        if let url = URL(string: url) {
            return url.removingQueries.absoluteString
        }
        return url
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
            } else {
                capabilities = nil
            }
            
            if layerType != .geopackage {
                fileUrl = nil
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
    
    @Published var error: String?
    
    @Published var username: String = "" {
        didSet {
            if username != oldValue {
                capabilities = nil
                urlPublisher.send(url)
            }
        }
    }
    
    @Published var password: String = "" {
        didSet {
            if password != oldValue {
                capabilities = nil
                urlPublisher.send(url)
            }
        }
    }
    
    var userUrlParameters: [String : String] {
        var userUrlParameters: [String: String] = [:]
        if let validUrl = URL(string: url) {
            userUrlParameters = validUrl.queryParameters.filter({ element in
                layerType != .wms || !wmsParameters.contains { param in
                    param == element.key.uppercased()
                }
            })
        }
        return userUrlParameters
    }
            
    var urlTemplate: String? {
        guard !url.isEmpty else {
            return nil
        }
        
        guard let url = URL(string:plainUrl) else {
            return nil
        }
        if layerType == .wms {
            let urlParamString = urlParameters.map({ (key: String, value: String) in
                "\(key)=\(value)"
            }).joined(separator: "&")
            
            return "\(url)?\(urlParamString)"
        } else if layerType == .xyz || layerType == .tms {
            if userUrlParameters.isEmpty {
                return "\(url)/{z}/{x}/{y}.png"
            } else {
                let urlParamString = urlParameters.map({ (key: String, value: String) in
                    "\(key)=\(value)"
                }).joined(separator: "&")
                return "\(url)/{z}/{x}/{y}.png?\(urlParamString)"
            }
        }
        return nil
    }
    @Published var tabSelection: Int? = 0
    
    @Published var importingFile: Bool = false
    @Published var fileImported: Bool = false
    @Published var confirmFileOverwrite: Bool = false
    @Published var fileUrl: URL?
    @Published var fileLayers: [String] = []
    @Published var fileName: String?
    @Published var selectedLayers: [any LayerInfo] = []
    
    @Published var order: Int?
    @Published var visible: Bool = true
    var mapLayer: MapLayer?
    
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
        if layerType == .geopackage {
            if !layers.isEmpty {
                return true
            }
        } else if layerType == .wms {
            return true
        }
        return false
    }
    
    var layers: [String] {
        return selectedLayers.compactMap { $0.name }
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
    
    func cancel() {
        if mapLayer == nil, let fileName = fileName, layerType == .geopackage {
            // this is a non saved layer.  If it is a GeoPackage layer, check if we should delete the GP
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                MapLayer.safeDeleteGeoPackage(name: fileName)
            }
        }
    }
    
    func updateBounds() {
        if selectedLayers.isEmpty {
            minLatitude = -90.0
            maxLatitude = 90.0
            minLongitude = -180.0
            maxLongitude = 180.0
        } else {
            minLatitude = selectedLayers[0].boundingBox?.minLatitude ?? 90.0
            maxLatitude = selectedLayers[0].boundingBox?.maxLatitude ?? -90.0
            minLongitude = selectedLayers[0].boundingBox?.minLongitude ?? 180.0
            maxLongitude = selectedLayers[0].boundingBox?.maxLongitude ?? -180.0
            for selectedLayer in selectedLayers.dropFirst() {
                minLatitude = min(minLatitude, selectedLayer.boundingBox?.minLatitude ?? minLatitude)
                maxLatitude = max(maxLatitude, selectedLayer.boundingBox?.maxLatitude ?? maxLatitude)
                minLongitude = min(minLongitude, selectedLayer.boundingBox?.minLongitude ?? minLongitude)
                maxLongitude = max(maxLongitude, selectedLayer.boundingBox?.maxLongitude ?? maxLongitude)
            }
        }
    }
    
    func updateSelectedLayers(layer: any LayerInfo) {
        if layer.selected {
            selectedLayers.append(layer)
        } else if let index = selectedLayers.firstIndex(where: { layerInfo in
            layerInfo.name == layer.name
        }) {
            selectedLayers.remove(at: index)
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
            if let mapLayer = self.mapLayer {
                mapLayer.update(viewModel: self, context: PersistenceController.current.viewContext)
            } else {
            
                let _ = MapLayer.createFrom(viewModel: self, context: PersistenceController.current.viewContext)
                do {
                    try PersistenceController.current.viewContext.save()
                } catch {
                    print("Error saving layer \(error)")
                }
            }
        }
    }
    
    let wmsParameters: [String] = ["SERVICE", "VERSION", "REQUEST", "FORMAT", "TILED", "WIDTH", "HEIGHT", "TRANSPARENT", "LAYERS", "CRS", "STYLES"]
    
    var urlParameters: [String : String] {
        if layerType == .wms {
            guard !url.isEmpty, let version = capabilities?.version else {
                return [:]
            }
            
            var layerNameArray: [String] = []
            var layersTransparent: Bool = true
            var mapTransparent: Bool = false
            
            if let formats = capabilities?.getMap?.formats, formats.contains(where: { format in
                format.starts(with: "image/png")
            }) {
                mapTransparent = true
            }
            for layer in selectedLayers {
                if let name = layer.name {
                    layerNameArray.append(name)
                }
                if let wmsLayer = layer as? WMSLayer {
                    layersTransparent = layersTransparent && wmsLayer.transparent
                }
            }
            let layerNames = layerNameArray.joined(separator: ",")
            var urlParameters: [String : String] = [:]
            urlParameters["SERVICE"] = "WMS"
            urlParameters["VERSION"] = version
            urlParameters["REQUEST"] = "GetMap"
            urlParameters["FORMAT"] = "\(mapTransparent || layersTransparent ? "image%2Fpng" : "image%2Fjpeg")"
            urlParameters["TILED"] = "true"
            urlParameters["WIDTH"] = "512"
            urlParameters["HEIGHT"] = "512"
            urlParameters["TRANSPARENT"] = "\(mapTransparent || layersTransparent ? "true" : "false")"
            urlParameters["LAYERS"] = "\(layerNames)"
            urlParameters["CRS"] = "EPSG%3A3857"
            urlParameters["STYLES"] = ""
            
            return urlParameters.merging(userUrlParameters) { (current, _) in current }
        } else {
            return userUrlParameters
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
            if complete {
                self.geoPackageImported()
            }
        }
        .store(in: &cancellable)
        
        importer.progress.$failure.receive(on: DispatchQueue.main).sink { failure in
            if let failure = failure {
                self.error = failure
            }
        }
        .store(in: &cancellable)
    }
    
    convenience init(mapLayer: MapLayer) {
        self.init()
        self.mapLayer = mapLayer
        self.fileName = mapLayer.name
        self.displayName = mapLayer.displayName ?? ""
        self.username = mapLayer.username ?? ""
        self.maximumZoom = Int(mapLayer.maxZoom)
        self.minimumZoom = Int(mapLayer.minZoom)
        self.minLatitude = mapLayer.minLatitude
        self.maxLatitude = mapLayer.maxLatitude
        self.minLongitude = mapLayer.minLongitude
        self.maxLongitude = mapLayer.maxLongitude
        self.layerType = LayerType(rawValue: mapLayer.type ?? "Unknown") ?? .unknown
        self.order = Int(mapLayer.order)
        self.visible = mapLayer.visible
        self.refreshRate = Int(mapLayer.refreshRate)
        if let mapLayerUrl = mapLayer.url {
            self.url = mapLayerUrl
        }
        if self.layerType == .geopackage {
            self.geoPackageImported()
        }
        
        if self.username != "", let credentials = Keychain().getCredentials(server: self.url , account: self.username) {
            self.password = credentials.password
        }
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
        var url: String = ""
        if userUrlParameters.isEmpty {
            url = "\(plainUrl)/0/0/0.png"
        } else {
            let urlParamString = urlParameters.map({ (key: String, value: String) in
                "\(key)=\(value)"
            }).joined(separator: "&")
            url = "\(plainUrl)/0/0/0.png?\(urlParamString)"
        }
        
        guard let url = URL(string: url) else {
            error = "Invalid URL"
            print("invalid url")
            return
        }
        error = nil
        var urlRequest: URLRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        var headers: HTTPHeaders = [:]
        if !username.isEmpty, !password.isEmpty {
            headers.add(.authorization(username: username, password: password))
        }
        
        MSI.shared.capabilitiesSession.request(url, method: .get, headers: headers)
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
            guard let url = URL(string: url)?.removingQueries else {
                error = "Invalid URL"
                print("invalid url")
                return
            }
            error = nil
            
            var urlRequest: URLRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let parameters: Parameters = [
                "SERVICE":"WMS",
                "REQUEST": "GetCapabilities"
            ]
            // merge the paramters but let the non user parameters override
            let filteredUserUrlParameters = userUrlParameters.filter({ element in
                !wmsParameters.contains { param in
                    param == element.key.uppercased()
                }
            })
            let allUrlParameters = parameters.merging(filteredUserUrlParameters) { (current, _) in current }
            urlRequest = try URLEncoding.default.encode(urlRequest, with: allUrlParameters)
            
            var headers: HTTPHeaders = [:]
            if !username.isEmpty, !password.isEmpty {
                headers.add(.authorization(username: username, password: password))
            }
            MSI.shared.capabilitiesSession.request(url, method: .get, parameters: allUrlParameters, headers: headers)
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
                            if let mapLayer = self.mapLayer {
                                for var subLayer: any LayerInfo in self.capabilities?.layers ?? [] {
                                    self.setSelectedLayers(layerNames: mapLayer.layerNames, layer: &subLayer)
                                }
                            }
                            
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
    
    func setSelectedLayers(layerNames: [String], layer: inout any LayerInfo) {
        if layerType == .wms {
            if layerNames.contains(where: { layerName in
                layerName == layer.name
            }) {
                layer.selected = true
                updateSelectedLayers(layer: layer)
            }
            for var subLayer: any LayerInfo in (layer as? WMSLayer)?.layers ?? [] {
                setSelectedLayers(layerNames: layerNames, layer:&subLayer)
            }
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
    let layers: [WMSLayer]?
    let getMap: GetMap?
    
    var webMercatorLayers: [WMSLayer] {
        return layers?.reduce([], { partialResult, layer in
            if let layer = layer.webMercatorLayers() {
                return partialResult + [layer]
            }
            return partialResult
        }) ?? []
    }
    
    var selectedLayers: [WMSLayer] {
        var selected: [WMSLayer] = []
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

final class WMSLayer: XMLObjectDeserialization, Identifiable, ObservableObject, LayerInfo {
    var id: String { name ?? "" }
    
    let title: String?
    let abstract: String?
    let name: String?
    let crs: [String]?
    let layers: [WMSLayer]?
    var boundingBox: BoundingBox?
    let transparent: Bool
    
    @Published var selected: Bool = false
    
    static func == (lhs: WMSLayer, rhs: WMSLayer) -> Bool {
        return lhs.id == rhs.id
    }
    
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
    
    func webMercatorLayers(parentIsWebMercator: Bool = false) -> WMSLayer? {
        var sublayers: [WMSLayer] = []
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
        return WMSLayer(title: title, abstract: abstract, name: name, crs: crs, layers: sublayers, boundingBox: boundingBox, transparent: transparent)
    }
    
    var selectedLayers: [WMSLayer] {
        
        let selectedLayers: [WMSLayer] = layers?.filter({ layer in
            layer.selected && layer.name != nil
        }).map({ layer in
            layer
        }) ?? []
        
        let selectedSubLayers: [WMSLayer] = layers?.filter({ layer in
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
    
    init(title: String?, abstract: String?, name: String?, crs: [String]?, layers: [WMSLayer]?, boundingBox: BoundingBox?, transparent: Bool) {
        self.title = title
        self.abstract = abstract
        self.name = name
        self.crs = crs
        self.layers = layers
        self.boundingBox = boundingBox
        self.transparent = transparent
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> WMSLayer {
        var transparent = true
        let opaque: Int? = node.value(ofAttribute: "opaque")
        if let opaque = opaque {
            transparent = opaque == 1 ? false : true
        } else {
            transparent = false
        }
        
        return try WMSLayer(
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
