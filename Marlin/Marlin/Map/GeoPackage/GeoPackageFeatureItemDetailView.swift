//
//  GeoPackageFeatureItemDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 4/11/23.
//

import SwiftUI
import MapKit
import geopackage_ios

struct GeoPackageFeatureItemDetailView: View {
    @StateObject var mapState: MapState = MapState()
    var featureItem: GeoPackageFeatureItem
    
    init(featureItem: GeoPackageFeatureItem) {
        self.featureItem = featureItem
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    MarlinMap(name: "GeoPackage Feature Item Detail Map", mixins: [UserLayersMap()], mapState: mapState)
                        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                        .onAppear {
                            mapState.center = MKCoordinateRegion(center: featureItem.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                        .onChange(of: featureItem) { featureItem in
                            mapState.center = MKCoordinateRegion(center: featureItem.coordinate, zoomLevel: 17.0, pixelWidth: 300.0)
                        }
                    Group {
                        if let date = featureItem.dateString {
                            Text(date)
                                .overline()
                        }
                        Text(featureItem.itemTitle)
                            .primary()
                        if let secondary = featureItem.secondaryTitle {
                            Text(secondary)
                                .lineLimit(8)
                                .secondary()
                        }
                        Text(featureItem.layerName ?? "")
                            .overline()
                        GeoPackageFeatureItemActionBar(featureItem: featureItem, showMoreDetailsButton: false, showFocusButton: true)
                            .padding(.bottom, 16)
                    }.padding([.leading, .trailing], 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            mediaGrid()
            
            if let featureRowData = featureItem.featureRowData {
                propertySection(featureRowData: featureRowData, sectionTitle: "Feature Details")
            }
        }
        .dataSourceDetailList()
        .navigationTitle("GeoPackage Feature")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: GeoPackageFeatureItem.self)
        }
    }
    
    @ViewBuilder
    func mediaGrid() -> some View {
        if let mediaRows = featureItem.mediaRows, !mediaRows.isEmpty {
            Section("Media") {
                VStack {
                    ForEach(mediaRows, id: \.self) { media in
                        if let media = media, let image = media.dataImage(), let tableName = media.table.tableName(), let id = media.idValue() {
                            Image(uiImage: media.dataImage())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .onTapGesture {
                                    if let imageData = image.pngData(), let docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                                        
                                        let filename = docsUrl.appendingPathComponent("gp_image_\(tableName)_\(id).png")
                                        try? imageData.write(to: filename)
                                        NotificationCenter.default.post(name: .DocumentPreview, object: filename)
                                    }
                                    
                                    
                                }
                        }
                    }
                }
                .card()
            }
            .dataSourceSection()
        }
    }
    
    @ViewBuilder
    func propertySection(featureRowData: GPKGFeatureRowData, sectionTitle: String) -> some View {
        if let values = featureRowData.values() as? [String: Any] {
            
            Section(sectionTitle) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(values.sorted(by: { $0.0 < $1.0 }), id: \.key) { key, value in
                        if key != featureRowData.geometryColumn() {
                            Property(property: key, value: featureItem.valueString(key: key, value: value))
                        }
                    }
                }
                .padding(.all, 16)
                .card()
                .frame(maxWidth: .infinity)
            }
            .dataSourceSection()
        }
    }
    
    @ViewBuilder
    func attributesSection() -> some View {
        if let attributeRows = featureItem.attributeRows {
            Group {
                ForEach(attributeRows, id: \.self) { attributeRow in
                    if let featureRowData = attributeRow.featureRowData {
                        propertySection(featureRowData: featureRowData, sectionTitle: "Attributes")
                    }
                }
            }
        }
    }
}
