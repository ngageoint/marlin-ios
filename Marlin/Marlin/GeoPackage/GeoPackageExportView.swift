//
//  GeoPackageExportView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/23.
//

import SwiftUI

struct GeoPackageExportView: View {
    @EnvironmentObject var dataSourceList: DataSourceList

    @StateObject var exporter: GeoPackageExporter = GeoPackageExporter()
    
    @State var exportRequest: [DataSourceExportRequest]
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Text("Included Data Sources".uppercased())
                        .overline()
                        .padding(.top, 8)
                        .padding(.all, 8)
                    Spacer()
                }
                HStack {
                    ForEach(dataSourceList.mappableDataSources, id: \.self) { dataSource in
                        let included = exportRequest.contains { request in
                            request.dataSourceItem.key == dataSource.key
                        }
                        
                        Button(action: {
                            if exporter.exporting {
                                return
                            }
                            if included {
                                exportRequest.removeAll { request in
                                    request.dataSourceItem.key == dataSource.key
                                }
                            } else {
                                exportRequest.append(DataSourceExportRequest(dataSourceItem: dataSource, filters: UserDefaults.standard.filter(dataSource.dataSource)))
                            }
                        }) {
                            Label(title: {}) {
                                if let image = dataSource.dataSource.image {
                                    Image(uiImage: image)
                                        .renderingMode(.template)
                                        .tint(Color.white)
                                }
                            }
                        }
                        .buttonStyle(MaterialFloatingButtonStyle(type: .custom, size: .mini, foregroundColor: included ? Color.white : Color.disabledColor, backgroundColor: included ? Color(uiColor: dataSource.dataSource.color) : Color.disabledBackground))
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(dataSource.dataSource.key) Export Toggle")
                    }
                }
                if !exporter.exporting && !exporter.complete {
                    HStack {
                        Text("Data Source Filters".uppercased())
                            .overline()
                            .padding(.top, 8)
                            .padding(.all, 8)
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        ForEach(exportRequest) { request in
                            ExportFilterRow(exportRequest: request)
                            Divider()
                        }
                        .background(Color.surfaceColor)
                    }
                } else {
                    HStack {
                        Text("Export Status".uppercased())
                            .overline()
                            .padding(.top, 8)
                            .padding(.all, 8)
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        ForEach(exportRequest) { request in
                            ExportProgressRow(progress: request.progress)
                            Divider()
                        }
                        .background(Color.surfaceColor)
                    }
                }
            }
            if exporter.complete {
                Text("Export complete")
            } else if exporter.exporting {
                Text("Exporting")
            }
            if let creationError = exporter.creationError {
                Text("Error \(creationError)")
            }
            Button("Export") {
                exporter.export(exportRequest: exportRequest)
            }
            .buttonStyle(MaterialButtonStyle(type:.contained))
            .padding(.all, 16)
        }
        .navigationTitle("GeoPackage Export")
        .background(Color.backgroundColor)
    }
}

struct ExportProgressRow: View {
    @State var filterCount: Int = 0
    
    @ObservedObject var progress: DataSourceExportProgress
    
    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading) {
            VStack {
                HStack(alignment: .center, spacing: 8) {
                    if let systemImageName = progress.dataSourceItem.dataSource.systemImageName {
                        Image(systemName: systemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    } else if let imageName = progress.dataSourceItem.dataSource.imageName {
                        Image(imageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                    
                    Text(progress.dataSourceItem.dataSource.fullDataSourceName)
                        .primary()
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("\(Int(progress.totalCount))")
                        .overline()
                }
                .contentShape(Rectangle())
                .padding([.leading, .top, .bottom, .trailing], 16)
                
                ProgressView(value: progress.exportCount, total: progress.totalCount)
                    .progressViewStyle(.linear)
                    .tint(Color.primaryColorVariant)
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel("export \(progress.dataSourceItem.dataSource.fullDataSourceName) progress")
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(progress.dataSourceItem.dataSource.color))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                    .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
    }
}

struct ExportFilterLabel: View {
    @ObservedObject var viewModel: TemporaryFilterViewModel
    var exportRequest: DataSourceExportRequest
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let systemImageName = exportRequest.dataSourceItem.dataSource.systemImageName {
                Image(systemName: systemImageName)
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
            } else if let imageName = exportRequest.dataSourceItem.dataSource.imageName {
                Image(imageName)
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
            }
            
            Text(exportRequest.dataSourceItem.dataSource.fullDataSourceName)
                .primary()
                .multilineTextAlignment(.leading)
            Spacer()
            Text("\(viewModel.count)")
                .overline()
        }
    }
}

struct ExportFilterRow: View {
    @State var filterCount: Int = 0

    var exportRequest: DataSourceExportRequest
    @State var viewModel: TemporaryFilterViewModel?

    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading) {
            if let viewModel = viewModel {
                DisclosureGroup {
                    FilterView(viewModel: viewModel)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(exportRequest.dataSourceItem.dataSource.fullDataSourceName) filters")
                } label: {
                    ExportFilterLabel(viewModel: viewModel, exportRequest: exportRequest)
                        .contentShape(Rectangle())
                        .padding([.leading, .top, .bottom, .trailing], 16)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(filterCount) \(exportRequest.dataSourceItem.dataSource.fullDataSourceName) filters")
                }
                .padding(.trailing, 16)
                .contentShape(Rectangle())
                .accessibilityElement(children: .contain)
                .accessibilityLabel("expand \(exportRequest.dataSourceItem.dataSource.fullDataSourceName) filters")
                .background(
                    HStack {
                        Rectangle()
                            .fill(Color(exportRequest.dataSourceItem.dataSource.color))
                            .frame(maxWidth: 8, maxHeight: .infinity)
                        Spacer()
                    }
                    .background(Color.surfaceColor)
                )
                .tint(Color.primaryColorVariant)
            }
        }
        .onAppear {
            viewModel = TemporaryFilterViewModel(dataSource: exportRequest.dataSourceItem.dataSource, filters: exportRequest.filters ?? UserDefaults.standard.filter(exportRequest.dataSourceItem.dataSource))
        }
    }
}
