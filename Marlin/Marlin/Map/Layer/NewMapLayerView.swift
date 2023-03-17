//
//  NewMapLayerView.swift
//  Marlin
//
//  Created by Daniel Barela on 2/28/23.
//

import Foundation
import SwiftUI
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

class NewMapLayerViewModel: ObservableObject {
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
    
    var description: some View {
        switch layers {
        case nil:
            return Text("🎥 \(title ?? "")")
        case .some(let layers):
            return layers.isEmpty ? Text("🎥 \(title ?? "")") : Text("🗂 \(title ?? "")")
        }
    }
}

struct LayerURLView: View {
    @ObservedObject var viewModel: NewMapLayerViewModel
    @ObservedObject var mapState: MapState
    @FocusState var isInputActive: Bool
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            List {
                Section {
                    VStack(alignment: .leading) {
                        Text("Layer URL")
                            .overline()
                        TextField("Layer URL", text: $viewModel.url)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .underlineTextFieldWithLabel()
                            .focused($isInputActive)
                            .accessibilityElement()
                            .accessibilityLabel("Layer URL input")
                    }
                    .frame(maxWidth:.infinity)
                } header: {
                    EmptyView().frame(width: 0, height: 0, alignment: .leading)
                }
                
                if viewModel.retrievingWMSCapabilities {
                    HStack(alignment: .center) {
                        ProgressView()
                            .tint(Color.primaryColorVariant)
                        Text("Attempting to retrieve WMS Capabilities document...")
                            .primary()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.backgroundColor)
                } else if viewModel.retrievingXYZTile {
                    HStack(alignment: .center) {
                        ProgressView()
                            .tint(Color.primaryColorVariant)
                        Text("Attempting to retrieve 0/0/0 tile...")
                            .primary()
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.backgroundColor)
                } else if viewModel.triedCapabilities && viewModel.triedXYZTile && viewModel.layerType == .unknown {
                    Section("Tile Server Information") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Unable to retrieve capabilities document or the 0/0/0 tile.  Please choose the correct type of tile server below.")
                                .primary()
                            Text("-or-")
                                .overline()
                            Button("Try again") {
                                viewModel.retrieveWMSCapabilitiesDocument()
                            }
                            .buttonStyle(MaterialButtonStyle())
                        }
                    }
                }
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    Image(systemName: viewModel.layerType == .xyz ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            viewModel.layerType = .xyz
                        }
                        .accessibilityElement()
                        .accessibilityLabel("XYZ")
                    Text("XYZ")
                        .overline()
                    Image(systemName: viewModel.layerType == .wms ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            viewModel.layerType = .wms
                        }
                        .accessibilityElement()
                        .accessibilityLabel("WMS")
                    Text("WMS")
                        .overline()
                    Image(systemName: viewModel.layerType == .tms ? "circle.inset.filled": "circle")
                        .foregroundColor(Color.primaryColor)
                        .onTapGesture {
                            viewModel.layerType = .tms
                        }
                        .accessibilityElement()
                        .accessibilityLabel("TMS")
                    Text("TMS")
                        .overline()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.backgroundColor)
                
                if viewModel.layerType == .wms {
                    if let capabilities = viewModel.capabilities {
                        Section("WMS Server Information") {
                            DisclosureGroup {
                                VStack(alignment: .leading, spacing: 8) {
                                    Property(property: "Layer Count", value: "\(capabilities.totalLayers)")
                                    Property(property: "WMS Version", value: capabilities.version)
                                    Property(property: "Contact Person", value: capabilities.contactPerson)
                                    Property(property: "Contact Organization", value: capabilities.contactOrganization)
                                    if let phone = capabilities.contactTelephone {
                                        Property(property: "Contact Telephone", valueView: AnyView(
                                            Link(phone, destination: URL(string: "tel:\(phone)")!)
                                                .font(Font.subheadline)
                                                .foregroundColor(Color.primaryColor)
                                        ))
                                    }
                                    if let email = capabilities.contactEmail {
                                        Property(property: "Contact Email", valueView: AnyView(
                                            Link(email, destination: URL(string: "mailto:\(email)")!)
                                                .font(Font.subheadline)
                                                .foregroundColor(Color.primaryColor)
                                        ))
                                    }
                                }
                                
                            } label : {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(capabilities.title ?? "WMS Server Information")
                                        .primary()
                                    Text(capabilities.abstract ?? "")
                                        .secondary()
                                }
                            }
                            .tint(Color.primaryColor)
                            .frame(maxWidth: .infinity)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("More Server Information")
                        }
                    } else {
                        Section("WMS Server Information") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unable to retrieve capabilities document")
                                    .primary()
                                Button("Try again") {
                                    viewModel.retrieveWMSCapabilitiesDocument()
                                }
                                .buttonStyle(MaterialButtonStyle())
                            }
                        }
                    }
                } else if viewModel.layerType != .unknown {
                    MarlinMap(name: "XYZ Layer Map", mixins: [BaseOverlaysMap(viewModel: viewModel)], mapState: mapState)
                        .frame(minHeight: 300, maxHeight: .infinity)
                }
            }
            .dataSourceDetailList()
            .listRowBackground(Color.white)
            
            NavigationLink {
                if viewModel.layerType == .wms {
                    WMSLayerEditView(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
                } else {
                    LayerConfiguration(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
                }
            } label: {
                Text("Confirm URL")
                    .tint(Color.primaryColor)
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .background(Color.backgroundColor)
            .disabled(!viewModel.urlOK)
            .padding(8)
        }
        .navigationTitle("Layer URL")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Create Map Layer")
                    .foregroundColor(Color.onPrimaryColor)
                    .tint(Color.onPrimaryColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isInputActive = false
                }
                .tint(Color.primaryColorVariant)
            }
        }
    }
}

struct LayerConfiguration: View {
    @ObservedObject var viewModel: NewMapLayerViewModel
    @FocusState var isInputActive: Bool
    @ObservedObject var mapState: MapState
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Group {
                ScrollView {
                    Group {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Layer Name")
                                .overline()
                            TextField("Layer Name", text: $viewModel.displayName)
                                .keyboardType(.default)
                                .underlineTextFieldWithLabel()
                                .focused($isInputActive)
                                .accessibilityElement()
                                .accessibilityLabel("Layer Name input")
                        }
                    }
                    Group {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Zoom Level Constraints")
                                .overline()
                            HStack {
                                TextField("Min Zoom", value: $viewModel.minimumZoom, format: .number.grouping(.never))
                                    .keyboardType(.numberPad)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Minimum Zoom input")
                                Text("to")
                                    .overline()
                                TextField("Max Zoom", value: $viewModel.maximumZoom, format: .number.grouping(.never))
                                    .keyboardType(.numberPad)
                                    .underlineTextFieldWithLabel()
                                    .focused($isInputActive)
                                    .accessibilityElement()
                                    .accessibilityLabel("Maximum Zoom input")
                            }
                        }
                    }
                    Group {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refresh Rate")
                                .overline()
                            HStack {
                                Picker("Refresh Rate Units", selection: $viewModel.refreshRateUnits) {
                                    ForEach(RefreshRateUnit.allCases, id: \.self) { value in
                                        Text(value.name)
                                            .tag(value)
                                    }
                                }
                                .scaledToFill()
                                .labelsHidden()
                                .tint(Color.primaryColorVariant)
                                
                                if viewModel.refreshRateUnits != .none {
                                    TextField("Refresh Rate", value: $viewModel.refreshRate, format: .number.grouping(.never))
                                        .keyboardType(.numberPad)
                                        .underlineTextFieldWithLabel()
                                        .focused($isInputActive)
                                        .accessibilityElement()
                                        .accessibilityLabel("Refresh Rate input")
                                } else {
                                    Spacer()
                                }
                            }
                            .padding(.leading, -8)
                        }
                    }
                }
                .frame(maxWidth:.infinity)
                .padding(8)
            }
            .frame(minHeight: 0, maxHeight: .infinity)
            
            MarlinMap(name: "WMS Layer Map", mixins: [BaseOverlaysMap(viewModel: viewModel)], mapState: mapState)
                .frame(minHeight: 0, maxHeight: .infinity)
            
            Button("Create Layer") {
                viewModel.create()
                isPresented.toggle()
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
            .tint(viewModel.displayName.count != 0 ? Color.primaryColorVariant : Color.disabledColor)
            .disabled(viewModel.displayName.count == 0)
            .padding(8)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Layer Configuration")
                    .foregroundColor(Color.onPrimaryColor)
                    .tint(Color.onPrimaryColor)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Cancel") {
                    isPresented.toggle()
                }
            }
            ToolbarItem(placement: .keyboard) {
                Spacer()
            }
            ToolbarItem(placement: .keyboard) {
                Button("Done") {
                    isInputActive = false
                }
                .tint(Color.primaryColorVariant)
            }
        }
    }
}

struct NewMapLayerView: View {
    @StateObject var viewModel: NewMapLayerViewModel = NewMapLayerViewModel()
    @FocusState var isInputActive: Bool
    @StateObject var mapState: MapState = MapState()
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            LayerURLView(viewModel: viewModel, mapState: mapState, isPresented: $isPresented)
        }
        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .top)
        .background(Color.backgroundColor)
    }
}

struct LayerRow: View {
    @ObservedObject var viewModel: NewMapLayerViewModel
    @ObservedObject var layer: Layer
    var parentWebMercator: Bool = false
    var body: some View {
        buildRow()
    }
    
    @ViewBuilder
    func buildRow() -> some View {
        if let layers = layer.layers, !layers.isEmpty {
            HStack {
                Image(systemName: "folder")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(layer.title ?? "Layer Group")")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                    if let abstract = layer.abstract {
                        Text(abstract)
                            .multilineTextAlignment(.leading)
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                    }
                }
            }
        } else if parentWebMercator || layer.isWebMercator {
            // case where there are no sub layers
            // these will be the selectable layers
            Toggle(isOn: $layer.selected, label: {
                HStack {
                    Image(systemName: "square.3.layers.3d")
                        .tint(Color.onSurfaceColor)
                        .opacity(0.60)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(layer.title ?? "Layer")")
                            .multilineTextAlignment(.leading)
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                        if let abstract = layer.abstract {
                            Text(abstract)
                                .multilineTextAlignment(.leading)
                                .font(Font.caption)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                        }
                    }
                    .padding([.top, .bottom], 4)
                }
            })
            .onChange(of: layer.selected, perform: { newValue in
                viewModel.updateTemplate()
            })
            .toggleStyle(iOSCheckboxToggleStyle())
            .contentShape(Rectangle())
            .onTapGesture {
                layer.selected.toggle()
            }
            .tint(Color.primaryColor)
            .accessibilityElement()
            .accessibilityLabel("Layer \(layer.title ?? "") Toggle")
        } else {
            HStack {
                Image(systemName: "nosign")
                    .tint(Color.disabledColor)
                    .opacity(0.60)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(layer.title ?? "Layer")")
                        .multilineTextAlignment(.leading)
                        .font(Font.body1)
                        .foregroundColor(Color.disabledColor.opacity(0.87))
                    Text("Layer is not availabe in web mercator")
                        .font(Font.caption)
                        .foregroundColor(Color.disabledColor.opacity(0.87))
                }
                .padding([.top, .bottom], 4)
            }
        }
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                configuration.label
                Spacer()
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
            }
        })
    }
}
